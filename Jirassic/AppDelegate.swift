//
//  AppDelegate.swift
//  Jira Logger
//
//  Created by Cristian Baluta on 24/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

let sharedData: DataManagerProtocol = DataManager()

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	@IBOutlet var window: NSWindow?
    @IBOutlet var popover: NSPopover?
    private var sleep: SleepNotifications?
	private let menu = MenuBarController()
	
	override init() {
		super.init()
		
		menu.onMouseDown = { [weak self] in
			if let wself = self {
				if (wself.menu.iconView?.isSelected == true) {
					Wireframe.showPopover(wself.popover!, fromIcon: wself.menu.iconView!)
				} else {
					Wireframe.hidePopover(wself.popover!)
				}
			}
        }
		
        sleep = SleepNotifications()
        sleep?.computerWentToSleep = {
			let reader = ReadDayInteractor(data: sharedData)
			let existingTasks = reader.tasksForDayOfDate(NSDate())
			if existingTasks.count > 0 {
				// We already started the day, analyze if it's scrum time
				
			}
        }
        sleep?.computerWakeUp = {
			let reader = ReadDayInteractor(data: sharedData)
			let existingTasks = reader.tasksForDayOfDate(NSDate())
			if existingTasks.count > 0 {
				// We already started the day, analyze if it's scrum time
				if TaskTypeFinder().scrumExists(existingTasks) {
					let task = Task(dateSart: self.sleep?.lastSleepDate, dateEnd: NSDate(), type: TaskType.Scrum)
					sharedData.updateTask(task, completion: {(success: Bool) -> Void in })
					InternalNotifications.taskAdded(task)
				}
			} else {
				// This might be the start of the day. Should we start counting automatically or wait the user to press start?
				
			}
        }
	}
	
    func applicationDidFinishLaunching (aNotification: NSNotification) {
		
		let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
		dispatch_after(dispatchTime, dispatch_get_main_queue(), {
			self.menu.iconView?.mouseDown(NSEvent())
		})
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
    }
	
    func applicationWillTerminate (aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

extension AppDelegate: NSUserNotificationCenterDelegate {
	
    func userNotificationCenter (center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
}

