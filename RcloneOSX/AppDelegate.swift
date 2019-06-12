//
//  AppDelegate.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 05.11.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        var storage: PersistentStorageAPI?
        // Insert code here to initialize your application
        // Check for new version
        _ = Checkfornewversion(inMain: true)
        // Read user configuration
        storage = PersistentStorageAPI(profile: nil)
        if let userConfiguration =  storage?.getUserconfiguration(readfromstorage: true) {
            _ = Userconfiguration(userconfigrcloneOSX: userConfiguration)
        } else {
            _ = RcloneVersionString()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

}
