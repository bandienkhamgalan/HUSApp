/**
	PatientListTableViewController.swift

	A table view controller that displays Patient entities with a search bar. The data is compiled and kept up to date with the use of an NSFetchedResultsController.
*/

import UIKit
import CoreData

class PatientListTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, PatientEditorViewControllerDelegate, SettingsViewControllerDelegate, UISearchResultsUpdating
{
    var searchController: UISearchController?
    var results: NSFetchedResultsController?
    
    var managedObjectContext: NSManagedObjectContext?
	{
		didSet // set up NSFetchedResultsController when view controller is linked with Core Data
        {
            var fetchRequest = NSFetchRequest(entityName:"Patient")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "patientID", ascending: true, selector:"caseInsensitiveCompare:")]
            results = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath:nil, cacheName:nil)
            results!.delegate = self
        }
    }
	
	required init(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
		// initialize and setup search bar bar
		self.searchController = UISearchController(searchResultsController: nil)
		self.searchController!.searchResultsUpdater = self
		self.searchController!.hidesNavigationBarDuringPresentation = false
		self.searchController!.dimsBackgroundDuringPresentation = false
		self.searchController!.searchBar.sizeToFit()
	}
	
	override func viewDidLoad()
	{
		self.results?.performFetch(nil)
		self.tableView.tableHeaderView = self.searchController!.searchBar
		self.searchController!.searchBar.tintColor = UIColor.whiteColor()
		super.viewDidLoad()
	}
	
	/*	userDidPressSettings is set to fire when the user taps on the Settings left bar button item in the navigation bar. */
	@IBAction func userDidPressSettings(sender: UIBarButtonItem)
	{
		// resign first responder from search bar to prevent persistent view
		self.searchController!.active = false
		
		// load, setup and present modally SettingsTableViewController from Main.storyboard
        let storyboard = UIStoryboard(name: "Main", bundle:nil)
		var settingsTVC = storyboard.instantiateViewControllerWithIdentifier("SettingsTable") as! SettingsTableViewController
        settingsTVC.delegate = self
		var settingsNVC = UINavigationController(rootViewController: settingsTVC)
		self.presentViewController(settingsNVC, animated: true, completion: nil)
	}
	
	/*	userDidPressDone is a SettingsTableViewControllerDelegate method called by the settings table view controller currently being presented modally. 
		It serves as a cue to dismiss the modal view controller. */
    func userDidPressDone(settings: SettingsTableViewController)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
	
	/*	prepareForSegue intercepts navigation logic set up in Main.storyboard whereby a patient editor screen comes up after the user presses "new patient".
		This interception is necessary to set-up the patient editor screen. */
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
	{
		let destination = segue.destinationViewController as! UIViewController
		switch(destination.restorationIdentifier!)
		{
			case "PatientEditor":
				// only intercept a segue to PatientEditor
				self.searchController!.active = false // resign first responder from search bar to prevent persistent view
				let destinationNVC = destination as! UINavigationController
				let patientEditor = destinationNVC.visibleViewController as! PatientEditorViewController
				
				// create a temporary new patient to be edited
				let entityDescript = NSEntityDescription.entityForName("Patient", inManagedObjectContext: managedObjectContext!)!
				let newPatient = NSManagedObject(entity: entityDescript, insertIntoManagedObjectContext: nil) as! Patient
				
				// assign patient and delegate
				patientEditor.delegate = self
				patientEditor.patient = newPatient
				break
			default:
				break
		}
	}
	
	/*	userDidPressCancelInPatientEditor is a PatientEditorViewControllerDelegate method called by the patient editor being presented modally.
		It serves as a cue to dismiss the modal view controller. */
    func userDidPressCancelInPatientEditor(patientEditor: PatientEditorViewController)
    {
		self.dismissViewControllerAnimated(true, completion: nil)
    }
	
	/*	userDidPressDoneInPatientEditor is a PatientEditorViewControllerDelegate method called by the patient editor being presented modally.
		It serves as a cue to dismiss the modal view controller and save the information. */
	func userDidPressDoneInPatientEditor(patientEditor: PatientEditorViewController)
    {
		// insert the temporary object into the object store and save changes
		managedObjectContext!.insertObject(patientEditor.patient!)
		managedObjectContext!.save(nil)
		
        self.dismissViewControllerAnimated(true, completion: nil)
    }
	
	/*	updateSearchResultsForSearchController is a search results updater delegate method that fires whenever the user makes changes to the search string. 
		Searching on this view controller works by modifying the Core Data fetch request, specifically by adding a predicate. */
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
		// recreate original fetch request
		var fetchRequest = NSFetchRequest(entityName:"Patient")
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "patientID", ascending: true, selector:"caseInsensitiveCompare:")]
		if count(searchController.searchBar.text) > 0
		{
			// add predicate if search query has length > 0 (not empty)
			fetchRequest.predicate = NSPredicate(format: "patientID CONTAINS[c] %@", searchController.searchBar.text)
		}
		
		// recreate fetch results controller and execute fetch request
		results = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath:nil, cacheName:nil)
		results!.performFetch(nil)
		
		tableView!.reloadData()
    }

    // Table view data source methods

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
		if self.results == nil
		{
			return 0
		}
		
		return self.results!.sections!.count;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		if self.results == nil
		{
			return 0
		}
        else
        {
            let sectionInfo = self.results!.sections![section] as! NSFetchedResultsSectionInfo
            return sectionInfo.numberOfObjects;
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("patientCell", forIndexPath: indexPath) as! UITableViewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
	
	/*	configureCell is a helper function that sets the labels inside a table view cell accordingly to the Patient entity as fetched by the fetched results controller. */
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath)
    {
        var currentPatient = self.results!.objectAtIndexPath(indexPath) as! Patient
        cell.textLabel!.text = currentPatient.patientID
    }
	
	//	Fetched results controller delegate methods
	//		These methods are allow the table view to update itself live, as changes are made to the object store.
	
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
	
	//	Table view delegate methods

	/*	This function navigates the user to the next screen when the user has selected a Patient entity. */
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		// initialize and setup next view controller to present
		let currentPatient = self.results!.objectAtIndexPath(indexPath) as! Patient
		self.searchController!.active = false
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let patientTVC = storyboard.instantiateViewControllerWithIdentifier("PatientViewer") as! PatientTableViewController
		patientTVC.setup(managedObjectContext: managedObjectContext!, patient: currentPatient)
		let parentNVC = self.parentViewController as! UINavigationController
		
		// push view controller onto navigation controller stack
		parentNVC.pushViewController(patientTVC, animated: true)
	}
	
	/*	This function provides the functionality of deleting Patients by swiping on the cells in the table view. */
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
			// Fetch the corresponding Patient entity and delete from object store
			// table view will update to reflect this change automatically thanks to fetched results controller delegate methods
			
            let patient = self.results!.objectAtIndexPath(indexPath) as! Patient
            var patientID:String? = patient.patientID
			for obj in patient.operations
			{
				managedObjectContext!.deleteObject(obj as! NSManagedObject)
			}
            managedObjectContext!.deleteObject(patient)
            managedObjectContext!.save(nil)	
        }
    }
}
