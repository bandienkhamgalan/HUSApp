//
//  DeathTableViewController.swift
//  HUSApp
//
//  Created by Bandi Enkh-Amgalan on 3/5/15.
//  Copyright (c) 2015 ucl. All rights reserved.
//

import UIKit

class DeathTableViewController: UITableViewController
{
    var death = false
    var date: NSDate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deathCell.hidden = true
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    @IBAction func deathSwitchChanged(sender: UISwitch) {
        death = sender.on
        
        if death == true {
            deathCell.hidden = false
        }
        else {
            deathCell.hidden = true
        }
        
    }
    
    @IBOutlet weak var deathCell: UITableViewCell!
    @IBOutlet weak var datePickerContainer: UIView!
    
    @IBOutlet weak var deathDate: UIDatePicker!
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "  "
    }
    
}