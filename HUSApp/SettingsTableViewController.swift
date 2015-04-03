//
//  SettingsTableViewController.swift
//  Lung Ops
//
//  Created by Bandi Enkh-Amgalan on 3/11/15.
//  Copyright (c) 2015 ucl. All rights reserved.
//

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
    
    func done()
	{
        if delegate != nil
        {
            delegate!.userDidPressDone(self)
        }
    }
    
    func dbSuccess()
    {
        // Display green tick alert when Dropbox is linked successfully.
        println(DBAccountManager.sharedManager().linkedAccount)
        PKNotification.successBackgroundColor = themeColour
        PKNotification.success("Linked!")
        done()
    }
    
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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        var doneButton : UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "done")
        doneButton.tintColor = themeColour
        
        self.navigationItem.rightBarButtonItem = doneButton
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: themeColour]
        
        // Observe for Dropbox successfully linked
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dbSuccess", name: "dropbox", object: nil)
        
        updateView()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
}
