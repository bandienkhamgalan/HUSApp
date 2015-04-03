//
//  PatientEditorViewController.swift
//  Lung Ops
//
//  Created by Bandi Enkh-Amgalan on 3/4/15.
//  Copyright (c) 2015 ucl. All rights reserved.
//

import UIKit

protocol PatientEditorViewControllerDelegate
{
    func userDidPressDone(patientEditor: PatientEditorViewController)
    func userDidPressCancel(patientEditor: PatientEditorViewController)
}

enum Gender: Int
{
    case male = 0
    case female
}

class PatientEditorViewController: UIViewController, UITextFieldDelegate
{
    var patient: Patient?
    var delegate: PatientEditorViewControllerDelegate?
    var patientID = ""
    var age = -1
    var gender = -1
    
    @IBOutlet weak var idField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var genderPicker: UISegmentedControl!
    
    @IBAction func cancel(sender: UIBarButtonItem)
    {
        if delegate != nil
        {
            delegate!.userDidPressCancel(self)
        }
    }
    
    @IBAction func done(sender: UIBarButtonItem)
    {
        patient!.patientID = patientID
        patient!.age = age
        patient!.gender = gender
        if delegate != nil
        {
            delegate!.userDidPressDone(self)
        }
    }
    
    @IBAction func genderPicked(sender: UISegmentedControl)
    {
        resignAllTextFieldsFirstResponders()
        switch(sender.selectedSegmentIndex)
        {
            case 0:
                gender = Gender.male.rawValue
                break
            case 1:
                gender = Gender.female.rawValue
                break
            default:
                break
        }
        tryToEnableDoneButton();
    }
    
    func tryToEnableDoneButton()
    {
        // Validate Age, Gender and Patient ID.
        if age > -1 && gender > -1 && patientID != ""
        {
            doneButton.enabled = true
        }
        else
        {
            doneButton.enabled = false
        }
    }
    
    func tryLinkDropbox()
	{
        // Check if a Dropbox account has been linked.
        var account = DBAccountManager.sharedManager().linkedAccount
        if account == nil {
            DBAccountManager.sharedManager().linkFromController(self)
        }
    }
    
    func dbSuccess()
    {
        // Display green tick alert when Dropbox is linked successfully.
        println(DBAccountManager.sharedManager().linkedAccount)
        PKNotification.successBackgroundColor = themeColour
        PKNotification.success("Linked!")
    }
    
    func resignAllTextFieldsFirstResponders()
    {
        idField.resignFirstResponder()
        ageField.resignFirstResponder()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        var newString = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        switch(textField)
        {
            case idField:
                patientID = newString
                break
            case ageField:
                var processedAge = NSNumberFormatter().numberFromString(newString)
                if processedAge != nil
                {
                    if newString.rangeOfString(".", options: nil, range: nil, locale: nil) == nil
                    {
                        age = processedAge!.integerValue
                    }
                    else
                    {
                        return false
                    }
                }
                else if countElements(newString) == 0
                {
                    age = -1
                    return true
                }
                else
                {
                    return false
                }
                break
            default:
                break
        }
        tryToEnableDoneButton();
        return true
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Observe if Dropbox successfully linked.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dbSuccess", name: "dropbox", object: nil)
        
        // Check if a Dropbox account has been linked.
        tryLinkDropbox()
        
        if patient == nil
        {
            if delegate != nil
            {
                delegate!.userDidPressCancel(self)
            }
        }
        else
        {
            self.view!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "resignAllTextFieldsFirstResponders"))
            
            // If there is existing patient, load information.
            if(patient!.patientID != nil)
            {
                self.title = "Editing \(patient!.patientID)"
                idField.text = patient!.patientID
                patientID = patient!.patientID
            }
            if(patient!.age != nil)
            {
                ageField.text = patient!.ageString()
                age = patient!.age.integerValue
            }
            if(patient!.gender != nil)
            {
                gender = patient!.gender.integerValue
                genderPicker.selectedSegmentIndex = gender
            }
            
            idField.delegate = self
            ageField.delegate = self
        }
        
        // Validate Age, Gender and Patient ID.
        tryToEnableDoneButton()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

}
