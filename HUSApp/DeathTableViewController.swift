/**
	DeathTableViewController.swift

	A specialized form controller used by OperationEditorViewController for inputting a person's alive/dead status through a switch control.
	If the switch is enabled, a second date field is shown for entering the date and time of death.
*/

import UIKit

class DeathTableViewController: UITableViewController
{
    @IBOutlet weak var deathSwitch: UISwitch!
    @IBOutlet weak var deathCell: UITableViewCell!
    @IBOutlet weak var deathDate: UIDatePicker!
	
	//	Externally configurable variables
    var savedDeathDate :NSDate?
	
	//	Model
    var death = false
    var date: NSDate?
    {
        get
        {
            return death == false ? nil : deathDate.date
        }
    }
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		deathCell.hidden = true
		
		// load pre-configured variables
		if savedDeathDate != nil
		{
			// if saved death date has been set, "Death" should be enabled
			death = true
			deathSwitch.setOn(true, animated: true)
			
			// show death date picker and load saved date
			deathCell.hidden = false
			deathDate.setDate(savedDeathDate!, animated: true)
		}
	}
	
	//	deathSwitchChanged is called when the user interacts with the "Death" switch control
    @IBAction func deathSwitchChanged(sender: UISwitch)
    {
        death = sender.on
		
		// if "Death" switch is enabled, show death date picker
        if death == true
		{
            deathCell.hidden = false
        }
        else
		{
            deathCell.hidden = true
        }
    }
    
    //	Table view delegate methods
	//		this form view does not have a prompt/title, but a space is returned as header to maintain consistency in header height
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return " "
    }
}
