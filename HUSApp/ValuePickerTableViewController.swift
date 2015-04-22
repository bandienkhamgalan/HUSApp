/**
	ValuePickerTableViewController.swift

	A generic form controller used by OperationEditorViewController that specializes in user input of numbers using a scrollable picker.
*/

import UIKit

class ValuePickerTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate
{
    @IBOutlet weak var picker: UIPickerView!
	
	//	Externally configurable variables
    var prompt = ""
    var min = 0
    var initial = 50
    var max = 100
    var interval = 1
    var savedValue = 0
	
	//	Computed property that returns currently selected integer
    var value: Int
    {
        get
        {
            return picker.selectedRowInComponent(0) * interval + min
        }
    }
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		picker.dataSource = self
		picker.delegate = self
		
		// load pre-configured value, if set
		if savedValue != 0
		{
			picker.selectRow(savedValue, inComponent: 0, animated: false)
		}
		else
		{
			picker.selectRow(Int((initial - min) / interval), inComponent: 0, animated: false)
		}
	}
	
	//	Picker view data source methods
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return Int((max - min + 1) / interval)
    }
	
	//	Picker view delegate methods
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String!
    {
        return String(row * interval + min)
    }
	
	//	Table view delegate methods
	//		The prompt/question is displayed as a section header.
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return prompt
    }
    
}
