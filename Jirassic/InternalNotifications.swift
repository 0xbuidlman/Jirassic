//
//  InternalNotifications.swift
//  Jirassic
//
//  Created by Baluta Cristian on 13/12/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

let kNewTaskWasAddedNotification = "NewTaskWasAddedNotification"

class InternalNotifications: NSObject {

	class func taskAdded (task: Task) {
//		NSNotificationCenter.defaultCenter().postNotificationName(kNewTaskWasAddedNotification, object: task)
	}
}
