//
//  PatientTableViewController.swift
//  HUSApp
//
//  Created by Bandi Enkh-Amgalan on 3/4/15.
//  Copyright (c) 2015 ucl. All rights reserved.
//

import UIKit

class PatientTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, PatientEditorViewControllerDelegate, OperationEditorViewControllerDelegate {
    
    var patient: Patient?
    var results: NSFetchedResultsController?
    var managedObjectContext: NSManagedObjectContext?
    
    func userDidPressCancel(patientEditor: PatientEditorViewController)
    {
        self.tableView.reloadData()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func userDidPressDone(patientEditor: PatientEditorViewController)
    {
        managedObjectContext!.save(nil)
        self.tableView.reloadData()
        self.title = patient!.name
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func userDidPressCancel(operationEditor: OperationEditorViewController)
    {
        managedObjectContext!.deleteObject(operationEditor.operation!)
        self.tableView.reloadData()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func userDidPressDone(operationEditor: OperationEditorViewController)
    {
        patient!.addOperations(NSSet(object: operationEditor.operation!))
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
    
    func userPressedAdd()
    {
        let operationEditor = OperationEditorViewController()
        let entityDescript = NSEntityDescription.entityForName("Operation", inManagedObjectContext: managedObjectContext!)!
        let newOperation = NSManagedObject(entity: entityDescript, insertIntoManagedObjectContext: managedObjectContext!) as Operation
        newOperation.patient = patient!
        operationEditor.delegate = self
        operationEditor.operation = newOperation
        let nvc = UINavigationController(rootViewController: operationEditor)
        self.presentViewController(nvc, animated: true, completion:nil)
    }
    
    override func viewDidLoad()
    {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "userPressedAdd")
        self.title = patient!.name
        results!.performFetch(nil)
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return self.results!.fetchedObjects!.count == 0 ? 1 : 2
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if indexPath.section == 0
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let patientEditorNVC = storyboard.instantiateViewControllerWithIdentifier("PatientEditor") as UINavigationController
            let patientEditor = patientEditorNVC.visibleViewController as PatientEditorViewController
            patientEditor.patient = patient!
            patientEditor.delegate = self
            self.presentViewController(patientEditorNVC, animated: true, completion: nil)
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
        else if indexPath.section == 1
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let operationViewer = storyboard.instantiateViewControllerWithIdentifier("OperationTableView") as OperationTableViewController
            operationViewer.setup(managedObjectContext: managedObjectContext!, patient: patient!)
            operationViewer.operation = self.results!.objectAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0)) as? Operation
            self.navigationController!.showViewController(operationViewer, sender: self)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if section == 0
        {
            return 1
        }
        let sectionInfo = self.results!.sections![0] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath)
    {
        cell.textLabel!.text = (self.results!.objectAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0)) as? Operation)!.dateString()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if indexPath.section == 0
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("patientInfoCell", forIndexPath: indexPath) as UITableViewCell
            
            for obj in cell.contentView.subviews
            {
                let view = obj as UIView
                switch(view.tag)
                {
                    case 1:
                        let patientLabel = view as UILabel
                        patientLabel.text = patient!.patientID + " . " + patient!.age.stringValue + " yrs old . " + patient!.genderString()
                        break
                    default:
                        break
                }
            }
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("operationCell", forIndexPath: indexPath) as UITableViewCell
            configureCell(cell, atIndexPath:indexPath)
            return cell
        }
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return section == 0 ? "" : "Operations"
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return indexPath.section == 0 ? 67 : 40
    }

    
    func controllerWillChangeContent(controller: NSFetchedResultsController)
    {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType)
    {
        switch(type)
        {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Left)
            break
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: UITableViewRowAnimation.Right)
            break
        default:
            break
        }
    }
    

    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?)
    {
        var fixedIndexPath: NSIndexPath?
        var fixedNewIndexPath: NSIndexPath?
        if indexPath != nil
        {
            fixedIndexPath = NSIndexPath(forRow: indexPath!.row, inSection: 1)
        }
        if newIndexPath != nil
        {
            fixedNewIndexPath = NSIndexPath(forRow: newIndexPath!.row, inSection: 1)
        }
        switch(type)
        {
        case .Insert:
            if( self.results!.fetchedObjects!.count == 1 )
            {
                self.tableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Left)
            }
            
            self.tableView.insertRowsAtIndexPaths([fixedNewIndexPath!], withRowAnimation: .Left)
            break
        case .Delete:
            if( self.results!.fetchedObjects!.count == 0 )
            {
                self.tableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: .Right)
            }
            
            self.tableView.deleteRowsAtIndexPaths([fixedIndexPath!], withRowAnimation: .Right)
            break
        case .Update:
            configureCell(tableView.cellForRowAtIndexPath(fixedIndexPath!)!, atIndexPath: fixedIndexPath!)
            break
        case .Move:
            self.tableView.deleteRowsAtIndexPaths([fixedIndexPath!], withRowAnimation: .Right)
            self.tableView.insertRowsAtIndexPaths([fixedNewIndexPath!], withRowAnimation: .Left)
            break
        default:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController)
    {
        self.tableView.endUpdates()
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete
        {
            // Delete the row from the data source
            
            let operation = self.results!.objectAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0)) as? Operation
            patient!.removeOperations(NSSet(object: operation!))
            managedObjectContext!.save(nil)
        }
    }
    


}
