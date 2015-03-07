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
            cell.textLabel!.text = (self.results!.objectAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0)) as? Operation)!.dateString()
            return cell
        }
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
            operationViewer.operation = self.results!.objectAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0)) as? Operation
            self.navigationController!.showViewController(operationViewer, sender: self)
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

}
