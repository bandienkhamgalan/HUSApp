//
//  OperationTableViewController.swift
//  HUSApp
//
//  Created by Yee Chong Tan on 06/03/2015.
//  Copyright (c) 2015 ucl. All rights reserved.
//

import UIKit

class OperationTableViewController: UITableViewController {
    
    var operation: Operation?
    
    override func viewDidLoad()
    {
        tableView.scrollEnabled = false
        
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section){
            case 0:
                return 6
            case 1:
                return operation!.complicationsArray().count
            case 2:
                return 3
            default:
                return 0
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("selectorCell", forIndexPath: indexPath) as UITableViewCell
        
        if (indexPath.section == 0){
            switch (indexPath.row){
                case 0:
                    cell.textLabel!.text = "Date of Operation"
                    break;
                case 1:
                    cell.textLabel!.text = "Type of Operation"
                    break;
                case 2:
                    cell.textLabel!.text = "Type of Resection"
                    break;
                case 3:
                    cell.textLabel!.text = "Duration of Operation"
                    break;
                case 4:
                    cell.textLabel!.text = "Blood Loss"
                    break;
                case 5:
                    cell.textLabel!.text = "Duration of Hospital Stay"
                    break;
                default:
                    break;
            
            }
        }
        
        if (indexPath.section == 1){
            var complication = operation!.complicationsArray()[indexPath.row] as String
            cell.textLabel?.text = complication
        }
        
        if (indexPath.section == 2){
            switch (indexPath.row){
            case 0:
                cell.textLabel!.text = "Admission to ICU"
                break;
            case 1:
                cell.textLabel!.text = "Follow-up Date"
                break;
            case 2:
                cell.textLabel!.text = "Death"
                break;
            default:
                break;
                
            }
        }

        return cell
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String
    {
        if (section == 1){
            return "Complications During Hospital Stay"
        }
        return " "
    }


}
