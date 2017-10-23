//
//  DataManager.swift
//  FitsmindToDoApp
//
//  Created by Cristina on 22/10/2017.
//  Copyright © 2017 Cristina. All rights reserved.
//

import UIKit
import RealmSwift

class FMDataManager: NSObject {

    static let sharedInstance = FMDataManager()
    let realm = try! Realm()
    
    func getTasks() -> Results<FMTask> {
        return realm.objects(FMTask.self)
    }
    
    func deleteTask(taskToBeDeleted: FMTask) {
        try! realm.write{
            realm.delete(taskToBeDeleted)
        }
    }
    
    func addTask(newTask: FMTask) {
        try! realm.write{
            realm.add(newTask)
        }
    }
    
    func updateTask(updatedTask: FMTask, withName: String, andPriority: FMPriority) {
        try! realm.write{
            updatedTask.name = withName
            updatedTask.priority = andPriority
            updatedTask.priorityRaw = andPriority.rawValue
        }
    }
    
}
