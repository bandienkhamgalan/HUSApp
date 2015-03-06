//
//  DateAndTimePickerTableViewController.swift
//  HUSApp
//
//  Created by Yee Chong Tan on 05/03/2015.
//  Copyright (c) 2015 ucl. All rights reserved.
//

import UIKit

enum PickerMode
{
    case CountDownTimer
    case Date
}

class DateAndTimePickerTableViewController: UITableViewController
{
    @IBOutlet weak var datePicker: UIDatePicker!
    var pickerMode = PickerMode.Date
    var date: NSDate?
    {
        get
        {
            if pickerMode == .Date
            {
                return datePicker.date
            }
            return nil
        }
    }
    var duration: NSTimeInterval?
    {
        get
        {
            if pickerMode == .CountDownTimer
            {
                return datePicker.countDownDuration
            }
            return nil
        }
    }
    
    var prompt = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.datePickerMode = pickerMode == .Date ? .Date : .CountDownTimer
        datePicker.countDownDuration = NSTimeInterval(1800);
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return prompt
    }
    
}
