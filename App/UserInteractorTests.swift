//
//  UserInteractorTests.swift
//  Jirassic
//
//  Created by Cristian Baluta on 03/05/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import XCTest
@testable import Jirassic

class UserInteractorTests: XCTestCase {
    
    func testLogout() {
        
        let repository = InMemoryCoreDataRepository()
        
        let task = Task(dateEnd: NSDate(), type: TaskType.Issue)
        repository.saveTask(task) { (success) in
            
        }
        
        let tasks = repository.queryTasksInDay(NSDate())
        XCTAssert(tasks.count == 1, "We added one task, we should receive one task")
        
        UserInteractor(data: repository).logout()
        
        let tasksAfterLogout = repository.queryTasksInDay(NSDate())
        XCTAssert(tasksAfterLogout.count == 0, "After logging out there should be no task left")
    }
}
