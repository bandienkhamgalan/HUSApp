//
//  PatientListTableViewController.swift
//  app development project
//
//  Created by Bandi Enkh-Amgalan on 3/1/15.
//  Copyright (c) 2015 a. All rights reserved.
//

import UIKit
import CoreData

class PatientListTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, PatientEditorViewControllerDelegate, UISearchResultsUpdating {
    
    
    var account = DBAccountManager.sharedManager()?.linkedAccount
    var dbFileSystem = DBFilesystem.sharedFilesystem()
    
	@IBAction func userDidPressSettings(sender: UIBarButtonItem)
	{
		let storyboard = UIStoryboard(name: "Main", bundle:nil)
		self.searchController!.active = false
		var settingsTVC = storyboard.instantiateViewControllerWithIdentifier("SettingsTable") as SettingsTableViewController
		var settingsNVC = UINavigationController(rootViewController: settingsTVC)
		self.presentViewController(settingsNVC, animated: true, completion: nil)
	}
    
    func userDidPressDone(settings: SettingsTableViewController)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
	
    var searchController: UISearchController?
    var results: NSFetchedResultsController?
    var managedObjectContext: NSManagedObjectContext?
    {
        didSet
        {
            var fetchRequest = NSFetchRequest(entityName:"Patient")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector:"caseInsensitiveCompare:")]
            results = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath:"firstLetter", cacheName:nil)
            results!.delegate = self
        }
    }
    
    func userDidPressCancel(patientEditor: PatientEditorViewController)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
        let patient = patientEditor.patient
        managedObjectContext!.deleteObject(patient!)
        managedObjectContext!.save(nil)
    }
    
    func userDidPressDone(patientEditor: PatientEditorViewController)
    {
        account = DBAccountManager.sharedManager().linkedAccount
        if (dbFileSystem == nil){
            DBFilesystem.setSharedFilesystem(DBFilesystem(account: DBAccountManager.sharedManager().linkedAccount))
            dbFileSystem = DBFilesystem.sharedFilesystem()
        }
        var name:String? = patientEditor.patient?.name
        var path:String = "/" + name!
        var dbpath:DBPath = DBPath.root().childPath(path)
        dbFileSystem.createFolder(dbpath, error: nil)
 
        managedObjectContext!.save(nil)
        self.tableView.reloadData()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        let destination = segue.destinationViewController as UIViewController
        switch(destination.restorationIdentifier!)
        {
            case "PatientEditor":
				self.searchController!.active = false
                let destinationNVC = destination as UINavigationController
                let patientEditor = destinationNVC.visibleViewController as PatientEditorViewController
                let entityDescript = NSEntityDescription.entityForName("Patient", inManagedObjectContext: managedObjectContext!)!
                let newPatient = NSManagedObject(entity: entityDescript, insertIntoManagedObjectContext: managedObjectContext!) as Patient
                patientEditor.delegate = self
                patientEditor.patient = newPatient
                break
            default:
                break
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
		println("in updatesearchresultsforsearchcontroller: \(searchController.searchBar.text)")
		var fetchRequest = NSFetchRequest(entityName:"Patient")
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector:"caseInsensitiveCompare:")]
		if countElements(searchController.searchBar.text) > 0
		{
			fetchRequest.predicate = NSPredicate(format: "name CONTAINS[c] %@", searchController.searchBar.text)
		}
		results = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath:"firstLetter", cacheName:nil)
		results!.performFetch(nil)
		tableView!.reloadData()
    }

    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
		self.searchController = UISearchController(searchResultsController: nil)
		self.searchController!.searchResultsUpdater = self
		self.searchController!.hidesNavigationBarDuringPresentation = false
		self.searchController!.dimsBackgroundDuringPresentation = false
		self.searchController!.searchBar.sizeToFit()
    }

    override func viewDidLoad()
    {
        self.results!.performFetch(nil);
        
        for object in self.results!.fetchedObjects!
        {
            var patient = object as Patient
            println(patient)
        }
		
		self.tableView.tableHeaderView = self.searchController!.searchBar
        self.searchController!.searchBar.tintColor = themeColour
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
		if self.results == nil
		{
			return 0
		}
		return self.results!.sections!.count;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let currentPatient = self.results!.objectAtIndexPath(indexPath) as Patient
		self.searchController!.active = false
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let patientTVC = storyboard.instantiateViewControllerWithIdentifier("PatientViewer") as PatientTableViewController
        patientTVC.setup(managedObjectContext: managedObjectContext!, patient: currentPatient)
        let parentNVC = self.parentViewController as UINavigationController
        parentNVC.pushViewController(patientTVC, animated: true)
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		if self.results == nil
		{
			return 0
		}
		let sectionInfo = self.results!.sections![section] as NSFetchedResultsSectionInfo
		return sectionInfo.numberOfObjects;
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath)
    {
        var currentPatient = self.results!.objectAtIndexPath(indexPath) as Patient
        cell.textLabel!.text = currentPatient.name

    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("patientCell", forIndexPath: indexPath) as UITableViewCell
        
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]!
    {
		if self.tableView.contentSize.height > self.tableView.bounds.size.height * 1.5
		{
			var toReturn = self.results!.sectionIndexTitles
			toReturn.insert(UITableViewIndexSearch, atIndex: 0)
			return toReturn
		}
		else
		{
			return nil
		}
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int
    {
		if index == 0
		{
			tableView.contentOffset = CGPointMake(0, -tableView.contentInset.top)
			return NSNotFound
		}
		else
		{
			return self.results!.sectionForSectionIndexTitle(title, atIndex: index - 1)
		}
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        let sectionInfo = self.results!.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.indexTitle
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController)
    {
        tableView.beginUpdates();
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType)
    {
        switch(type)
        {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Left)
            break
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Right)
            break
        default:
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?)
    {
        switch(type)
        {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Left)
            break
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Right)
            break;
        case .Update:
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath:indexPath!)
            break
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Right)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Left)
            break
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController)
    {
        tableView.endUpdates()
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete
        {
            // Delete the row from the data source
            let patient = self.results!.objectAtIndexPath(indexPath) as Patient
            
            if (dbFileSystem == nil){
                account = DBAccountManager.sharedManager().linkedAccount
                DBFilesystem.setSharedFilesystem(DBFilesystem(account: account))
                dbFileSystem = DBFilesystem.sharedFilesystem()
            }
            var name:String? = patient.name
            var path:String = "/" + name!
            var dbpath:DBPath = DBPath.root().childPath(path)
            dbFileSystem.deletePath(dbpath, error: nil)
            
            managedObjectContext!.deleteObject(patient)
            managedObjectContext!.save(nil)
        }
    }
    

}
