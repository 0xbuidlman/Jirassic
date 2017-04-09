//
//  SyncTasks.swift
//  Jirassic
//
//  Created by Cristian Baluta on 02/04/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation

class SyncTasks {
    
    fileprivate let localRepository: Repository!
    fileprivate let remoteRepository: Repository!
    fileprivate var tasksToSave = [Task]()
    fileprivate var tasksToDelete = [Task]()
    
    init (localRepository: Repository, remoteRepository: Repository) {
        self.localRepository = localRepository
        self.remoteRepository = remoteRepository
    }
    
    func start (_ completion: @escaping ((_ hasIncomingChanges: Bool) -> Void)) {
        
        tasksToSave = localRepository.queryUnsyncedTasks()
        RCLog("1. unsyncedTasks = \(self.tasksToSave.count)")
        localRepository.queryDeletedTasks { deletedTasks in
            RCLog("1. deletedTasks = \(deletedTasks.count)")
            self.tasksToDelete = deletedTasks
            self.syncNextTask { (success) in
                self.getLatestServerChanges(completion)
            }
        }
    }
    
    fileprivate func syncNextTask (_ completion: @escaping ((_ success: Bool) -> Void)) {
        
        var task = tasksToSave.first
        if task != nil {
            tasksToSave.remove(at: 0)
            saveTask(task!, completion: { (success) in
                self.syncNextTask(completion)
            })
        } else {
            task = tasksToDelete.first
            if task != nil {
                tasksToDelete.remove(at: 0)
                deleteTask(task!, completion: { (success) in
                    self.syncNextTask(completion)
                })
            } else {
                completion(true)
            }
        }
    }
    
    func saveTask (_ task: Task, completion: @escaping ((_ success: Bool) -> Void)) {
        
        RCLog("sync save \(task)")
        _ = remoteRepository.saveTask(task) { (uploadedTask) in
            // After task was saved to server update it to local datastore
            _ = self.localRepository.saveTask(uploadedTask, completion: { (task) in
                completion(true)
            })
        }
    }
    
    func deleteTask (_ task: Task, completion: @escaping ((_ success: Bool) -> Void)) {
        
        RCLog("sync delete \(task)")
        _ = remoteRepository.deleteTask(task, forceDelete: true) { (uploadedTask) in
            // After task was saved to server update it to local datastore
            _ = self.localRepository.deleteTask(task, forceDelete: true, completion: { (task) in
                completion(true)
            })
        }
    }
    
    func getLatestServerChanges (_ completion: @escaping ((_ hasIncomingChanges: Bool) -> Void)) {
        RCLog("2. getLatestServerChanges")
        remoteRepository.queryUpdates(sinceDate: Date(timeIntervalSince1970: 0)) { changedTasks, deletedTasksIds, error in
            for task in changedTasks {
                self.localRepository.saveTask(task, completion: { (task) in
                    RCLog("saved to local db")
                })
            }
            for remoteId in deletedTasksIds {
                self.localRepository.deleteTask(objectId: (local: nil, remote: remoteId), completion: { (success) in
                    RCLog(">>>>  deleted from local db: \(remoteId) \(success)")
                })
            }
            completion(changedTasks.count > 0 || deletedTasksIds.count > 0)
        }
    }
}
