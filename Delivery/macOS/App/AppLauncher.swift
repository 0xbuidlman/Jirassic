//
//  AppLauncher.swift
//  Jirassic
//
//  Created by Cristian Baluta on 24/12/2016.
//  Copyright © 2016 Imagin soft. All rights reserved.
//

import Cocoa
import ServiceManagement

extension AppDelegate {

    func killLauncher() {
        
        let identifier = "com.ralcr.Jirassic.osx.launcher"
        let ret = SMLoginItemSetEnabled(identifier as CFString, true)
        RCLog(ret)
        return
        for app in NSWorkspace.shared().runningApplications {
            if app.bundleIdentifier == identifier {
                DistributedNotificationCenter.default()
                    .postNotificationName(NSNotification.Name(rawValue: "killme"),
                                          object: Bundle.main.bundleIdentifier!,
                                          userInfo: nil,
                                          deliverImmediately: true)
                break
            }
        }
    }
}
