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

@objc protocol SelectorTableViewControllerDelegate
{
    func userDidUpdateChoice(sender: SelectorTableViewController)
	optional func userCanUpdateChoice(newSelection: [String], sender: SelectorTableViewController) -> Bool
}

class SelectorTableViewController: UITableViewController
{
    var selectedColor = UIColor(red: 69.0/255.0, green: 174.0/255.0, blue: 172.0/255.0, alpha: 1.0)
    var deselectedColor = UIColor.blackColor()
    var options: [String]?
    var mode = SelectorMode.Multiple
    var selection: [String] = []
    var prompt = ""
    
    var delegate: SelectorTableViewControllerDelegate?
    
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

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return options == nil ? 0 : options!.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("selectorCell", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...
        cell.textLabel!.text = options![indexPath.row]
        
        if contains(selection, options![indexPath.row])
        {
            cell.accessoryType = .Checkmark
            cell.textLabel!.textColor = selectedColor
        }
        else
        {
            cell.accessoryType = .None
            cell.textLabel!.textColor = deselectedColor
        }

        return cell
    }
    

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String
    {
        return prompt
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
		var newSelection = selection
		// buffer changes to model
		var selectedText = options![indexPath.row]
		if mode == .Single
		{
			newSelection = [selectedText]
		}
		else
		{
			var index = find(selection, selectedText)
			if index == nil // doesn't exist, "SELECTION"
			{
				newSelection.append(selectedText)
			}
			else			// exists, "DESELECTION"
			{
				newSelection.removeAtIndex(index!)
			}
		}
		
		// check with delegate
		if delegate!.userCanUpdateChoice?(newSelection, sender: self) ?? true
		{
			selection = newSelection
			
			// if allowed, proceed with changes to UI
			if mode == .Multiple
			{
				if cell!.accessoryType == .Checkmark
				{
					cell!.accessoryType = UITableViewCellAccessoryType.None
					cell!.textLabel!.textColor = UIColor.blackColor()
				}
				else
				{
					cell!.accessoryType = .Checkmark
					cell!.textLabel!.textColor = selectedColor
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
				cell!.textLabel!.textColor = selectedColor
			}
			
			if delegate != nil
			{
				delegate!.userDidUpdateChoice(self)
			}
		}
		
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
	

}
