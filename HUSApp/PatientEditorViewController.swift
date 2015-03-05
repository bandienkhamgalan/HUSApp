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
        
        nameField.delegate = self
        idField.delegate = self
        ageField.delegate = self
        doneButton.enabled = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        switch(textField)
        {
            case nameField:
                name = textField.text
                break
            case idField:
                patientID = textField.text
                break
            case ageField:
                let processedAge = NSNumberFormatter().numberFromString(textField.text)
                if processedAge != nil
                {
                    age = processedAge!.integerValue
                }
                else
                {
                    age = -1
                }
                break
            default:
                break
        }
        tryToEnableDoneButton();
        return true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
