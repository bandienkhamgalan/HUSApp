//
//  SelectorTableViewController.swift
//  Lung Ops
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
    let selectedColor = UIColor(red: 69.0/255.0, green: 174.0/255.0, blue: 172.0/255.0, alpha: 1.0)
    let deselectedColor = UIColor.blackColor()
    
    var options: [String]?
    var mode = SelectorMode.Multiple
    var selection: [String] = []
    var prompt = ""
    var delegate: SelectorTableViewControllerDelegate?
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // Return the number of rows in the section.
        return options == nil ? 0 : options!.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("selectorCell", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell.
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
		var newSelection = selection
        
		// Buffer change to Model.
		var selectedText = options![indexPath.row]
        
		if mode == .Single
		{
			newSelection = [selectedText]
		}
		else
		{
			var index = find(selection, selectedText)
			if index == nil
			{
				// Selected Option doesn't exist, "SELECTION"
                newSelection.append(selectedText)
			}
			else
			{
				// Selected Option exists, "DESELECTION"
                newSelection.removeAtIndex(index!)
			}
		}
		
		if delegate!.userCanUpdateChoice?(newSelection, sender: self) ?? true
		{
			selection = newSelection
			
			// If User can update choice, proceed with changes to UI.
			if mode == .Multiple
			{
				if cell!.accessoryType == .Checkmark
				{
					cell!.accessoryType = UITableViewCellAccessoryType.None
					cell!.textLabel!.textColor = deselectedColor
				}
				else
				{
					cell!.accessoryType = .Checkmark
					cell!.textLabel!.textColor = selectedColor
				}
			}
			else if mode == .Single
			{
                //  Remove all Styling from all Rows.
				for row in 0...tableView.numberOfRowsInSection(0) - 1
				{
					var currentCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0))
					currentCell!.accessoryType = UITableViewCellAccessoryType.None
					currentCell!.textLabel!.textColor = deselectedColor
				}
                // Style selected Row with checkmark and color.
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
	
    
    override func viewDidLoad()
    {
        tableView.scrollEnabled = false
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String
    {
        return prompt
    }
}
