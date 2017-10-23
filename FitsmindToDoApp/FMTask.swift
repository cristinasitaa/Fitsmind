//
//  FMTask.swift
//  FitsmindToDoApp
//
//  Created by Cristina on 22/10/2017.
//  Copyright © 2017 Cristina. All rights reserved.
//

import RealmSwift

enum FMPriority : Int {
    case high
    case medium
    case low
    case unknown
  
    static func enumFromString(string:String) -> FMPriority? {
        var i = 0
        while let item = FMPriority(rawValue: i) {
            if String(describing: item) == string { return item }
            i += 1
        }
        return nil
    }
}


class FMTask: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var createdAt = NSDate()
    @objc dynamic var notes = ""
    @objc dynamic var isCompleted = false
    
    @objc dynamic var priorityRaw = 0

    var priority : FMPriority  {
        get {
            if let priority = FMPriority(rawValue: priorityRaw) {
                return priority
            }
            return .unknown
        }
        
        set {
            priorityRaw = newValue.rawValue
        }
    }
    
}
