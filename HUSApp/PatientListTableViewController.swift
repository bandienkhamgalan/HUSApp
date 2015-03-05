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
        self.dismissViewControllerAnimated(true, completion: nil)
        managedObjectContext!.save(nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        let destination = segue.destinationViewController as UIViewController
        switch(destination.restorationIdentifier!)
        {
            case "PatientEditor":
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
        
    }

    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        searchController = UISearchController(searchResultsController: self)
        searchController!.searchResultsUpdater = self
    }

    override func viewDidLoad()
    {
        self.results!.performFetch(nil);
        println("fetched \(self.results!.fetchedObjects!.count) objects")
        
        for object in self.results!.fetchedObjects!
        {
            var patient = object as Patient
            println(patient)
        }
        
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        if self.results == nil
        {
            return 0
        }
        println("\(self.results!.sections!.count) sections in table view");
        return self.results!.sections!.count;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let currentPatient = self.results!.objectAtIndexPath(indexPath) as Patient
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let patientTVC = storyboard.instantiateViewControllerWithIdentifier("PatientViewer") as PatientTableViewController
        patientTVC.setup(managedObjectContext: managedObjectContext!, patient: currentPatient)
        let parentNVC = self.parentViewController as UINavigationController
        println("created patient tvc \(patientTVC)")
        parentNVC.pushViewController(patientTVC, animated: true)
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if self.results == nil
        {
            return 0
        }
        let sectionInfo = self.results!.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects;
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
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath)
    {
        var currentPatient = self.results!.objectAtIndexPath(indexPath) as Patient
        cell.textLabel!.text = currentPatient.name

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

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("patientCell", forIndexPath: indexPath) as UITableViewCell
        
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]!
    {
        return self.results!.sectionIndexTitles
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int
    {
        return self.results!.sectionForSectionIndexTitle(title, atIndex: index)
    }
    
    override func tableView(tableView: UITableView,
        titleForHeaderInSection section: Int) -> String?
    {
        let sectionInfo = self.results!.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.indexTitle
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete
        {
            // Delete the row from the data source
            let patient = self.results!.objectAtIndexPath(indexPath) as Patient
            managedObjectContext?.deleteObject(patient)
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

}
