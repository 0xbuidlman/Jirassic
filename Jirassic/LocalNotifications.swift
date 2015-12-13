//
//  LocalNotifications.swift
//  Jirassic
//
//  Created by Baluta Cristian on 12/12/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class LocalNotifications: NSObject {

	func showNotification (title: String, informativeText: String) {
		
		let notification = NSUserNotification()
		notification.title = title
		notification.informativeText = informativeText
		
		NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
	}
}
