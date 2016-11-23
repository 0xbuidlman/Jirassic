//
//  NewTaskViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 06/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class NewTaskViewController: NSViewController {
    
    @IBOutlet fileprivate var taskTypeSegmentedControl: NSSegmentedControl?
	@IBOutlet fileprivate var issueIdTextField: NSTextField?
	@IBOutlet fileprivate var notesTextField: NSTextField?
	@IBOutlet fileprivate var endDateTextField: NSTextField?
	@IBOutlet fileprivate var durationTextField: NSTextField?
	
	var onOptionChosen: ((_ taskData: TaskCreationData) -> Void)?
	var onCancelChosen: ((Void) -> Void)?
    fileprivate var _dateEnd = ""
    fileprivate var issueTypes = [String]()
	
	// Sets the end date of the task to the UI picker. It can be edited and requested back
	var dateEnd: Date {
		get {
			let hm = Date.parseHHmm(self.endDateTextField!.stringValue)
			return Date().dateByUpdating(hour: hm.hour, minute: hm.min)
		}
		set {
			self.endDateTextField?.stringValue = newValue.HHmm()
		}
	}
    var duration: TimeInterval {
        get {
            if self.durationTextField!.stringValue == "" {
                return 0.0
            }
            let hm = Date.parseHHmm(self.durationTextField!.stringValue)
            return Double(hm.min * 60 + hm.hour * 3600)
        }
    }
	var notes: String {
		get {
			return notesTextField!.stringValue
		}
		set {
			self.notesTextField?.stringValue = newValue
		}
	}
	var taskNumber: String {
		get {
			return issueIdTextField!.stringValue
		}
		set {
			self.issueIdTextField?.stringValue = newValue
		}
	}
	
    func setTaskDataWithTaskType (_ taskSubtype: TaskSubtype) {
        
        let taskData = TaskCreationData(
            dateStart: self.duration > 0 ? self.dateEnd.addingTimeInterval(-self.duration) : nil,
            dateEnd: self.dateEnd,
            taskNumber: self.taskNumber,
            notes: self.notes
        )
        self.onOptionChosen?(taskData)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskTypeSegmentedControl?.selectedSegment = 0
    }
    
    override func viewDidLayout() {
        
    }
    
    fileprivate func taskSubtype() -> TaskSubtype {
        
        switch taskTypeSegmentedControl!.selectedSegment {
            case 0: return .issueEnd
            case 1: return .scrumEnd
            case 2: return .meetingEnd
            case 3: return .lunchEnd
            default: return .issueEnd
        }
    }
}

extension NewTaskViewController: NSTextFieldDelegate {
    
    override func controlTextDidBeginEditing (_ obj: Notification) {
        
        if let textField = obj.object as? NSTextField {
            guard textField == endDateTextField || textField == durationTextField else {
                return
            }
            _dateEnd = textField.stringValue
        }
    }
    
    override func controlTextDidChange (_ obj: Notification) {
        
        if let textField = obj.object as? NSTextField {
            guard textField == endDateTextField || textField == durationTextField else {
                return
            }
            let predictor = PredictiveTimeTyping()
            let comps = textField.stringValue.components(separatedBy: _dateEnd)
            let newDigit = (comps.count == 1 && _dateEnd != "") ? "" : comps.last
            _dateEnd = predictor.timeByAdding(newDigit!, to: _dateEnd)
            textField.stringValue = _dateEnd
        }
    }
}

extension NewTaskViewController {
    
    @IBAction func handleSegmentedControl (_ sender: NSSegmentedControl) {
        
        let subtype = taskSubtype()
        switch subtype {
        case .issueEnd:
            issueIdTextField?.stringValue = ""
            break
        case .scrumEnd:
            issueIdTextField?.stringValue = "scrum"
            break
        case .meetingEnd:
            issueIdTextField?.stringValue = "meeting"
            break
        case .lunchEnd:
            issueIdTextField?.stringValue = "lunch"
            break
        case .gitCommitEnd:
            
            break
        }
    }
    
    @IBAction func handleSaveButton (_ sender: NSButton) {
        
        let subtype = taskSubtype()
        RCLogO(subtype)
        setTaskDataWithTaskType(subtype)
    }
    
    @IBAction func handleCancelButton (_ sender: NSButton) {
        self.onCancelChosen?()
    }
}
