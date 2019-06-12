//
//  userconfiguration.swift
//  rcloneOSXver30
//
//  Created by Thomas Evensen on 24/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length cyclomatic_complexity

import Foundation

// Reading userconfiguration from file into rcloneOSX
final class Userconfiguration {

    weak var rclonechangedDelegate: RcloneIsChanged?

    private func readUserconfiguration(dict: NSDictionary) {
        // Detailed logging
        if let detailedlogging = dict.value(forKey: "detailedlogging") as? Int {
            if detailedlogging == 1 {
                ViewControllerReference.shared.detailedlogging = true
            } else {
                ViewControllerReference.shared.detailedlogging = false
            }
        }
        // Optional path for rclone
        if let rclonePath = dict.value(forKey: "rclonePath") as? String {
            ViewControllerReference.shared.rclonePath = rclonePath
        }
        // Temporary path for restores single files or directory
        // Temporary path for restores single files or directory
        if let restorePath = dict.value(forKey: "restorePath") as? String {
            if restorePath.count > 0 {
                ViewControllerReference.shared.restorePath = restorePath
            } else {
                ViewControllerReference.shared.restorePath = nil
            }
        }
        // Mark tasks
        if let marknumberofdayssince = dict.value(forKey: "marknumberofdayssince") as? String {
            if Double(marknumberofdayssince)! > 0 {
                let oldmarknumberofdayssince = ViewControllerReference.shared.marknumberofdayssince
                ViewControllerReference.shared.marknumberofdayssince = Double(marknumberofdayssince)!
                if oldmarknumberofdayssince != ViewControllerReference.shared.marknumberofdayssince {
                    weak var reloadconfigurationsDelegate: Createandreloadconfigurations?
                    reloadconfigurationsDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
                    reloadconfigurationsDelegate?.createandreloadconfigurations()
                }
            }
        }
        // No logging, minimum logging or full logging
        if let minimumlogging = dict.value(forKey: "minimumlogging") as? Int {
            if minimumlogging == 1 {
                ViewControllerReference.shared.minimumlogging = true
            } else {
                ViewControllerReference.shared.minimumlogging = false
            }
        }
        if let fulllogging = dict.value(forKey: "fulllogging") as? Int {
            if fulllogging == 1 {
                ViewControllerReference.shared.fulllogging = true
            } else {
                ViewControllerReference.shared.fulllogging = false
            }
        }
        if let rclone143 = dict.value(forKey: "rclone143") as? Int {
            if rclone143 == 1 {
                ViewControllerReference.shared.rclone143 = true
            } else {
                ViewControllerReference.shared.rclone143 = nil
            }
        }
    }

    init (userconfigrcloneOSX: [NSDictionary]) {
        if userconfigrcloneOSX.count > 0 {
            self.readUserconfiguration(dict: userconfigrcloneOSX[0])
        }
        _ = Setrclonepath()
        _ = RcloneVersionString()
    }
}
