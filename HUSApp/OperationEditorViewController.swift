//
//  OperationEditorViewController.swift
//  HUSApp
//
//  Created by Bandi Enkh-Amgalan on 3/5/15.
//  Copyright (c) 2015 ucl. All rights reserved.
//

import UIKit

protocol OperationEditorViewControllerDelegate
{
    func userDidPressCancel(operationEditor: OperationEditorViewController)
    func userDidPressDone(operationEditor: OperationEditorViewController)
}

class OperationEditorViewController: UIViewController, UIScrollViewDelegate, SelectorTableViewControllerDelegate
{
    func userPressedCancel()
    {
        if delegate != nil
        {
            delegate!.userDidPressCancel(self)
        }
    }
    
    // views
    
    var scrollView: UIScrollView?
    var progressView: UIProgressView?
    
    var initialized = false
    var screens: [UITableViewController?] = []
    
    var screenOne: DateAndTimePickerTableViewController?
    var screenTwo: SelectorTableViewController?
    var screenThree: SelectorTableViewController?
    var screenFour: DateAndTimePickerTableViewController?
    var screenFive: ValuePickerTableViewController?
    var screenSix: ValuePickerTableViewController?
    var screenSeven: SelectorTableViewController?
    var screenEight: SelectorTableViewController?
    var screenNine: DateAndTimePickerTableViewController?
    var screenTen: DeathTableViewController?
    var doneButton: UIBarButtonItem?
    var nextButton: UIBarButtonItem?
    
    // model
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
            return Float(completed) / 10.0
        }
    }
    
    var essentialCompleted: Bool
    {
        get
        {
            for i in [1, 2, 6, 7]
            {
                if screensCompleted[i] == false
                {
                    return false
                }
            }
            return true
        }
    }
    
    var operation: Operation?
    var complications: NSMutableDictionary?
    
    // miscellaneous
    var delegate: OperationEditorViewControllerDelegate?
    
    let themeColour = UIColor(red: 69.0/255.0, green: 174.0/255.0, blue: 172.0/255.0, alpha: 1.0)

    func userDidSelectChoice(sender: SelectorTableViewController)
    {
        var selections = sender.selection
        switch(sender)
        {
            case screenTwo!:
                // approach
                operation!.setApproachValue(selections[0])
                println(operation!.approachString())
                screensCompleted[1] = true
                userPressedNext()
                break
            case screenThree!:
                // resection
                operation!.setResectionValue(selections[0])
                println(operation!.resectionString())
                screensCompleted[2] = true
                userPressedNext()
                break
            case screenSeven!:
                // complications
                for obj in complications!.allKeys
                {
                    var key = obj as String
                    complications!.setValue(contains(selections, key) ? NSNumber(bool: true) : NSNumber(bool: false), forKey: key)
                }
                operation!.setComplicationsValue(complications!)
                screensCompleted[6] = true
                break
            case screenEight!:
                // admission to ICU
                var answer = selections[0] as String
                if answer == "Yes"
                {
                    operation!.admittedToICU = NSNumber(bool: true)
                }
                else
                {
                    operation!.admittedToICU = NSNumber(bool: false)
                }
                screensCompleted[7] = true
                userPressedNext()
            default:
                break
        }
    }
    
    func userPressedDone()
    {
        if delegate != nil
        {
            progressView!.setProgress(1.0, animated: true)
            operation!.date = screenOne!.date
            operation!.duration = screenFour!.duration
            operation!.bloodLoss = screenFive!.value
            operation!.durationOfStay = screenSix!.value
            operation!.alive = screenTen!.death
            operation!.deathDate = screenTen!.date
            delegate!.userDidPressDone(self)
        }
    }
    
    func setupScrollView() -> UIScrollView
    {
        var toReturn = UIScrollView(frame: CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64))
        toReturn.contentInset = UIEdgeInsetsZero
        toReturn.showsHorizontalScrollIndicator = false
        toReturn.showsVerticalScrollIndicator = false
        toReturn.pagingEnabled = true
        toReturn.bounces = false
        toReturn.directionalLockEnabled = true
        toReturn.contentSize = CGSize(width: toReturn.frame.size.width * 10, height: toReturn.frame.size.height)
        toReturn.delegate = self
        return toReturn
    }
    
    func userPressedNext()
    {
        if currentPage < 9
        {
            var targetX = (currentPage + 1) * Int(scrollView!.frame.size.width)
            scrollView!.setContentOffset(CGPointMake(CGFloat(targetX), 0), animated: true)
        }
    }
    
    func updateIndicatorAndTitle()
    {
        var screen = scrollView!.contentOffset.x / scrollView!.frame.size.width
        var previousPage = currentPage
        currentPage = Int(screen)
        
        // determine progress
        if (previousPage == 0 || previousPage == 3 || previousPage == 4 || previousPage == 5 || previousPage == 8) && previousPage < currentPage
        {
            screensCompleted[previousPage] = true
        }
        
        if essentialCompleted && currentPage == 9
        {
            self.navigationItem.rightBarButtonItem = doneButton
        }
        else
        {
            self.navigationItem.rightBarButtonItem = nextButton
        }
    
        progressView!.setProgress(completion, animated: true)
        title = "Question \((Int(screen) + 1))/10"
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView)
    {
        updateIndicatorAndTitle()
        ensureScreensInitialized()
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView)
    {
        updateIndicatorAndTitle()
        ensureScreensInitialized()
    }
    
    func initializeScreen(index: Int) -> UITableViewController?
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
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
                screenFive = storyboard.instantiateViewControllerWithIdentifier("ValuePicker") as? ValuePickerTableViewController
                return screenFive
            case 5:
                screenSix = storyboard.instantiateViewControllerWithIdentifier("ValuePicker") as? ValuePickerTableViewController
                return screenSix
            case 6:
                screenSeven = storyboard.instantiateViewControllerWithIdentifier("Selector") as? SelectorTableViewController
                return screenSeven
            case 7:
                screenEight = storyboard.instantiateViewControllerWithIdentifier("Selector") as? SelectorTableViewController
                return screenEight
            case 8:
                screenNine = storyboard.instantiateViewControllerWithIdentifier("DateTimePicker") as? DateAndTimePickerTableViewController
                return screenNine
            case 9:
                screenTen = storyboard.instantiateViewControllerWithIdentifier("Death") as? DeathTableViewController
                return screenTen
            default:
                return nil
        }
    }
    
    func setupScreen(index: Int)
    {
        switch(index)
        {
            case 0:
                screenOne!.prompt = "Date of Operation"
                screenOne!.pickerMode = .Date
                break
            case 1:
                screenTwo!.prompt = "Type of Approach"
                var approaches = Operation.possibleApproaches() as [String]
                screenTwo!.options = approaches
                screenTwo!.mode = .Single
                screenTwo!.delegate = self
                break
            case 2:
                screenThree!.prompt = "Type of Resection"
                var resections = Operation.possibleResections() as [String]
                screenThree!.options = Operation.possibleResections() as [String]
                screenThree!.mode = .Single
                screenThree!.delegate = self
                break
            case 3:
                screenFour!.prompt = "Duration of Operation"
                screenFour!.pickerMode = .CountDownTimer
                break
            case 4:
                screenFive!.prompt = "Blood Loss / mL"
                screenFive!.min = 0
                screenFive!.max = 100
                screenFive!.interval = 1
                screenFive!.initial = 20
                break
            case 5:
                screenSix!.prompt = "Total Time in Hospital / days"
                screenSix!.min = 0
                screenSix!.max = 30
                screenSix!.interval = 1
                screenSix!.initial = 7
                break
            case 6:
                screenSeven!.prompt = "Complications during hospital stay"
                complications = Operation.emptyComplications()
                screenSeven!.options = complications!.allKeys as? [String]
                screenSeven!.mode = .Multiple
                screenSeven!.delegate = self
                break
            case 7:
                screenEight!.prompt = "Admission to ICU"
                screenEight!.options = ["Yes", "No"]
                screenEight!.mode = .Single
                screenEight!.delegate = self
                break
            case 8:
                screenNine!.prompt = "Follow-up Date"
                screenNine!.pickerMode = .Date
                break
            default:
                break
        }
    }
    
    func insertIntoScrollView(index: Int)
    {
        var tvc = screens[index]!
        tvc.view.frame = CGRectMake(scrollView!.frame.size.width * CGFloat(index), 0, scrollView!.frame.size.width, scrollView!.frame.size.height)
        scrollView!.addSubview(tvc.view)
    }
    
    func ensureScreensInitialized()
    {
        if(!initialized)
        {
            initialized = true
            for i in 0...9
            {
                if screens[i] == nil
                {
                    initialized = false
                    if i <= currentPage + 1
                    {
                        screens[i] = initializeScreen(i)
                        setupScreen(i)
                        insertIntoScrollView(i)
                    }
                }
            }
        }
    }
    
    override func loadView()
    {
        var screenRect = UIScreen.mainScreen().bounds
        self.view = UIView(frame: CGRectMake(0, 0, screenRect.size.width, screenRect.size.height))
        
        // scrollview
        scrollView = setupScrollView()
        view.addSubview(scrollView!)
    }
    
    override func viewDidLoad()
    {
        if operation == nil
        {
            if delegate != nil
            {
                delegate!.userDidPressCancel(self)
            }
        }
        var screenRect = UIScreen.mainScreen().bounds
        self.view.tintColor = themeColour
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: themeColour]
            
        // bar buttons
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "userPressedCancel")
      
        doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "userPressedDone")
       
        nextButton = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Plain, target: self, action: "userPressedNext")
        
        self.navigationItem.leftBarButtonItem?.tintColor = themeColour
        doneButton?.tintColor = themeColour
        nextButton?.tintColor = themeColour
        
        // progress view
        progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.Bar)
        progressView!.frame = CGRectMake(0, 64, screenRect.size.width, 2)
        progressView!.progress = 0
        view.addSubview(progressView!)
        
        // setup screen completed (model)
        for _ in 0...9
        {
            screensCompleted.append(false)
        }
        
        // setup screens array
        for _ in 0...9
        {
            screens.append(nil)
        }
        
        // update
        updateIndicatorAndTitle()
        
        // add screens
        ensureScreensInitialized()
        navigationItem.rightBarButtonItem = nextButton
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
