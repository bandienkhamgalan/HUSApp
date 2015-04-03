//
//  TextFieldInputTableViewController.swift
//  Lung Ops
//
//  Created by Yee Chong Tan on 16/03/2015.
//  Copyright (c) 2015 ucl. All rights reserved.
//

import UIKit

protocol TextFieldInputTableViewControllerDelegate
{
    func userDidChangeText(sender: TextFieldInputTableViewController)
}

class TextFieldInputTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    
    var prompt = ""
    var delegate: TextFieldInputTableViewControllerDelegate?
    
    var savedValue: Int?
    var value: Int
    {
        get
        {
            return countElements(textField.text) == 0 ? -1 :
                (NSNumberFormatter().numberFromString(textField.text)! as NSNumber).integerValue
        }
        set
        {
            if textField != nil
            {
                textField.text = NSNumberFormatter().stringFromNumber(NSNumber(integer: newValue))
            }
        }
    }
    
    func resignTextFieldFirstResponder()
    {
        textField.resignFirstResponder()
    }
    
    override func becomeFirstResponder() -> Bool
    {
        return textField.becomeFirstResponder()
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        var newString = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        if NSNumberFormatter().numberFromString(newString) != nil || countElements(newString) == 0
        {
            if delegate != nil
            {
                delegate!.userDidChangeText(self)
            }
            return true
        }
        else
        {
            return false
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "resignTextFieldFirstResponder"))
        textField.delegate = self
        
        if savedValue != nil
        {
            value = savedValue!
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return prompt
    }

}
