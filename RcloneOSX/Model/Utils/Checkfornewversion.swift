//
//  newVersion.swift
//  rcloneOSXver30
//
//  Created by Thomas Evensen on 02/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable line_length

import Foundation

protocol NewVersionDiscovered: class {
    func notifyNewVersion()
}

final class Checkfornewversion {

    private var runningVersion: String?
    private var urlPlist: String?
    private var urlNewVersion: String?

    // External resources
    private var resource: Resources?

    weak var newversionDelegate: NewVersionDiscovered?

    //If new version set URL for download link and notify caller
    private func urlnewVersion (inMain: Bool) {
        globalBackgroundQueue.async(execute: { () -> Void in
            if let url = URL(string: self.urlPlist!) {
                do {
                    let contents = NSDictionary (contentsOf: url)
                    if let url = contents?.object(forKey: self.runningVersion!) {
                        self.urlNewVersion = url as? String
                        // Setting reference to new version if any
                        ViewControllerReference.shared.URLnewVersion = self.urlNewVersion
                        if inMain {
                            self.newversionDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllerMain
                            self.newversionDelegate?.notifyNewVersion()
                        } else {
                            self.newversionDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcabout) as? ViewControllerAbout
                            self.newversionDelegate?.notifyNewVersion()
                        }
                    }
                }
            }
        })
    }

    // Return version of RcloneOSX
    func rcloneOSXversion() -> String? {
        return self.runningVersion
    }

    init (inMain: Bool) {
        self.runningVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        self.resource = Resources()
        if let resource = self.resource {
            self.urlPlist = resource.getResource(resource: .urlPlist)
            self.urlnewVersion(inMain: inMain)
        }
    }
}
