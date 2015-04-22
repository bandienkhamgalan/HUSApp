/**
	PatientTableViewController.swift

	A grouped table view controller that displays 1. short description of a Patient and 2. all Operation entities under that Patient. Operation entities are compiled and kept up to date with the use of an NSFetchedResultsController.
*/

import UIKit

class PatientTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, PatientEditorViewControllerDelegate, OperationEditorViewControllerDelegate
{
    var patient: Patient?
    var results: NSFetchedResultsController?
    var managedObjectContext: NSManagedObjectContext?
	
	/*	This function must be called by whichever class is managing this view controller, to provide necessary information and initiate data fetching. */
	func setup(managedObjectContext moc:NSManagedObjectContext, patient patientValue:Patient)
	{
		// link to Core Data
		managedObjectContext = moc
		
		// create a fetch request for Operation entities under given Patient
		patient = patientValue
		let request = NSFetchRequest(entityName:"Operation")
		request.predicate = NSPredicate(format: "patient = %@", patient!)
		request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
		
		results = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
		results!.delegate = self
	}
	
	override func viewDidLoad()
	{
		// create button on top right that lets users add Operation entity
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "userPressedAdd")
		
		// set title to be shown in navigation bar
		self.title = patient!.patientID
		
		// execute fetch request
		results!.performFetch(nil)
		
		super.viewDidLoad()
	}
	
	/*	userPressedAdd fires when the user taps the corresponding bar button item, and displays an Operation editor screen modally. */
	func userPressedAdd()
	{
		// create temporary Operation entity
		let entityDescript = NSEntityDescription.entityForName("Operation", inManagedObjectContext: managedObjectContext!)!
		let newOperation = NSManagedObject(entity: entityDescript, insertIntoManagedObjectContext: nil) as! Operation
		
		// initialize, setup and present modally the operation editor
		let operationEditor = OperationEditorViewController()
		operationEditor.delegate = self
		operationEditor.operation = newOperation
		let nvc = UINavigationController(rootViewController: operationEditor)
		self.presentViewController(nvc, animated: true, completion:nil)
	}
	
	/*	userDidPressCancel is a OperationEditorViewControllerDelegate method called by the operation editor being presented modally. 
		It serves as a cue to dismiss the modal view controller. */
	func userDidPressCancel(operationEditor: OperationEditorViewController)
	{
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	/*	userDidPressDone is a OperationEditorViewControllerDelegate method called by the operation editor being presented modally.
		It serves as a cue to dismiss the modal view controller and save the information. */
	func userDidPressDone(operationEditor: OperationEditorViewController)
	{
		// insert the temporary object into the object store and save changes
		managedObjectContext!.insertObject(operationEditor.operation!)
		operationEditor.operation!.patient = patient!
		patient!.addOperations(NSSet(object: operationEditor.operation!) as Set<NSObject>)
		managedObjectContext!.save(nil)
		
		self.dismissViewControllerAnimated(true, completion: nil)
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
		// update view in case patient details changed
		self.title = patient!.patientID
		self.tableView!.reloadData()
		
        managedObjectContext!.save(nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    //	Table view data source methods
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return self.results!.fetchedObjects!.count == 0 ? 1 : 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0
        {
            return 1 // only one row in static patient information section
        }
        else
		{
            let sectionInfo = self.results!.sections![0] as! NSFetchedResultsSectionInfo
            return sectionInfo.numberOfObjects
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if indexPath.section == 0	// patient information cell
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("patientInfoCell", forIndexPath: indexPath) as! UITableViewCell
			
			// *** unelegant implementation *** << work on this
			// finding the label view whose text customze the text by iterating over each subview and checking for tag = 1
            for obj in cell.contentView.subviews
            {
                let view = obj as! UIView
                switch(view.tag)
                {
                    case 1:
                        let patientLabel = view as! UILabel
                        patientLabel.text = patient!.patientID + " . " + patient!.age.stringValue + " yrs old . " + patient!.genderString()
                        break
                    default:
                        break
                }
            }
			
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("operationCell", forIndexPath: indexPath) as! UITableViewCell
            configureCell(cell, atIndexPath:indexPath)
            return cell
        }
    }
	
	/*	configureCell is a helper function that sets the labels inside a table view cell accordingly to the Operation entity as fetched by the fetched results controller. */
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath)
    {
        cell.textLabel!.text = (self.results!.objectAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0)) as? Operation)!.dateString()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return indexPath.section == 0 ? 67 : 40
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        if indexPath.section == 0
        {
            return false
        }
        return true
    }

	//	Fetched results controller delegate methods
	//		These methods are allow the table view to update itself live, as changes are made to the object store.
	
    func controllerWillChangeContent(controller: NSFetchedResultsController)
    {
        self.tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType)
    {
        switch(type)
        {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Left)
            break
        case .Delete:
            if sectionIndex == 1
            {
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Right)
            }
            break
        default:
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?)
    {
		// index paths are from fetch controller's perspective
		// in reality, must account for static section 0 which holds patient information cell
        var fixedIndexPath: NSIndexPath?
        var fixedNewIndexPath: NSIndexPath?
		
		if indexPath != nil
        {
            fixedIndexPath = NSIndexPath(forRow: indexPath!.row, inSection: 1)
        }
        if newIndexPath != nil
        {
            fixedNewIndexPath = NSIndexPath(forRow: newIndexPath!.row, inSection: 1)
        }
		
        switch(type)
        {
            case .Insert:
                if self.results!.fetchedObjects!.count == 1
                {
                    self.tableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Left)
                }
                self.tableView.insertRowsAtIndexPaths([fixedNewIndexPath!], withRowAnimation: .Left)
                break
            case .Delete:
                if self.results!.fetchedObjects!.count == 0
                {
                    self.tableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: .Right)
                }
                self.tableView.deleteRowsAtIndexPaths([fixedIndexPath!], withRowAnimation: .Right)
                break
            case .Update:
                configureCell(tableView.cellForRowAtIndexPath(fixedIndexPath!)!, atIndexPath: fixedIndexPath!)
                break
            case .Move:
                if indexPath?.section == 1
                {
                    self.tableView.deleteRowsAtIndexPaths([fixedIndexPath!], withRowAnimation: .Right)
                    self.tableView.insertRowsAtIndexPaths([fixedNewIndexPath!], withRowAnimation: .Left)
                }
                break
            default:
                break
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController)
    {
        self.tableView.endUpdates()
    }
	
	//	Table view delegate methods
	override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
	{
		return section == 0 ? "" : "Operations"
	}
	
	/*	This function navigates the user to the next screen or displays a Patient editor depending on which cell was tapped.  */
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		if indexPath.section == 0 // Patient Information cell selected
		{
			// Initialize, setup and present modally Patient editor with current Patient
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let patientEditorNVC = storyboard.instantiateViewControllerWithIdentifier("PatientEditor") as! UINavigationController
			let patientEditor = patientEditorNVC.visibleViewController as! PatientEditorViewController
			patientEditor.patient = patient!
			patientEditor.delegate = self
			self.presentViewController(patientEditorNVC, animated: true, completion: nil)
			tableView.deselectRowAtIndexPath(indexPath, animated: false)
		}
		else if indexPath.section == 1
		{
			// Initialize, setup and show Operation editor with selected Operation (pop onto navigation controller stack)
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let operationViewer = storyboard.instantiateViewControllerWithIdentifier("OperationTableView") as! OperationTableViewController
			operationViewer.setup(managedObjectContext: managedObjectContext!, operation: self.results!.objectAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0)) as! Operation)
			self.navigationController!.showViewController(operationViewer, sender: self)
		}
	}
	
	/*	This function provides the functionality of deleting Operations by swiping on the cells in the table view. */
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
			// Fetch the corresponding Operation entity and delete from object store
			// table view will update to reflect this change automatically thanks to fetched results controller delegate methods
			
			let operation = self.results!.objectAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0)) as? Operation
			managedObjectContext!.deleteObject(operation!)
            patient!.removeOperations(NSSet(object: operation!) as Set<NSObject>)
            managedObjectContext!.save(nil)
        }
	}
}