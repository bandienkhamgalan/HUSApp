/**
	PatientEditorViewController.swift

	A custom view controller with a form-like interface whereby the user enters/updates information for a Patient entity. 
	
	Note: this view controller currently initiates the Dropbox link process if the user hasn't linked yet, because this is
	the earliest point when exporting functionality may be needed. Therefore, this class contains some Dropbox API calls.
	However, all Dropbox logic should be moved away for better code structure.
*/

import UIKit

//	Delegates receive important messages from this class and need to implement this protocol
protocol PatientEditorViewControllerDelegate
{
    func userDidPressDoneInPatientEditor(patientEditor: PatientEditorViewController)
    func userDidPressCancelInPatientEditor(patientEditor: PatientEditorViewController)
}

enum Gender: Int
{
    case male = 0
    case female
}

class PatientEditorViewController: UIViewController, UITextFieldDelegate
{
    // Temporary data variables to hold input until user presses Save
    var patientID = ""
    var age = -1
    var gender = -1
	
	var patient: Patient?
	
	var delegate: PatientEditorViewControllerDelegate?
	
    @IBOutlet weak var idField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var genderPicker: UISegmentedControl!
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		// Dropbox linking
		linkDropbox()
		
		// Enable feature where tapping outside a form field removes focus/resigns first responder
		self.view!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "resignAllTextFieldsFirstResponders"))
		
		// If not a new patient, load existing information into UI and data variables
		if(patient!.patientID != nil)
		{
			self.title = "Editing \(patient!.patientID)"
			idField.text = patient!.patientID	// UI
			patientID = patient!.patientID		// data
		}
		if(patient!.age != nil)
		{
			ageField.text = patient!.ageString()	// UI
			age = patient!.age.integerValue			// data
		}
		if(patient!.gender != nil)
		{
			gender = patient!.gender.integerValue		// data
			genderPicker.selectedSegmentIndex = gender	// UI
		}
		tryToEnableDoneButton()
		
		// register as text field delegates
		idField.delegate = self
		ageField.delegate = self
	}
	
	/*	The Done button remains disabled by default until all form fields have been filled correctly.
	tryToEnableDoneButton is called after every user input to check if all fields have been filled, and if so, enable the Done button. */
	func tryToEnableDoneButton()
	{
		if age > -1 && gender > -1 && patientID != ""
		{
			doneButton.enabled = true
		}
		else
		{
			doneButton.enabled = false
		}
	}
	
	/*	cancel is set to fire when the user presses the Cancel bar button item, and sends the appropriate message to delegate. */
    @IBAction func cancel(sender: UIBarButtonItem)
    {
		// dismiss
        delegate?.userDidPressCancelInPatientEditor(self)
    }
	
	/*	done is set to fire when the user presses the Done bar button item, commits user's changes and sends the appropriate message to delegate. */
    @IBAction func done(sender: UIBarButtonItem)
    {
        patient!.patientID = patientID
        patient!.age = age
        patient!.gender = gender
		
        delegate?.userDidPressDoneInPatientEditor(self)
    }
	
	/* genderPicked is set to fire when the user makes a selection in the gender picker segmented control, and updates the temporary gender variable. */
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
	
	/*	linkDropbox checks if the user has linked a Dropbox account already, and if not, prompt the user to do so. */
    func linkDropbox()
	{
        var account = DBAccountManager.sharedManager().linkedAccount
        if account == nil
		{
			// Start linking process if Dropbox account not linked
            DBAccountManager.sharedManager().linkFromController(self)
        }
		
		// Observe for internal notification on successful Dropbox link
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "dbSuccess", name: "dropbox", object: nil)
    }
    
	/*	dbSuccess fires when the internal notification that Dropbox has been linked gets posted. */
	func dbSuccess()
	{
		// PKNotification library is used here to display a small non-obstrusive visual in the center of screen
		println(DBAccountManager.sharedManager().linkedAccount)
		PKNotification.successBackgroundColor = themeColour
		PKNotification.success("Linked!")
    }
	
	/*	resignAllTextFieldsFirstResponders resigns all form fields from first responder status a.k.a removes focus. 
		It is being used in conjunction with tap gesture recognizer. */
    func resignAllTextFieldsFirstResponders()
    {
        idField.resignFirstResponder()
        ageField.resignFirstResponder()
    }
	
	/*	text field delegate method that performs input validation and saves to temporary data variables. */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
		// compute the "new"/changed string and remove any leading or trailing whitespace
        var newString = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
		
		var shouldChange = false
        switch(textField)
        {
            case idField:
                patientID = newString
				shouldChange = true
                break
            case ageField:
                var processedAge = NSNumberFormatter().numberFromString(newString)
                if processedAge != nil																// do not allow non-numbers
                {
                    if newString.rangeOfString(".", options: nil, range: nil, locale: nil) == nil	// do not allow decimals (contains periods)
                    {
                        age = processedAge!.integerValue
						shouldChange = true
                    }
                }
                else if count(newString) == 0
                {
                    age = -1
                    shouldChange = true
                }
                break
            default:
                break
        }
		
        tryToEnableDoneButton();
        return shouldChange
    }
}
