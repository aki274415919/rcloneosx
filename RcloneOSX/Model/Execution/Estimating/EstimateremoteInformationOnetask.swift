//
//  EstimateRemoteInformationTask.swift
//  rcloneosx
//
//  Created by Thomas Evensen on 30.04.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

final class EstimateremoteInformationOnetask: SetConfigurations {

    init(index: Int, outputprocess: OutputProcess?) {
        let taskDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        let outDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain) as? ViewControllertabMain
        let arguments = self.configurations!.arguments4rclone(index: index, argtype: .argdryRun)
        let process = Rclone(arguments: arguments)
        process.executeProcess(outputprocess: outputprocess)
        taskDelegate?.getProcessReference(process: process.getProcess()!)
        outDelegate?.sendoutputprocessreference(outputprocess: outputprocess)
    }
}
