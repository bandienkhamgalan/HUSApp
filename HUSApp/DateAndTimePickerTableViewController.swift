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
    var savedDate: NSDate?
    var savedCountdown :NSTimeInterval?
    
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
        
        if pickerMode == .Date {
            if savedDate != nil {
                datePicker.setDate(savedDate!, animated: true)
            } else {
                datePicker.setDate(NSDate(), animated: true)
            }
        } else {
            if savedCountdown != nil {
                datePicker.countDownDuration = savedCountdown!
            } else {
                datePicker.countDownDuration = NSTimeInterval(1800);
            }
        }

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
