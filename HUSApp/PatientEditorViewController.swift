//
//  PatientEditorViewController.swift
//  HUSApp
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
    var name = ""
    var patientID = ""
    var age = -1
    var gender = -1
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBAction func cancel(sender: UIBarButtonItem)
    {
        if delegate != nil
        {
            delegate!.userDidPressCancel(self)
        }
    }
    
    @IBAction func done(sender: UIBarButtonItem)
    {
        patient!.name = name
        patient!.patientID = patientID
        patient!.age = age
        patient!.gender = gender
        if delegate != nil
        {
            delegate!.userDidPressDone(self)
        }
    }
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var idField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    
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
        if countElements(name) > 0 && age > -1 && gender > -1
        {
            doneButton.enabled = true
        }
        else
        {
            doneButton.enabled = false
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
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
            // existing patient -> load information
            if(patient!.name != nil)
            {
                nameField.text = patient!.name
                self.title = "Editing \(patient!.name)"
                name = patient!.name
            }
            if(patient!.patientID != nil)
            {
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
            
            nameField.delegate = self
            idField.delegate = self
            ageField.delegate = self
        }
        tryToEnableDoneButton()
        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var genderPicker: UISegmentedControl!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func resignAllTextFieldsFirstResponders()
    {
        nameField.resignFirstResponder()
        idField.resignFirstResponder()
        ageField.resignFirstResponder()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        var newString = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string)
        switch(textField)
        {
            case nameField:
                name = newString
                break
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

}
