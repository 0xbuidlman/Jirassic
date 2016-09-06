//
//  TasksViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class TasksViewController: NSViewController {
	
	@IBOutlet private var splitView: NSSplitView?
	@IBOutlet private var calendarScrollView: CalendarScrollView?
	@IBOutlet private var tasksScrollView: TasksScrollView?
    @IBOutlet private var listSegmentedControl: NSSegmentedControl?
    
    var appWireframe: AppWireframe?
    var tasksPresenter: TasksPresenterInput?
	
	override func awakeFromNib() {
		view.layer = CALayer()
		view.wantsLayer = true
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		registerForNotifications()
        listSegmentedControl!.selectedSegment = TaskTypeSelection().lastType().rawValue
        
        calendarScrollView!.didSelectDay = { [weak self] (day: Day) in
            self?.tasksPresenter?.reloadTasksOnDay(day, listType: ListType(rawValue: (self?.listSegmentedControl!.selectedSegment)!)!)
        }
        
        tasksScrollView!.didRemoveRow = { [weak self] (row: Int) in
            RCLogO("Remove item at row \(row)")
            if row >= 0 {
                self?.tasksPresenter!.removeTaskAtRow(row)
                self?.tasksScrollView!.removeTaskAtRow(row)
            }
        }
        tasksScrollView!.didAddRow = { [weak self] (row: Int) -> Void in
            RCLogO("Add item after row \(row)")
            if row >= 0 {
                self?.tasksPresenter!.insertTaskAfterRow(row)
            }
        }
    }
	
	override func viewDidAppear() {
		super.viewDidAppear()
        tasksPresenter!.refreshUI()
	}
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
}

extension TasksViewController {
	
	@IBAction func handleSegmentedControl (sender: NSSegmentedControl) {
        let listType = ListType(rawValue: sender.selectedSegment)!
        TaskTypeSelection().setType(listType)
        if let selectedDay = calendarScrollView!.selectedDay {
            tasksPresenter!.reloadTasksOnDay(selectedDay, listType: listType)
        }
	}
    
    @IBAction func handleSettingsButton (sender: NSButton) {
        appWireframe!.flipToSettingsController()
    }
    
    @IBAction func handleQuitAppButton (sender: NSButton) {
        NSApplication.sharedApplication().terminate(nil)
    }
}

extension TasksViewController: TasksPresenterOutput {
    
    func showLoadingIndicator (show: Bool) {
        
    }
    
    func showMessage (message: MessageViewModel) {
        
        appWireframe?.presentMessage(message, intoSplitView: splitView!)
        appWireframe?.messageViewController.didPressButton = tasksPresenter?.messageButtonDidPress
    }
    
    func showDates (weeks: [Week]) {
        
        calendarScrollView?.weeks = weeks
        calendarScrollView?.reloadData()
    }
    
    func showTasks (tasks: [Task], listType: ListType) {
        
        RCLog(listType)
        tasksScrollView!.listType = listType
        tasksScrollView!.data = tasks
        tasksScrollView!.reloadData()
        tasksScrollView!.hidden = false
    }
    
    func selectDay (day: Day) {
        calendarScrollView!.selectDay(day)
    }
    
    func presentNewTaskController() {
        
        splitView!.hidden = true
        appWireframe!.removeMessage()
        
        appWireframe!.presentNewTaskController()
        appWireframe!.newTaskViewController.date = NSDate()
        appWireframe!.newTaskViewController.onOptionChosen = { [weak self] (taskData: TaskCreationData) -> Void in
            self?.tasksPresenter!.insertTaskWithData(taskData)
            self?.tasksPresenter!.updateNoTasksState()
            self?.tasksPresenter!.reloadData()
            self?.appWireframe!.removeNewTaskController()
            self?.splitView!.hidden = false
        }
        appWireframe!.newTaskViewController.onCancelChosen = { [weak self] in
            self?.appWireframe?.removeNewTaskController()
            self?.splitView?.hidden = false
            self?.tasksPresenter?.updateNoTasksState()
        }
    }
}

extension TasksViewController {
	
	func registerForNotifications() {
		
		NSNotificationCenter.defaultCenter().addObserver(self,
			selector: #selector(TasksViewController.handleNewTaskAdded(_:)),
			name: kNewTaskWasAddedNotification,
			object: nil)
	}
	
	func handleNewTaskAdded (notif: NSNotification) {
        tasksPresenter?.reloadData()
	}
}
