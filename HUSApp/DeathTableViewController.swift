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
    var savedDeathDate :NSDate?
    
    var death = false
    var date: NSDate?
    {
        get
        {
            return death == false ? nil : deathDate.date
        }
    }
    
    @IBOutlet weak var deathSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deathCell.hidden = true
        
        if savedDeathDate != nil {
            deathSwitch.setOn(true, animated: true)
            death = true
            deathDate.setDate(savedDeathDate!, animated: true)
            deathCell.hidden = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    @IBOutlet weak var deathDate: UIDatePicker!
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return " "
    }
    
}