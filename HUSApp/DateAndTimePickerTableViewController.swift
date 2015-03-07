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
    var savedDate: NSDate = NSDate()
    var savedCountdown :NSTimeInterval = NSTimeInterval(1800)
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
        
        if savedDate != NSDate() {
            datePicker.setDate(savedDate, animated: true)
        }
        if savedCountdown != NSTimeInterval(1800){
            datePicker.countDownDuration = savedCountdown
        } else {
            datePicker.countDownDuration = NSTimeInterval(1800);
        }
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

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
