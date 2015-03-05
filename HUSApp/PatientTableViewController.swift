//
//  PatientTableViewController.swift
//  HUSApp
//
//  Created by Bandi Enkh-Amgalan on 3/4/15.
//  Copyright (c) 2015 ucl. All rights reserved.
//

import UIKit

class PatientTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, PatientEditorViewControllerDelegate
{
    var patient: Patient?
    var results: NSFetchedResultsController?
    var managedObjectContext: NSManagedObjectContext?
    
    func userDidPressCancel(patientEditor: PatientEditorViewController)
    {
        managedObjectContext!.reset()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func userDidPressDone(patientEditor: PatientEditorViewController)
    {
        managedObjectContext!.save(nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setup(managedObjectContext moc:NSManagedObjectContext, patient patientValue:Patient)
    {
        patient = patientValue
        managedObjectContext = moc
        let request = NSFetchRequest(entityName:"Operation")
        request.predicate = NSPredicate(format: "patient = %@", patient!)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        results = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext!, sectionNameKeyPath: "year", cacheName: nil)
        results!.delegate = self
        self.title = patient!.name
    }
    
    func userPressedEdit()
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let patientEditorNVC = storyboard.instantiateViewControllerWithIdentifier("PatientEditor") as UINavigationController
        let patientEditor = patientEditorNVC.visibleViewController as PatientEditorViewController
        patientEditor.patient = patient!
        self.presentViewController(patientEditorNVC, animated: true, completion:nil)
    }
    
    override func viewDidLoad() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: "userPressedEdit")
        results!.performFetch(nil)
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return self.results!.sections!.count + 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if section == 0
        {
            return 1
        }
        let sectionInfo = self.results!.sections![section - 1] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if indexPath.section == 0
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("patientCell", forIndexPath: indexPath) as UITableViewCell
            for obj in cell.contentView.subviews
            {
                let view = obj as UIView
                println(view.tag)
                switch(view.tag)
                {
                    case 10:
                        let gender = view as UILabel
                        gender.text = patient!.genderString()
                        break
                    case 11:
                        let id = view as UILabel
                        id.text = "#" + patient!.patientID
                        break
                    case 12:
                        let age = view as UILabel
                        age.text = patient!.age.stringValue
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
            return cell
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
