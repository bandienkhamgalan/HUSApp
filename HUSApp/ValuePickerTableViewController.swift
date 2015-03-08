//
//  ValuePickerTableViewController.swift
//  HUSApp
//
//  Created by Bandi Enkh-Amgalan on 3/5/15.
//  Copyright (c) 2015 ucl. All rights reserved.
//

import UIKit

class ValuePickerTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate
{
    
    var prompt = ""
    var min = 0
    var initial = 50
    var max = 100
    var interval = 1
    var savedValue = 0
    
    var value: Int
    {
        get
        {
            return picker.selectedRowInComponent(0) * interval + min
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.dataSource = self
        picker.delegate = self
        if savedValue != 0 {
            picker.selectRow(savedValue, inComponent: 0, animated: false)
        } else {
            picker.selectRow(Int((initial - min) / interval), inComponent: 0, animated: false)
        }
        
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView,
        numberOfRowsInComponent component: Int) -> Int
    {
        return Int((max - min + 1) / interval)
    }
    
    func pickerView(pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int) -> String!
    {
        return String(row * interval + min)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var picker: UIPickerView!
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return prompt
    }
    
}