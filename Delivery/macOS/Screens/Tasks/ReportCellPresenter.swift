//
//  ReportCellPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 06/11/2016.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Cocoa

class ReportCellPresenter: NSObject {
    
    var cell: CellProtocol?
    
    convenience init (cell: CellProtocol) {
        self.init()
        self.cell = cell
    }
    
    func present (theReport: Report) {
        
        cell?.data = (
            dateEnd: Date(),
            taskNumber: theReport.taskNumber,
            notes: theReport.notes
        )
        cell?.duration = Date(timeIntervalSince1970: theReport.duration).HHmmGMT()
        cell?.statusImage?.image = NSImage(named: NSImageNameStatusAvailable)
    }
}
