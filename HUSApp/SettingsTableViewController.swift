//
//  SettingsTableViewController.swift
//  HUSApp
//
//  Created by Bandi Enkh-Amgalan on 3/11/15.
//  Copyright (c) 2015 ucl. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    var themeColour = UIColor(red: 69.0/255.0, green: 174.0/255.0, blue: 172.0/255.0, alpha: 1.0)
    
    func done(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet var infoDropbox: UITableViewCell!
    @IBOutlet var actionDropbox: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var doneButton : UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "done")
        doneButton.tintColor = themeColour
        self.navigationItem.rightBarButtonItem = doneButton
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: themeColour]
        
        updateView()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateView(){
        if DBAccountManager.sharedManager().linkedAccount != nil {
            actionDropbox.textLabel?.text = "Sign Out from Dropbox"
            actionDropbox.textLabel?.textColor = UIColor.redColor()
            infoDropbox.detailTextLabel?.text = DBAccountManager.sharedManager().linkedAccount.info.userName
            
        } else {
            actionDropbox.textLabel?.text = "Link with Dropbox"
            actionDropbox.textLabel?.textColor = themeColour
            infoDropbox.detailTextLabel?.text = "Not Available"
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 && DBAccountManager.sharedManager().linkedAccount != nil {
            DBAccountManager.sharedManager().linkedAccount.unlink()
        } else if indexPath.section == 1 {
            DBAccountManager.sharedManager().linkFromController(self)
        }
        
        updateView()
    }

}
