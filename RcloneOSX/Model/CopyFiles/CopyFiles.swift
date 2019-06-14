//
//  CopyFiles.swift
//  rcloneOSX
//
//  Created by Thomas Evensen on 12/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  SwiftLint: OK 31 July 2017
//  swiftlint:disable line_length

import Foundation

final class CopyFiles: SetConfigurations {

    private var index: Int?
    private var config: Configuration?
    private var files: [String]?
    private var arguments: [String]?
    private var command: String?
    private var commandDisplay: String?
    var process: CommandCopyFiles?
    var outputprocess: OutputProcess?

    func getOutput() -> [String] {
        return self.outputprocess?.getOutput() ?? [""]
    }

    func abort() {
        guard self.process != nil else { return }
        self.process!.abortProcess()
    }

    func executeRclone(remotefile: String, localCatalog: String, dryrun: Bool) {
        guard self.config != nil else { return }
        if dryrun {
            self.arguments = CopyFileArguments(task: .restorerclone, config: self.config!, remotefile: remotefile, localCatalog: localCatalog).getArgumentsdryRun()
        } else {
            self.arguments = CopyFileArguments(task: .restorerclone, config: self.config!, remotefile: remotefile, localCatalog: localCatalog).getArguments()
        }
        self.command = nil
        self.outputprocess = nil
        self.outputprocess = OutputProcess()
        self.process = CommandCopyFiles(command: nil, arguments: self.arguments)
        self.process!.executeProcess(outputprocess: self.outputprocess)
    }

    func getCommandDisplayinView(remotefile: String, localCatalog: String) -> String {
        guard self.config != nil else { return "" }
        guard self.index != nil else { return "" }
        self.commandDisplay = Getrclonepath().rclonepath ?? "" + " " + CopyFileArguments(task: .restorerclone, config: self.config!, remotefile: remotefile, localCatalog: localCatalog).getcommandDisplay()
        return self.commandDisplay ?? " "
    }

    init (hiddenID: Int) {
        self.index = self.configurations?.getIndex(hiddenID)
        self.config = self.configurations!.getConfigurations()[self.index!]
    }

  }
