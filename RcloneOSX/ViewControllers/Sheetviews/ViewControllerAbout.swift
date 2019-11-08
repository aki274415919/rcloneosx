//
//  ViewControllerAbout.swift
//  rcloneOSX
//
//  Created by Thomas Evensen on 18/11/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation
import Cocoa

class ViewControllerAbout: NSViewController, SetDismisser {

    @IBOutlet weak var version: NSTextField!
    @IBOutlet weak var downloadbutton: NSButton!
    @IBOutlet weak var thereisanewversion: NSTextField!
    @IBOutlet weak var rcloneversionstring: NSTextField!
    @IBOutlet weak var copyright: NSTextField!
    @IBOutlet weak var iconby: NSTextField!

    var copyrigthstring: String = "Copyright © 2019 Thomas Evensen"
    var iconbystring: String = "Icon by: Zsolt Sándor"

    // External resources as documents, download
    private var resource: Resources?

    @IBAction func dismiss(_ sender: NSButton) {
        if (self.presentingViewController as? ViewControllerMain) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
        } else if (self.presentingViewController as? ViewControllerNewConfigurations) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcnewconfigurations)
        } else if (self.presentingViewController as? ViewControllerCopyFiles) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vccopyfiles)
        } else if (self.presentingViewController as? ViewControllerLoggData) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcloggdata)
        } else if (self.presentingViewController as? ViewControllerRestore) != nil {
            self.dismissview(viewcontroller: self, vcontroller: .vcrestore)
        }
    }

    @IBAction func changelog(_ sender: NSButton) {
        if let resource = self.resource {
            NSWorkspace.shared.open(URL(string: resource.getResource(resource: .changelog))!)
        }
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    @IBAction func documentation(_ sender: NSButton) {
        if let resource = self.resource {
            NSWorkspace.shared.open(URL(string: resource.getResource(resource: .documents))!)
        }
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    @IBAction func download(_ sender: NSButton) {
        guard ViewControllerReference.shared.URLnewVersion != nil else {
            self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
            return
        }
        NSWorkspace.shared.open(URL(string: ViewControllerReference.shared.URLnewVersion!)!)
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.copyright.stringValue = self.copyrigthstring
        self.iconby.stringValue = self.iconbystring
        ViewControllerReference.shared.setvcref(viewcontroller: .vcabout, nsviewcontroller: self)
        self.resource = Resources()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.downloadbutton.isEnabled = false
        if let version = Checkfornewversion().rcloneOSXversion() {
            self.version.stringValue = "RcloneOSX ver: " + version
        }
        self.thereisanewversion.stringValue = "You have the latest ..."
        self.rcloneversionstring.stringValue = ViewControllerReference.shared.rcloneversionstring ?? ""
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.downloadbutton.isEnabled = false
    }

}

extension ViewControllerAbout: NewVersionDiscovered {
    // Notifies if new version is discovered
    func notifyNewVersion() {
        globalMainQueue.async(execute: { () -> Void in
            self.downloadbutton.isEnabled = true
            self.thereisanewversion.stringValue = "New version available: "
        })
    }
}
