//
//  PersistentStoreageUserconfiguration.swift
//  rcloneOSX
//
//  Created by Thomas Evensen on 26/10/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//

import Foundation

final class PersistentStorageUserconfiguration: ReadWriteDictionary {
    // Saving user configuration
    func saveuserconfiguration() {
        if let array: [NSDictionary] = ConvertUserconfiguration().userconfiguration {
            self.writeToStore(array: array)
        }
    }

    // func read userconfiguration
    func readuserconfiguration() -> [NSDictionary]? {
        return self.readNSDictionaryFromPersistentStore()
    }

    // Writing configuration to persistent store
    // Configuration is [NSDictionary]
    private func writeToStore(array: [NSDictionary]) {
        // Getting the object just for the write method, no read from persistent store
        _ = self.writeNSDictionaryToPersistentStorage(array: array)
    }

    init() {
        super.init(whattoreadwrite: .userconfig, profile: nil, configpath: ViewControllerReference.shared.configpath)
    }
}
