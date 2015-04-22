/**
	SelectorTableViewController.swift

	A generic form controller used by OperationEditorViewController that specializes in user selection of one or more items in a table.
*/

import UIKit

enum SelectorMode
{
    case Multiple
    case Single
}

//	Delegates receive important messages through implementing the following protocol
@objc protocol SelectorTableViewControllerDelegate
{
    func userDidUpdateChoice(sender: SelectorTableViewController)	// message after selection changes
	optional func userCanUpdateChoice(newSelection: [String], sender: SelectorTableViewController) -> Bool	// optional method of validating selection
}

class SelectorTableViewController: UITableViewController
{
	//	Styling
    let selectedColor = themeColour
    let deselectedColor = UIColor.blackColor()
	
	//	Model
    var options: [String]?
    var selection: [String] = []
	
	//	Externally configurable variables
	var mode = SelectorMode.Multiple // form can be configured to permit multiple selections or only single selection of items, multiple is default
    var prompt = ""
	
	var delegate: SelectorTableViewControllerDelegate?
	
	override func viewDidLoad()
	{
		tableView.scrollEnabled = false
		super.viewDidLoad()
	}
	
    // Table view data source methods

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return options == nil ? 0 : options!.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("selectorCell", forIndexPath: indexPath) as! UITableViewCell

        cell.textLabel!.text = options![indexPath.row]
		
		//	load pre-configured selections
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
	
	// Table view delegate methods
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
		
		//	reflect change in temporary copy of model
		var newSelection = selection
		var selectedText = options![indexPath.row]
		if mode == .Single
		{
			newSelection = [selectedText]
		}
		if mode == .Multiple
		{
			var index = find(selection, selectedText)
			if index == nil
			{
				// item was not selected: "SELECTION"
                newSelection.append(selectedText)
			}
			else
			{
				// item was selected: "DESELECTION"
                newSelection.removeAtIndex(index!)
			}
		}
		
		//	give chance for delegate to approve changes
		if delegate!.userCanUpdateChoice?(newSelection, sender: self) ?? true
		{
			// if approved, commit temporary changes
			selection = newSelection
			
			// reflect model change in view
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
                //  "deselect" all rows
				for row in 0...tableView.numberOfRowsInSection(0) - 1
				{
					var currentCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0))
					currentCell!.accessoryType = UITableViewCellAccessoryType.None
					currentCell!.textLabel!.textColor = deselectedColor
				}
                // "select" only selected row
				cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
				cell!.textLabel!.textColor = selectedColor
			}
			
			delegate?.userDidUpdateChoice(self)
		}
		
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
	
	//	The prompt/question is displayed as a section header.
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String
    {
        return prompt
    }
}
