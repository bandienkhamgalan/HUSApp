/**
	OperationEditorViewController.swift

	A custom view controller that serves as a horizontally scrollable wizard/form for entering information for an Operation entity. 
	A paged scroll view is populated with 12 subviews (12 form screens). Each form subview is actually a table view, and several generic table view controllers
	were written for use in this class, each applicable to one data type e.g. date (with Date picker) or number (with Value picker.
*/

import UIKit

//	Delegates receive important messages from this class and need to implement this protocol
protocol OperationEditorViewControllerDelegate
{
    func userDidPressCancel(operationEditor: OperationEditorViewController)
    func userDidPressDone(operationEditor: OperationEditorViewController)
}

class OperationEditorViewController: UIViewController, UIScrollViewDelegate, SelectorTableViewControllerDelegate, TextFieldInputTableViewControllerDelegate
{
	var initialized = false
	var screens: [UITableViewController?] = []
	
    // Main views
    var scrollView: UIScrollView?
    var progressView: UIProgressView?
	
	// form subviews to go in scroll view
    var screenOne: DateAndTimePickerTableViewController?
    var screenTwo: SelectorTableViewController?
    var screenThree: SelectorTableViewController?
    var screenFour: DateAndTimePickerTableViewController?
    var screenFive: TextFieldInputTableViewController?
    var screenSix: ValuePickerTableViewController?
    var screenSeven: ValuePickerTableViewController?
    var screenEight: ValuePickerTableViewController?
    var screenNine: SelectorTableViewController?
    var screenTen: SelectorTableViewController?
    var screenEleven: DateAndTimePickerTableViewController?
    var screenTwelve: DeathTableViewController?
	
    var doneButton: UIBarButtonItem?
    var nextButton: UIBarButtonItem?
    
	// model
	var operation: Operation?
	
	// temporary data variables
	var approach: NSString?
	var admittedToICU: Bool?
	var complications: NSMutableDictionary?
	var resections: NSMutableDictionary?
	
	// state variables
    var existingOperation = false
    var currentPage: Int = 0
    var screensCompleted: [Bool] = []
    var completion: Float
    {
        get
        {
            var completed = 0
            for obj in screensCompleted
            {
                if (obj as Bool) == true
                {
                    completed++
                }
            }
            return Float(completed) / 12.0
        }
    }
    
    var essentialCompleted: Bool
    {
        get
        {
            for i in [1, 2, 4, 9]
            {
                if screensCompleted[i] == false
                {
                    return false
                }
            }
            return true
        }
    }
	
    var delegate: OperationEditorViewControllerDelegate?

	/*	The view of this controller is not drawn in Main.storyboard, and is thus set up manually in loadView and viewDidLoad. */
	override func loadView()
	{
		// full screen view
		var screenRect = UIScreen.mainScreen().bounds
		self.view = UIView(frame: CGRectMake(0, 0, screenRect.size.width, screenRect.size.height))
		
		// scrollview
		scrollView = UIScrollView(frame: CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64))
		view.addSubview(scrollView!)
		
		// bar buttons
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "userPressedCancel")
		doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "userPressedDone")
		nextButton = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Plain, target: self, action: "userPressedNext")
	
		// progress bar (only shown when entering information for a new operation)
		existingOperation = operation!.date != nil
		if !existingOperation
		{
			progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.Bar)
			progressView!.frame = CGRectMake(0, 64, screenRect.size.width, 2)
			view.addSubview(progressView!)
		}
		
	}

	override func viewDidLoad()
	{
		// configure scroll view
		scrollView!.contentInset = UIEdgeInsetsZero
		scrollView!.showsHorizontalScrollIndicator = false
		scrollView!.showsVerticalScrollIndicator = false
		scrollView!.pagingEnabled = true
		scrollView!.bounces = false
		scrollView!.directionalLockEnabled = true
		scrollView!.contentSize = CGSize(width: scrollView!.frame.size.width * 12, height: scrollView!.frame.size.height)
		scrollView!.delegate = self
		
		// configure main view settings
		self.view.tintColor = themeColour
		self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: themeColour]
		self.automaticallyAdjustsScrollViewInsets = false
		
		// configure progress bar
		progressView?.progress = 0
		
		// configure bar button items
		self.navigationItem.leftBarButtonItem!.tintColor = themeColour
		doneButton?.tintColor = themeColour
		nextButton?.tintColor = themeColour

		// configure model/state
		for _ in 0...11
		{
			screensCompleted.append(false)
		}
		
		// prepare array to hold scroll view subviews
		for _ in 0...11
		{
			screens.append(nil)
		}
		
		// ensure first two screens initialized
		ensureScreensInitialized()
		
		// start initializing asynchronously screens on background thread
		dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.value), 0))
		{
			for i in 0...11
			{
				if self.screens[i] == nil
				{
					self.screens[i] = self.initializeScreen(i)
					self.setupScreen(i)
					
					// all operations with views must take place on main thread
					dispatch_sync(dispatch_get_main_queue())
					{
						self.insertIntoScrollView(i)
						return
					}
				}
			}
			self.initialized = true
		}
		
		// update title and progress bar
		updateProgressBarAndTitleAndBarButtonItems()
		
		super.viewDidLoad()
	}
	
	/*	This function fires when the user presses the Cancel bar button item, discarding all changes and just
		sending the appropriate message to the delegate. */
	func userPressedCancel()
	{
		delegate?.userDidPressCancel(self)
	}
	
	/*	This function fires when the user presses the Next bar button item, and simply scrolls the scroll view
		to the next page/form screen. */
	func userPressedNext()
	{
		if currentPage < 11
		{
			var targetX = (currentPage + 1) * Int(scrollView!.frame.size.width)
			scrollView!.setContentOffset(CGPointMake(CGFloat(targetX), 0), animated: true)
		}
	}
	
	/*	This function fires when the user presses the Done bar button item, saving all user changes,
		and sending the corresponding message to the delegate. */
	func userPressedDone()
	{
		// animate completion (for UX)
		progressView?.setProgress(1.0, animated: true)
		
		// save user input to Operation entity
		operation!.date = screenOne?.date
		if screenTwo != nil {
			operation!.setApproachValue(approach! as String)
		}
		if screenThree != nil {
			operation!.setResectionsValue(resections! as [NSObject : AnyObject])
		}
		if screenFour != nil {
			operation!.duration = Int(screenFour!.duration! / 60)
		}
		if screenFive != nil {
			operation!.bloodLoss = screenFive!.value
		}
		if screenSix != nil {
			operation!.fev1 = screenSix!.value
		}
		if screenSeven != nil {
			operation!.dlco = screenSeven!.value
		}
		if screenEight != nil {
			operation!.durationOfStay = screenEight!.value
		}
		if screenNine != nil {
			operation!.setComplicationsValue(complications! as [NSObject : AnyObject])
		}
		if screenTen != nil {
			operation!.admittedToICU = admittedToICU
		}
		if screenEleven != nil {
			operation!.followUpDate = screenEleven!.date
		}
		if screenTwelve != nil {
			operation!.alive = !(screenTwelve!.death)
			operation!.deathDate = screenTwelve!.date
		}
		
		// send message to delegate
		delegate?.userDidPressDone(self)
	}
	
	/*	ensureScreensInitialized is a function that makes sure that whatever views the user can directly scroll to, are initialized and
		ready to be displayed. Initialization would ideally already have happened on the background thread, but this function insures
		against the worst case. */
	func ensureScreensInitialized()
	{
		if !initialized		// check local convenience variable
		{
			initialized = true
			for i in 0...11
			{
				if screens[i] == nil
				{
					initialized = false
					
					if i <= currentPage + 1
					{
						// initialize all views up to this page + 1
						screens[i] = initializeScreen(i)
						setupScreen(i)
						insertIntoScrollView(i)
					}
				}
			}
		}
	}
	
	/*	initializeScreen acts a a factory of sorts, whereby the caller specifies the index/page number of the screen to be initialized, and
		receives an instance of the appropriate form table view controller. */
	func initializeScreen(index: Int) -> UITableViewController?
	{
		let storyboard = UIStoryboard(name: "Main", bundle: nil)	// views were drawn in Storyboard
		switch(index)
		{
			case 0:
				screenOne = storyboard.instantiateViewControllerWithIdentifier("DateTimePicker") as? DateAndTimePickerTableViewController
				return screenOne
			case 1:
				screenTwo = storyboard.instantiateViewControllerWithIdentifier("Selector") as? SelectorTableViewController
				return screenTwo
			case 2:
				screenThree = storyboard.instantiateViewControllerWithIdentifier("Selector") as? SelectorTableViewController
				return screenThree
			case 3:
				screenFour = storyboard.instantiateViewControllerWithIdentifier("DateTimePicker") as? DateAndTimePickerTableViewController
				return screenFour
			case 4:
				screenFive = storyboard.instantiateViewControllerWithIdentifier("TextFieldInput") as? TextFieldInputTableViewController
				return screenFive
			case 5:
				screenSix = storyboard.instantiateViewControllerWithIdentifier("ValuePicker") as? ValuePickerTableViewController
				return screenSix
			case 6:
				screenSeven = storyboard.instantiateViewControllerWithIdentifier("ValuePicker") as? ValuePickerTableViewController
				return screenSeven
			case 7:
				screenEight = storyboard.instantiateViewControllerWithIdentifier("ValuePicker") as? ValuePickerTableViewController
				return screenEight
			case 8:
				screenNine = storyboard.instantiateViewControllerWithIdentifier("Selector") as? SelectorTableViewController
				return screenNine
			case 9:
				screenTen = storyboard.instantiateViewControllerWithIdentifier("Selector") as? SelectorTableViewController
				return screenTen
			case 10:
				screenEleven = storyboard.instantiateViewControllerWithIdentifier("DateTimePicker") as? DateAndTimePickerTableViewController
				return screenEleven
			case 11:
				screenTwelve = storyboard.instantiateViewControllerWithIdentifier("Death") as? DeathTableViewController
				return screenTwelve
			default:
				return nil
		}
	}
	
	/*	setupScreen takes the index of a form screen in the screens array as a parameter, and performs the configuration necessary
		to customize the generic form controller to the correct specifications. */
	func setupScreen(index: Int)
	{
		switch(index)
		{
			case 0:
				screenOne!.prompt = "Date of Operation"
				screenOne!.pickerMode = .Date
				if operation!.date != nil
				{
					screenOne!.savedDate = operation!.date
				}
				break
			case 1:
				screenTwo!.prompt = "Type of Approach"
				approach = operation!.approachString()
				screenTwo!.options = Operation.possibleApproaches() as! [String]!
				if operation!.approachString() != nil
				{
					screenTwo!.selection = [operation!.approachString()]
				}
				screenTwo!.mode = .Single
				screenTwo!.delegate = self
				break
			case 2:
				screenThree!.prompt = "Type of Resection"
				resections = operation!.resectionsDictionary()
				screenThree!.options = sorted(resections!.allKeys as! [String], <)
				screenThree!.mode = .Multiple
				if operation!.resection != nil
				{
					screenThree!.selection = operation!.resectionsArray() as! [String]
				}
				screenThree!.delegate = self
				break
			case 3:
				screenFour!.prompt = "Duration of Operation"
				screenFour!.pickerMode = .CountDownTimer
				if operation!.duration != nil
				{
					screenFour!.savedCountdown = NSTimeInterval(operation!.duration.intValue * 60)
				}
				break
			case 4:
				screenFive!.prompt = "Blood Loss / mL"
				screenFive!.delegate = self
				if operation!.bloodLoss != nil
				{
					screenFive!.savedValue = operation!.bloodLoss.integerValue
				}
				break
			case 5:
				screenSix!.prompt = "FEV1 / %"
				screenSix!.min = 0
				screenSix!.max = 100
				screenSix!.interval = 1
				screenSix!.initial = 50
				if operation!.bloodLoss != nil
				{
					screenSix!.savedValue = operation!.fev1.integerValue
				}
				break
			case 6:
				screenSeven!.prompt = "DLCO / %"
				screenSeven!.min = 0
				screenSeven!.max = 100
				screenSeven!.interval = 1
				screenSeven!.initial = 50
				if operation!.dlco != nil
				{
					screenSeven!.savedValue = operation!.dlco.integerValue
				}
				break
			case 7:
				screenEight!.prompt = "Total Time in Hospital / days"
				screenEight!.min = 0
				screenEight!.max = 365
				screenEight!.interval = 1
				screenEight!.initial = 7
				if operation!.durationOfStay != nil
				{
					screenEight!.savedValue = operation!.durationOfStay.integerValue
				}
				break
			case 8:
				screenNine!.prompt = "Complications during hospital stay"
				complications = Operation.emptyComplications()
				screenNine!.options = sorted(complications!.allKeys as! [String], <)
				screenNine!.mode = .Multiple
				if operation!.complications != nil
				{
					screenNine!.selection = operation!.complicationsArray() as! [String]
				}
				screenNine!.delegate = self
				break
			case 9:
				screenTen!.prompt = "Admission to ICU"
				screenTen!.options = ["Yes", "No"]
				screenTen!.mode = .Single
				if operation!.admittedToICU != nil
				{
					admittedToICU = operation!.admittedToICU.boolValue
					screenTen!.selection = [admittedToICU! == true ? "Yes" : "No"]
				}
				screenTen!.delegate = self
				break
			case 10:
				screenEleven!.prompt = "Follow-up Date"
				screenEleven!.pickerMode = .Date
				if operation!.followUpDate != nil
				{
					screenEleven!.savedDate = operation!.followUpDate
				}
				break
			case 11:
				if operation!.deathDate != nil
				{
					screenTwelve!.savedDeathDate = operation!.deathDate
				}
				break
			default:
				break
		}
	}
	
	/*	insertIntoScrollView takes the index of a form screen in the screens array as a parameter, and inserts
		the view of the form controller into the correct position into the main scroll view. */
	func insertIntoScrollView(index: Int)
	{
		var tvc = screens[index]!
		tvc.view.frame = CGRectMake(scrollView!.frame.size.width * CGFloat(index), 0, scrollView!.frame.size.width, scrollView!.frame.size.height)
		scrollView!.addSubview(tvc.view)
	}
	
	/*	Whenever the scroll view scrolls to a new page, multiple elements on screen must be updated. Firstly, the title shown in the navigation bar
		must be updated. Secondly, the progress bar should be updated, if the user did in fact complete the screen by entering valid input.
		Finally, because the top right bar button item is set to usually show "Next", if progress has reached 100%, the button is switched
		to "Done". */
	func updateProgressBarAndTitleAndBarButtonItems()
	{
		// calculate which screen the user is on
		var screen = round(scrollView!.contentOffset.x / scrollView!.frame.size.width)
		var previousPage = currentPage
		currentPage = Int(screen)
		
		// some form screens have default values, so if user has scrolled past such a screen
		// consider the screen completed
		if (previousPage == 0 || previousPage == 3 || previousPage == 5 || previousPage == 6 || previousPage == 7 || previousPage == 8 || previousPage == 10) && previousPage != currentPage
		{
			screensCompleted[previousPage] = true
		}
		
		// when the user scrolls onto page 4, which contains a text field, automatically make it the first responder
		// likewise the user scrolls away from page 4, automatically resign it from first responder
		if previousPage == 4 && previousPage != currentPage
		{
			screenFive!.resignTextFieldFirstResponder()
		}
		else if currentPage == 4 && previousPage != currentPage
		{
			screenFive!.becomeFirstResponder()
		}
		
		// if all essential screens have been completed (those without default values), switch "Next" to "Done"
		if existingOperation || (essentialCompleted == true && currentPage == 11 )
		{
			self.navigationItem.rightBarButtonItem = doneButton
		}
		else
		{
			self.navigationItem.rightBarButtonItem = nextButton
		}
		
		// update progress bar
		progressView?.setProgress(completion, animated: true)
		
		// update title
		title = "Question \((Int(screen) + 1))/12"
	}
	
	/*	userCanUpdateChoice is a SelectorTableViewControllerDelegate method that validates user input on a Selector form
		returning a boolean specifying whether or not the new input will be permitted.
		It is solely used for page 3 ("resections"), where there is a restriction that at least one item be selected at a time (empty selection not allowed). */
	func userCanUpdateChoice(newSelection: [String], sender: SelectorTableViewController) -> Bool
	{
		return sender == screenThree! ? count(newSelection) > 0 : true
	}
	
	/*	userDidUpdateChoice is a SelectorTableViewControllerDelegate method that is called after a user has changed the selection
		on a selector form. It is used to extract the new user input and update the temporary data variables. */
    func userDidUpdateChoice(sender: SelectorTableViewController)
    {
        var selections = sender.selection
        switch(sender)
        {
            case screenTwo!:
                // approach is stored as a string
				approach = selections[0]
                screensCompleted[1] = true
                userPressedNext()
                break
            case screenThree!:
                // resection is stored as a string to boolean map
				for obj in resections!.allKeys
				{
					var key = obj as! String
					resections!.setValue(contains(selections, key) ? NSNumber(bool: true) : NSNumber(bool: false), forKey: key)
				}
                screensCompleted[2] = true
                break
            case screenNine!:
                // complications is stored as a string to boolean map
                for obj in complications!.allKeys
                {
                    var key = obj as! String
                    complications!.setValue(contains(selections, key) ? NSNumber(bool: true) : NSNumber(bool: false), forKey: key)
                }
                operation!.setComplicationsValue(complications! as [NSObject : AnyObject])
                screensCompleted[8] = true
                break
            case screenTen!:
                // admission to ICU is stored as a boolean
                var answer = selections[0] as String
                admittedToICU = answer == "Yes"
                screensCompleted[9] = true
                userPressedNext()
            default:
                break
        }
    }
	
	/*	userDidChangeText is a TextFieldInputTableViewControllerDelegate method that is called after a user has changed the text inside
		a text field form. It is used to update the progress/completion. */
    func userDidChangeText(sender: TextFieldInputTableViewController)
    {
        if screenFive!.value > 0
        {
            screensCompleted[4] = true
        }
    }
	
	/*	scrollViewDidScroll is a UIScrollViewDelegate method that is used to respond to the user scrolling back and forth on the screen
		manually (by swiping instead of "Next" bar button item). It is used to make sure screens and initialized and update the
		progress bar, title and navigation bar items. */
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        updateProgressBarAndTitleAndBarButtonItems()
        ensureScreensInitialized()
    }
}