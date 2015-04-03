//
//  DeathTableViewController.swift
//  Lung Ops
//
//  Created by Bandi Enkh-Amgalan on 3/5/15.
//  Copyright (c) 2015 ucl. All rights reserved.
//

import UIKit

class DeathTableViewController: UITableViewController
{
    @IBOutlet weak var deathSwitch: UISwitch!
    @IBOutlet weak var deathCell: UITableViewCell!
    @IBOutlet weak var deathDate: UIDatePicker!
    
    var savedDeathDate :NSDate?
    
    var death = false
    var date: NSDate?
    {
        get
        {
            return death == false ? nil : deathDate.date
        }
    }
    
    @IBAction func deathSwitchChanged(sender: UISwitch)
    {
        death = sender.on
        if death == true {
            deathCell.hidden = false
        }
        else {
            deathCell.hidden = true
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        deathCell.hidden = true
        
        // Display Date Picker if Death Date exist
        if savedDeathDate != nil {
            deathSwitch.setOn(true, animated: true)
            death = true
            deathDate.setDate(savedDeathDate!, animated: true)
            deathCell.hidden = false
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // Set Prompt to Empty String
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return " "
    }
    
}
