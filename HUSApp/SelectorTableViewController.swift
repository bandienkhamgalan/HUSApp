//
//  SelectorTableViewController.swift
//  HUSApp
//
//  Created by Bandi Enkh-Amgalan on 3/5/15.
//  Copyright (c) 2015 ucl. All rights reserved.
//

import UIKit

enum SelectorMode
{
    case Multiple
    case Single
}

protocol SingleSelectorTableViewControllerDelegate
{
    func userDidSelectChoice(sender: SelectorTableViewController)
}

class SelectorTableViewController: UITableViewController
{
    var options: [String]?
    var mode = SelectorMode.Multiple
    var selection: [String] = []
    var prompt = ""
    var delegate: SingleSelectorTableViewControllerDelegate?
    
    override func viewDidLoad()
    {
        tableView.scrollEnabled = false
        
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return options == nil ? 0 : options!.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("selectorCell", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...
        cell.textLabel!.text = options![indexPath.row]

        return cell
    }
    

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String
    {
        return prompt
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if mode == .Multiple
        {
            if cell!.accessoryType == .Checkmark
            {
                cell!.accessoryType = UITableViewCellAccessoryType.None
                cell!.textLabel!.textColor = UIColor.blackColor()
                selection.removeAtIndex(find(selection, options![indexPath.row])!)
            }
            else
            {
                cell!.accessoryType = .Checkmark
                cell!.textLabel!.textColor = UIColor(red: 69.0/255.0, green: 174.0/255.0, blue: 172.0/255.0, alpha: 1.0)
                selection.append(options![indexPath.row])
            }
        }
        else if mode == .Single
        {
            for row in 0...tableView.numberOfRowsInSection(0) - 1
            {
                var currentCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0))
                currentCell!.accessoryType = UITableViewCellAccessoryType.None
                currentCell!.textLabel!.textColor = UIColor.blackColor()
            }
            cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
            cell!.textLabel!.textColor = UIColor(red: 69.0/255.0, green: 174.0/255.0, blue: 172.0/255.0, alpha: 1.0)
            
            selection = [options![indexPath.row]]
            
            if delegate != nil
            {
                delegate!.userDidSelectChoice(self)
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        println(selection)
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
