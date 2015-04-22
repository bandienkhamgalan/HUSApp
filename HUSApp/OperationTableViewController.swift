/**
	OperationTableViewController.swift

	A grouped table view controller that displays information for a single Operation entity in a structured format. 
*/

import UIKit

class OperationTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, OperationEditorViewControllerDelegate
{
    var operation: Operation?
    var managedObjectContext: NSManagedObjectContext?
	
	/*	This function must be called by whichever class is managing this view controller, to provide necessary information. */
	func setup(managedObjectContext moc:NSManagedObjectContext, operation operationValue:Operation)
	{
		// establish Core Data link
		managedObjectContext = moc
		
		operation = operationValue
	}
	
	/*	userDidPressCancel is a OperationEditorViewControllerDelegate method called by the operation editor being presented modally.
		It serves as a cue to dismiss the modal view controller. */
    func userDidPressCancel(operationEditor: OperationEditorViewController)
    {
        self.tableView.reloadData()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
	
	/*	userDidPressCancel is a OperationEditorViewControllerDelegate method called by the operation editor being presented modally.
		It serves as a cue to dismiss the modal view controller and the information. */
    func userDidPressDone(operationEditor: OperationEditorViewController)
    {
		managedObjectContext!.save(nil)
		
		// reflect changes in table view
        self.tableView.reloadData()
		
        self.dismissViewControllerAnimated(true, completion: nil)
    }
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		self.title = operation!.dateString()
		
		// create "Edit" button in navigation bar
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "userPressedEdit")
	}
	
	/*	This function fires when the user taps the right bar button item to edit the operation. */
    func userPressedEdit()
    {
		// initialize, setup and present modally an operation editor view controller
        let operationEditor = OperationEditorViewController()
        operationEditor.operation = operation
        operationEditor.delegate = self
        let nvc = UINavigationController(rootViewController: operationEditor)
        self.presentViewController(nvc, animated: true, completion:nil)
    }
    
    //	Table view data source methods
	
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch(section)
		{
            case 0:
                return 9
            case 1:
                return operation!.complicationsArray().count
            case 2:
                return 2
            default:
                return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("operationViewerCell", forIndexPath: indexPath) as! UITableViewCell
		
		// General Information about Operation
        if (indexPath.section == 0)
		{
            switch (indexPath.row)
			{
                case 0:
                    cell.textLabel!.text = "Date of Operation"
                    cell.detailTextLabel!.text = operation!.dateString()
                    break;
                case 1:
                    cell.textLabel!.text = "Type of Operation"
                    cell.detailTextLabel!.text = operation!.approachString()
                    break;
                case 2:
                    cell.textLabel!.text = "Type of Resection"
					
					// enable multiple lines in cell
					cell.detailTextLabel!.numberOfLines = 0
					cell.detailTextLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping
					
					// prepare a potential multi-line string in the case that the operation is multiple "resection" types
					var text = ""
					for obj in operation!.resectionsArray()
					{
						text += (obj as! String) + "\n"
					}
					
					// remove last '\n' character (side-effect of above algorihtm)
					text = (text as NSString).substringToIndex(max(0, count(text) - 1))
					
					cell.detailTextLabel!.text = text
                    break;
                case 3:
                    cell.textLabel!.text = "Duration of Operation"
                    cell.detailTextLabel!.text = operation!.durationString()
                    break;
                case 4:
                    cell.textLabel!.text = "FEV1"
                    cell.detailTextLabel!.text = "\(operation!.fev1) %"
                    break;
                case 5:
                    cell.textLabel!.text = "DLCO"
                    cell.detailTextLabel!.text = "\(operation!.dlco) %"
                    break;
                case 6:
                    cell.textLabel!.text = "Blood Loss"
                    cell.detailTextLabel!.text = "\(operation!.bloodLoss) mL"
                    break;
                case 7:
                    cell.textLabel!.text = "Admission to ICU"
                    if (operation!.admittedToICU == 1){
                        cell.detailTextLabel!.text = "Yes"
                    }
                    else {
                        cell.detailTextLabel!.text = "No"
                    }
                    break;
                case 8:
                    cell.textLabel!.text = "Duration of Hospital Stay"
                    cell.detailTextLabel!.text = "\(operation!.durationOfStay) days"
                    break;
                default:
                    break;
            }
        }
		
		// Section that lists complications as rows
        if (indexPath.section == 1)
		{
            var complication = operation!.complicationsArray()[indexPath.row] as! String
            cell.textLabel!.text = complication
            cell.detailTextLabel!.text = " "
        }
		
		// Section that lists follow-up date and status (alive/deceased)
        if (indexPath.section == 2)
		{
            switch (indexPath.row)
			{
				case 0:
					if (operation!.alive == 1) {
						cell.textLabel!.text = "Follow-up Date"
						cell.detailTextLabel!.text = operation!.followUpDateString()
					}
					if (operation!.alive == 0) {
						cell.textLabel!.text = "Follow-up Date"
						cell.detailTextLabel!.text = "NA"
					}
					break;
				case 1:
					if (operation!.alive == 1) {
						cell.textLabel!.text = "Alive"
						cell.detailTextLabel!.text = "Yes"
					}
					else {
						cell.textLabel!.text = "Death Date"
						cell.detailTextLabel!.text = operation!.deathDateString()
					}
					break;
				default:
					break;
            }
        }
        return cell
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.title = "Operation"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "userPressedEdit")
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String
    {
		// only Complications section has a header
        return section == 1 && operation!.complicationsArray().count > 0 ? "Complications During Hospital Stay" : ""
    }
}
