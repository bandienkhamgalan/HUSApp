//
//  OperationTableViewController.swift
//  HUSApp
//
//  Created by Yee Chong Tan on 06/03/2015.
//  Copyright (c) 2015 ucl. All rights reserved.
//

import UIKit

class OperationTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, OperationEditorViewControllerDelegate {
    
    var operation: Operation?
    var patient: Patient?
    var results: NSFetchedResultsController?
    var managedObjectContext: NSManagedObjectContext?
    
    func userDidPressCancel(operationEditor: OperationEditorViewController)
    {
        self.tableView.reloadData()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func userDidPressDone(operationEditor: OperationEditorViewController)
    {
        self.operation = operationEditor.operation!
        managedObjectContext!.save(nil)
        self.tableView.reloadData()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setup(managedObjectContext moc:NSManagedObjectContext, patient patientValue:Patient)
    {
        patient = patientValue
        managedObjectContext = moc
        let request = NSFetchRequest(entityName:"Operation")
        request.predicate = NSPredicate(format: "patient = %@", patient!)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        results = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        results!.delegate = self
    }
    
    func userPressedEdit()
    {
        let operationEditor = OperationEditorViewController()
        operationEditor.operation = operation
        operationEditor.delegate = self
        let nvc = UINavigationController(rootViewController: operationEditor)
        self.presentViewController(nvc, animated: true, completion:nil)
    }
    
    override func viewDidLoad()
    {        
        super.viewDidLoad()
        self.title = "Operation"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "userPressedEdit")
   
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
                return 7
            case 1:
                return operation!.complicationsArray().count
            case 2:
                return 2
            default:
                return 0
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("operationViewerCell", forIndexPath: indexPath) as UITableViewCell
        
        if (indexPath.section == 0){
            switch (indexPath.row){
                
            case 0:
                    cell.textLabel!.text = "Date of Operation"
                    cell.detailTextLabel!.text = operation!.dateString()
                    break;
                case 1:
                    cell.textLabel!.text = "Type of Operation"
                    cell.detailTextLabel!.text = operation!.approachString()
                    break;
                case 2:
                    cell.textLabel!.text = "Type of Resection"
                    cell.detailTextLabel!.text = operation!.resectionString()
                    break;
                case 3:
                    cell.textLabel!.text = "Duration of Operation"
                    cell.detailTextLabel!.text = operation!.durationString()
                    break;
                case 4:
                    cell.textLabel!.text = "Blood Loss"
                    cell.detailTextLabel!.text = "\(operation!.bloodLoss) mL"
                    break;
                case 5:
                    cell.textLabel!.text = "Admission to ICU"
                    if (operation!.admittedToICU == 1){
                        cell.detailTextLabel!.text = "Yes"
                    }
                    else {
                        cell.detailTextLabel!.text = "No"
                    }
                    break;
                case 6:
                    cell.textLabel!.text = "Duration of Hospital Stay"
                    cell.detailTextLabel!.text = "\(operation!.durationOfStay) days"
                    break;
                default:
                    break;
            
            }
        }
    
        
        if (indexPath.section == 1){
            var complication = operation!.complicationsArray()[indexPath.row] as String
            cell.textLabel!.text = complication
            cell.detailTextLabel!.text = " "
        }
        
        if (indexPath.section == 2){
            
            switch (indexPath.row){

            case 0:
                if (operation!.alive == 1) {
                    cell.textLabel!.text = "Follow-up Date"
                    cell.detailTextLabel!.text = operation!.followUpDateString()
                }
                if (operation!.alive == 0) {
                    cell.textLabel!.text = "Follow-up Date"
                    cell.detailTextLabel!.text = "NA"
                }
                break;
            case 1:
                if (operation!.alive == 1) {
                    cell.textLabel!.text = "Alive"
                    cell.detailTextLabel!.text = "Yes"
                }
                else {
                    cell.textLabel!.text = "Death Date"
                    cell.detailTextLabel!.text = operation!.deathDateString()
                }
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
        return ""
    }


}