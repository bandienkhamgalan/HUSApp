/**
	DateAndTimePickerTableViewController.swift

	A generic form controller used by OperationEditorViewController that specializes in user input of either dates or duration through a scrollable picker.
*/

import UIKit

enum PickerMode
{
    case CountDownTimer
    case Date
}

class DateAndTimePickerTableViewController: UITableViewController
{
    @IBOutlet weak var datePicker: UIDatePicker!
	
	//	A class using DateAndTimePicker sets the mode of the input (either time or duration) with pickerMode
    var pickerMode = PickerMode.Date
	
	//	Externally configurable variables
    var savedDate: NSDate?
    var savedCountdown :NSTimeInterval?
    var prompt = ""
	
	//	Computed property that returns current selection (for date mode)
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
	
	//	Computed property that returns current duration (for duration mode)
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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        datePicker.datePickerMode = pickerMode == .Date ? .Date : .CountDownTimer
		
		//	if a saved value is set, load that value into UI
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

	//	Table view delegate methods
	//		The prompt/question is displayed as a section header.
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return prompt
    }
}