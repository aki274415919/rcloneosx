//
//  newVersion.swift
//  rcloneOSXver30
//
//  Created by Thomas Evensen on 02/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation

protocol NewVersionDiscovered: AnyObject {
    func notifyNewVersion()
}

final class Checkfornewversion {
    private var runningVersion: String?
    private var urlPlist: String?
    private var urlNewVersion: String?

    weak var newversionDelegateMain: NewVersionDiscovered?
    weak var newversionDelegateAbout: NewVersionDiscovered?

    // If new version set URL for download link and notify caller
    private func urlnewVersion() {
        globalBackgroundQueue.async { () -> Void in
            if let url = URL(string: self.urlPlist ?? "") {
                do {
                    let contents = NSDictionary(contentsOf: url)
                    if let url = contents?.object(forKey: self.runningVersion ?? "") {
                        self.urlNewVersion = url as? String
                        // Setting reference to new version if any
                        ViewControllerReference.shared.URLnewVersion = self.urlNewVersion
                        self.newversionDelegateMain = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
                        self.newversionDelegateAbout = ViewControllerReference.shared.getvcref(viewcontroller: .vcabout) as? ViewControllerAbout
                        self.newversionDelegateMain?.notifyNewVersion()
                        self.newversionDelegateAbout?.notifyNewVersion()
                    }
                }
            }
        }
    }

    // Return version of RcloneOSX
    func rcloneOSXversion() -> String? {
        return self.runningVersion
    }

    init() {
        self.runningVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let resource = Resources()
        self.urlPlist = resource.getResource(resource: .urlPlist)
        self.urlnewVersion()
    }
}
