//
//  ViewControllertabMain.swift
//  rcloneOSXver30
//  The Main ViewController.
//
//  Created by Thomas Evensen on 19/08/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  swiftlint:disable  file_length line_length type_body_length

import Foundation
import Cocoa

// Protocol for start,stop, complete progressviewindicator
protocol StartStopProgressIndicator: class {
    func start()
    func stop()
    func complete()
}

// Protocol for either completion of work or update progress when Process discovers a
// process termination and when filehandler discover data
protocol UpdateProgress: class {
    func processTermination()
    func fileHandler()
}

protocol ViewOutputDetails: class {
    func reloadtable()
    func appendnow() -> Bool
    func getalloutput() -> [String]
    func enableappend()
    func disableappend()
}

// Protocol for getting the hiddenID for a configuration
protocol GetHiddenID: class {
    func gethiddenID() -> Int?
}

protocol SetProfileinfo: class {
    func setprofile(profile: String, color: NSColor)
}

protocol AllProfileDetails: class {
    func enablereloadallprofiles()
    func disablereloadallprofiles()
}

class ViewControllertabMain: NSViewController, ReloadTable, Deselect, VcMain, FileerrorMessage, Remoterclonesize, Setcolor {

    // Configurations object
    var configurations: Configurations?
    var schedules: Schedules?
    // Reference to the single taskobject
    var singletask: SingleTask?
    // Reference to batch taskobject
    var batchtasks: BatchTask?
    var dateandtime: Dateandtime?
    // Delegate function getting batchTaskObject
    weak var batchtasksDelegate: GetNewBatchTask?
    // Main tableview
    @IBOutlet weak var mainTableView: NSTableView!
    // Progressbar indicating work
    @IBOutlet weak var working: NSProgressIndicator!
    @IBOutlet weak var estimating: NSTextField!
    // Displays the rcloneCommand
    @IBOutlet weak var rcloneCommand: NSTextField!
    // If On result of Dryrun is presented before
    // executing the real run
    @IBOutlet weak var dryRunOrRealRun: NSTextField!
    // Progressbar scheduled task
    @IBOutlet weak var executing: NSTextField!
    // total number of files in remote volume
    @IBOutlet weak var totalNumber: NSTextField!
    // total size of files in remote volume
    // Showing info about profile
    @IBOutlet weak var profilInfo: NSTextField!
    // Showing info about double clik or not
    @IBOutlet weak var rcloneversionshort: NSTextField!
    @IBOutlet weak var remoteinfonumber: NSTextField!
    @IBOutlet weak var remoteinfosize: NSTextField!

    // Reference to Process task
    var process: Process?
    // Index to selected row, index is set when row is selected
    var index: Int?
    // Getting output from rclone
    var outputprocess: OutputProcess?
    // Getting output from batchrun
    var outputbatch: OutputBatch?
    // Dynamic view of output
    var dynamicappend: Bool = false
    // HiddenID task, set when row is selected
    var hiddenID: Int?
    // Bool if one or more remote server is offline
    // Ready for execute again
    var readyforexecution: Bool = true
    // Update view estimating
    var setbatchyesno: Bool = false
    // Allprofiles view presented
    var allprofilesview: Bool = false
    // Delegate for refresh allprofiles if changes in profiles
    weak var allprofiledetailsDelegate: ReloadTableAllProfiles?

    @IBOutlet weak var info: NSTextField!

    @IBAction func restore(_ sender: NSButton) {
        guard self.index != nil else {
            self.info(num: 1)
            return
        }
        guard ViewControllerReference.shared.norclone == false else {
            _ = Norclone()
            return
        }
        guard self.configurations!.getConfigurations()[self.index!].task == ViewControllerReference.shared.sync else {
                self.info(num: 7)
                return
        }
        self.configurations!.processtermination = .restore
        self.presentAsSheet(self.restoreViewController!)
    }

    @IBAction func getremoteinfo(_ sender: NSButton) {
        guard ViewControllerReference.shared.norclone == false else {
            _ = Norclone()
            return
        }
        if self.index != nil {
            self.configurations!.processtermination = .rclonesize
            self.outputprocess = OutputProcess()
            self.working.startAnimation(nil)
            self.estimating.isHidden = false
            _ = RcloneSize(index: self.index!, outputprocess: self.outputprocess)
        } else {
            self.info(num: 1)
        }
    }

    @IBAction func totinfo(_ sender: NSButton) {
        guard ViewControllerReference.shared.norclone == false else {
            _ = Norclone()
            return
        }
        self.configurations!.processtermination = .remoteinfotask
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerRemoteInfo!)
        })
    }

    @IBAction func quickbackup(_ sender: NSButton) {
        guard ViewControllerReference.shared.norclone == false else {
            _ = Norclone()
            return
        }
        self.configurations!.processtermination = .quicktask
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerQuickBackup!)
        })
    }

    @IBAction func edit(_ sender: NSButton) {
        self.reset()
        guard self.index != nil else {
            self.info(num: 1)
            return
        }
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.editViewController!)
        })
    }

    @IBAction func rcloneparams(_ sender: NSButton) {
        self.reset()
        guard self.index != nil else {
            self.info(num: 1)
            return
        }
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerRcloneParams!)
        })
    }

    @IBAction func delete(_ sender: NSButton) {
        self.reset()
        guard self.hiddenID != nil else {
            self.info(num: 1)
            return
        }
        let answer = Alerts.dialogOKCancel("Delete selected task?", text: "Cancel or OK")
        if answer {
            if self.hiddenID != nil {
                // Delete Configurations and Schedules by hiddenID
                self.configurations!.deleteConfigurationsByhiddenID(hiddenID: self.hiddenID!)
                self.schedules!.deletescheduleonetask(hiddenID: self.hiddenID!)
                self.deselect()
                self.hiddenID = nil
                self.index = nil
                self.reloadtabledata()
            }
        }
    }

    func info(num: Int) {
        switch num {
        case 1:
            self.info.stringValue = "Select a task...."
        case 2:
            self.info.stringValue = "Possible error logging..."
        case 3:
            self.info.stringValue = "No rclone in path..."
        case 4:
            self.info.stringValue = "⌘A to abort or wait..."
        default:
            self.info.stringValue = ""
        }
    }

    // Menus as Radiobuttons for Edit functions in tabMainView
    func reset() {
        self.outputprocess = nil
        self.setNumbers(output: nil)
        self.process = nil
        self.singletask = nil
    }

    @IBAction func information(_ sender: NSToolbarItem) {
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerInformation!)
        })
    }

    // Abort button
    @IBAction func abort(_ sender: NSButton) {
        globalMainQueue.async(execute: { () -> Void in
            self.abortOperations()
            self.process = nil
        })
    }

    @IBAction func userconfiguration(_ sender: NSToolbarItem) {
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerUserconfiguration!)
        })
    }

    // Selecting profiles
    @IBAction func profiles(_ sender: NSButton) {
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerProfile!)
        })
    }

    // Selecting About
    @IBAction func about (_ sender: NSButton) {
        self.presentAsModalWindow(self.viewControllerAbout!)
    }

    // Selecting automatic backup
    @IBAction func automaticbackup (_ sender: NSButton) {
        self.automaticbackup()
    }

    func automaticbackup() {
        self.configurations!.processtermination = .automaticbackup
        self.configurations?.remoteinfotaskworkqueue = RemoteInfoTaskWorkQueue(inbatch: false)
        self.presentAsSheet(self.viewControllerEstimating!)
    }

    @IBAction func executetasknow(_ sender: NSButton) {
        guard self.hiddenID != nil else {
            self.info(num: 1)
            return
        }
        guard self.index != nil else {
            self.info(num: 1)
            return
        }
        guard self.configurations!.getConfigurations()[self.index!].task != ViewControllerReference.shared.move ||
        self.configurations!.getConfigurations()[self.index!].task != ViewControllerReference.shared.check else {
            return
        }
        self.configurations!.processtermination = .singlequicktask
        self.working.startAnimation(nil)
        let arguments = self.configurations!.arguments4rclone(index: self.index!, argtype: .arg)
        self.outputprocess = OutputProcess()
        let process = Rclone(arguments: arguments)
        process.executeProcess(outputprocess: self.outputprocess)
        self.process = process.getProcess()
    }

    // Function for display rclone command
    // Either --dry-run or real run
    @IBOutlet weak var displaysynccommand: NSButton!
    @IBOutlet weak var displayRealRun: NSButton!
    @IBAction func displayRcloneCommand(_ sender: NSButton) {
        self.showrclonecommandmainview()
    }

    // Display correct rclone command in view
    func showrclonecommandmainview() {
        if let index = self.index {
            guard index <= self.configurations!.getConfigurations().count else {
                return
            }
            if self.displaysynccommand.state == .on {
                self.rcloneCommand.stringValue = Displayrclonepath(index: index, display: .sync).rclonepath ?? ""
            } else {
                self.rcloneCommand.stringValue = Displayrclonepath(index: index, display: .restore).rclonepath ?? ""
            }
        } else {
            self.rcloneCommand.stringValue = ""
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        self.working.usesThreadedAnimation = true
        ViewControllerReference.shared.setvcref(viewcontroller: .vctabmain, nsviewcontroller: self)
        self.mainTableView.target = self
        self.mainTableView.doubleAction = #selector(ViewControllertabMain.tableViewDoubleClick(sender:))
        self.displaysynccommand.state = .on
        _ = Setrclonepath()
        // configurations and schedules
        self.createandreloadconfigurations()
        self.createandreloadschedules()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        if ViewControllerReference.shared.initialstart == 0 {
            self.view.window?.center()
            ViewControllerReference.shared.initialstart = 1
        }
         ViewControllerReference.shared.activetab = .vctabmain
        if self.configurations!.configurationsDataSourcecount() > 0 {
            globalMainQueue.async(execute: { () -> Void in
                self.mainTableView.reloadData()
            })
        }
        self.rcloneischanged()
        self.displayProfile()
        self.readyforexecution = true
        if self.dateandtime == nil { self.dateandtime = Dateandtime()}
    }

    // Execute tasks by double click in table
    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender: AnyObject) {
        if self.readyforexecution {
            self.executeSingleTask()
        }
        self.readyforexecution = false
    }

    // Single task can be activated by double click from table
    func executeSingleTask() {
        self.configurations!.processtermination = .singletask
        guard ViewControllerReference.shared.norclone == false else {
            _ = Norclone()
            return
        }
        guard self.index != nil else { return }
        self.batchtasks = nil
        guard self.singletask != nil else {
            // Dry run
            self.singletask = SingleTask(index: self.index!)
            self.singletask?.executeSingleTask()
            // Set reference to singleTask object
            self.configurations!.singleTask = self.singletask
            return
        }
        // Real run
        self.singletask?.executeSingleTask()
    }

    @IBAction func executeBatch(_ sender: NSToolbarItem) {
        self.configurations!.processtermination = .estimatebatchtask
        guard ViewControllerReference.shared.norclone == false else {
            _ = Norclone()
            return
        }
        self.singletask = nil
        self.setNumbers(output: nil)
        self.deselect()
        globalMainQueue.async(execute: { () -> Void in
            self.presentAsSheet(self.viewControllerBatch!)
        })
    }

    // Function for setting profile
    func displayProfile() {
        weak var localprofileinfo: SetProfileinfo?
        if let profile = self.configurations!.getProfile() {
            self.profilInfo.stringValue = "Profile: " + profile
            self.profilInfo.textColor = setcolor(nsviewcontroller: self, color: .black)
        } else {
            self.profilInfo.stringValue = "Profile: default"
            self.profilInfo.textColor = setcolor(nsviewcontroller: self, color: .green)
        }
        localprofileinfo = ViewControllerReference.shared.getvcref(viewcontroller: .vcnewconfigurations ) as? ViewControllerNewConfigurations
        localprofileinfo?.setprofile(profile: self.profilInfo.stringValue, color: self.profilInfo.textColor!)
        self.showrclonecommandmainview()
    }

    // Setting remote info
    func remoteinfo(reset: Bool) {
        guard self.outputprocess?.getOutput()?.count ?? 0 > 0 || reset == false else {
            self.remoteinfonumber.stringValue = ""
            self.remoteinfosize.stringValue = ""
            return
        }
        let size = self.remoterclonesize(input: self.outputprocess!.getOutput()![0])
        guard size != nil else { return }
        NumberFormatter.localizedString(from: NSNumber(value: size!.count), number: NumberFormatter.Style.decimal)
        self.remoteinfonumber.stringValue = String(NumberFormatter.localizedString(from: NSNumber(value: size!.count), number: NumberFormatter.Style.decimal))
        self.remoteinfosize.stringValue = String(NumberFormatter.localizedString(from: NSNumber(value: size!.bytes/1024), number: NumberFormatter.Style.decimal))
    }

    // setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        self.seterrorinfo(info: "")
        if self.process != nil { self.abortOperations() }
        if self.readyforexecution == false { self.abortOperations() }
        self.readyforexecution = true
        self.info(num: 0)
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            self.index = index
            self.hiddenID = self.configurations!.gethiddenID(index: index)
            self.outputprocess = nil
            self.outputbatch = nil
            self.setNumbers(output: nil)
        } else {
            self.index = nil
        }
        self.process = nil
        self.singletask = nil
        self.showrclonecommandmainview()
        self.reloadtabledata()
        self.remoteinfo(reset: true)
    }

    func createandreloadschedules() {
        self.process = nil
        guard self.configurations != nil else {
            self.schedules = Schedules(profile: nil)
            return
        }
        if let profile = self.configurations!.getProfile() {
            self.schedules = nil
            self.schedules = Schedules(profile: profile)
        } else {
            self.schedules = nil
            self.schedules = Schedules(profile: nil)
        }
    }

    func createandreloadconfigurations() {
        guard self.configurations != nil else {
            self.configurations = Configurations(profile: nil)
            return
        }
        if let profile = self.configurations!.getProfile() {
            self.configurations = nil
            self.configurations = Configurations(profile: profile)
        } else {
            self.configurations = nil
            self.configurations = Configurations(profile: nil)
        }
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
        if self.allprofilesview {
            self.allprofiledetailsDelegate?.reloadtable()
        }
    }
}
