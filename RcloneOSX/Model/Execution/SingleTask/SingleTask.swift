//
//  NewSingleTask.swift
//  rcloneOSX
//
//  Created by Thomas Evensen on 20.06.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable line_length

import Foundation

// Protocols for instruction start/stop progressviewindicator
protocol StartStopProgressIndicatorSingleTask: class {
    func startIndicator()
    func stopIndicator()
}

// Protocol functions implemented in main view
protocol SingleTaskProgress: class {
    func presentViewProgress()
    func presentViewInformation(outputprocess: OutputProcess)
    func terminateProgressProcess()
    func seterrorinfo(info: String)
    func setNumbers(output: OutputProcess?)
    func gettransferredNumber() -> String
    func gettransferredNumberSizebytes() -> String
    func getProcessReference(process: Process)
}

final class SingleTask: SetSchedules, SetConfigurations {

    // Delegate function for start/stop progress Indicator in BatchWindow
    weak var indicatorDelegate: StartStopProgressIndicatorSingleTask?
    // Delegate functions for kicking of various updates (informal) during
    // process task in main View
    weak var taskDelegate: SingleTaskProgress?
    // Reference to Process task
    var process: Process?
    // Index to selected row, index is set when row is selected
    private var index: Int?
    // Getting output from rclone
    var outputprocess: OutputProcess?
    // Holding max count
    private var maxcount: Int = 0
    // Single task work queu
    private var workload: SingleTaskWorkQueu?
    // Ready for execute again
    private var ready: Bool = true
    // Single task can be activated by double click from table
    func executeSingleTask() {

        if self.workload == nil {
            self.workload = SingleTaskWorkQueu()
        }
        let arguments: [String]?
        switch self.workload!.peek() {
        case .estimatesinglerun:
            if let index = self.index {
                self.indicatorDelegate?.startIndicator()
                arguments = self.configurations!.arguments4rclone(index: index, argtype: .argdryRun)
                let process = Rclone(arguments: arguments)
                self.outputprocess = OutputProcess()
                process.executeProcess(outputprocess: self.outputprocess)
                self.process = process.getProcess()
                self.taskDelegate?.getProcessReference(process: self.process!)
            }
        case .executesinglerun:
            if let index = self.index {
                self.taskDelegate?.presentViewProgress()
                arguments = self.configurations!.arguments4rclone(index: index, argtype: .arg)
                self.outputprocess = OutputProcess()
                let process = Rclone(arguments: arguments)
                process.executeProcess(outputprocess: self.outputprocess)
                self.process = process.getProcess()
                self.taskDelegate?.getProcessReference(process: self.process!)
                self.taskDelegate?.seterrorinfo(info: "")
            }
        case .abort:
            self.workload = nil
            self.taskDelegate?.seterrorinfo(info: "Abort")
        case .empty:
            self.workload = nil
        default:
            self.workload = nil
        }
    }

    func processTermination() {
        self.ready = true
        if let workload = self.workload {
            switch workload.pop() {
            case .estimatesinglerun:
                self.indicatorDelegate?.stopIndicator()
                self.taskDelegate?.setNumbers(output: self.outputprocess)
                self.maxcount = self.outputprocess!.getMaxcount()
                self.taskDelegate?.presentViewInformation(outputprocess: self.outputprocess!)
            case .error:
                self.indicatorDelegate?.stopIndicator()
                self.taskDelegate?.presentViewInformation(outputprocess: self.outputprocess!)
                self.workload = nil
            case .executesinglerun:
                self.taskDelegate?.terminateProgressProcess()
                self.taskDelegate?.presentViewInformation(outputprocess: self.outputprocess!)
                if self.configurations!.getConfigurations()[self.index!].task != ViewControllerReference.shared.check {
                    self.configurations!.setCurrentDateonConfiguration(index: self.index!, outputprocess: outputprocess)
                }
            case .empty:
                self.workload = nil
            default:
                self.workload = nil
            }
        }
    }

    // Put error token ontop of workload
    func error() {
        guard self.workload != nil else {
            return
        }
        self.workload!.error()
    }

    init(index: Int) {
        self.index = index
        self.indicatorDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        self.taskDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
    }
}

// Counting
extension SingleTask: Count {

    // Maxnumber of files counted
    func maxCount() -> Int {
        return self.maxcount
    }

    // Counting number of files
    // Function is called when Process discover FileHandler notification
    func inprogressCount() -> Int {
        guard self.outputprocess != nil else {
            return 0
        }
        return self.outputprocess!.count()
    }

}
