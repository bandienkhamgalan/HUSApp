/**
	TextFieldInputTableViewController.swift

	A generic form controller used by OperationEditorViewController that specializes in user input of integers.
*/

import UIKit

//	Delegates receive important information through implementing the following protocol
protocol TextFieldInputTableViewControllerDelegate
{
    func userDidChangeText(sender: TextFieldInputTableViewController)
}

class TextFieldInputTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
	
	//	Externally configurable variables
    var savedValue: Int?
    var prompt = ""
	
    var delegate: TextFieldInputTableViewControllerDelegate?
	
	//	Computed property for getting and setting currently inputted integer
    var value: Int
    {
        get
        {
            return count(textField.text) == 0 ? -1 :
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
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		
		// Enable feature where tapping outside the text field removes focus a.k.a resigns first responder
		self.view!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "resignTextFieldFirstResponder"))
		
		textField.delegate = self
		
		if savedValue != nil
		{
			value = savedValue!
		}
	}
	
	//	resignTextFieldFirstResponder resigns the text field's status as first responder.
	//	It is linked a tap gesture recognizer that activates when the user taps outside the text field.
    func resignTextFieldFirstResponder()
    {
        textField.resignFirstResponder()
    }
	
	//	becomeFirstResponder makes the text field the first responder. It can be used by classes externally to give focus to the text field.
    override func becomeFirstResponder() -> Bool
    {
        return textField.becomeFirstResponder()
    }

	/*	text field delegate method that performs input validation and saves to model. */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
		// compute the "new"/changed string and remove any leading or trailing whitespace
        var newString = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if NSNumberFormatter().numberFromString(newString) != nil || count(newString) == 0
        {
			// only allow numbers
            delegate?.userDidChangeText(self)
            return true
        }
        else
        {
            return false
        }
    }
	
	//	Table view delegate methods
	//		The prompt/question is displayed as a section header.
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return prompt
    }

}
