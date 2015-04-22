/**
	SettingsTableViewController.swift

	A static grouped table view controller that acts as the settings screen for the application i.e. link/unlink their Dropbox. 
*/

import UIKit
import Foundation

protocol SettingsViewControllerDelegate
{
    func userDidPressDone(settings: SettingsTableViewController)
}

class SettingsTableViewController: UITableViewController
{
    @IBOutlet var infoDropbox: UITableViewCell!
    @IBOutlet var actionDropbox: UITableViewCell!
    
    var delegate: SettingsViewControllerDelegate?
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: themeColour]
		
		// create and setup Done button in top right
		var doneButton : UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "done")
		doneButton.tintColor = themeColour
		self.navigationItem.rightBarButtonItem = doneButton
		
		// Observe for internal notification on successful Dropbox link
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "dbSuccess", name: "dropbox", object: nil)
		
		updateView()
	}
	
	/* updateView sets the titles and labels shown in the cells of the table view to correctly reflect state of Dropbox. */
	func updateView()
	{
		if DBAccountManager.sharedManager().linkedAccount != nil
		{
			actionDropbox.textLabel?.text = "Sign Out from Dropbox"
			actionDropbox.textLabel?.textColor = UIColor.redColor()
			infoDropbox.detailTextLabel?.text = DBAccountManager.sharedManager().linkedAccount.info?.userName
			
		}
		else
		{
			actionDropbox.textLabel?.text = "Link with Dropbox"
			actionDropbox.textLabel?.textColor = themeColour
			infoDropbox.detailTextLabel?.text = "Not Available"
		}
	}
	
	/* done fires when the user presses the Done bar button item, and passes the message along to the delegate */
    func done()
	{
        delegate?.userDidPressDone(self)
    }
	
	/*	dbSuccess fires when the internal notification that Dropbox has been linked gets posted. */
    func dbSuccess()
    {
        // PKNotification library is used here to display a small non-obstrusive visual in the center of screen
        println(DBAccountManager.sharedManager().linkedAccount)
        PKNotification.successBackgroundColor = themeColour
        PKNotification.success("Linked!")
		
		// close the settings pane upon link
        done()
    }
	
	// Table view delegate methods 
	
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if indexPath.section == 1 && DBAccountManager.sharedManager().linkedAccount != nil
        {
            DBAccountManager.sharedManager().linkedAccount.unlink()
            println("App unlinked from Dropbox!")
        }
        else if indexPath.section == 1
        {
            DBAccountManager.sharedManager().linkFromController(self)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        updateView()
    }

}
