//
//  NewTaskViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 06/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class NewTaskViewController: NSViewController {
    
    @IBOutlet fileprivate weak var taskTypeSegmentedControl: NSSegmentedControl!
	@IBOutlet fileprivate weak var issueIdTextField: NSTextField!
	@IBOutlet fileprivate weak var notesTextField: NSTextField!
	@IBOutlet fileprivate weak var endDateTextField: NSTextField!
    @IBOutlet fileprivate weak var startDateTextField: NSTextField!
    @IBOutlet fileprivate weak var startDateButton: NSButton!
	
	var onSave: ((_ taskData: TaskCreationData) -> Void)?
	var onCancel: ((Void) -> Void)?
    fileprivate var activeEditingTextFieldContent = ""
    fileprivate var issueTypes = [String]()
    fileprivate let predictor = PredictiveTimeTyping()
    fileprivate let localPreferences = RCPreferences<LocalPreferences>()
	
    var dateStart: Date? {
        get {
            if localPreferences.bool(.useDuration) {
                return self.duration > 0 ? self.dateEnd.addingTimeInterval(-self.duration) : nil
            } else {
                if self.startDateTextField!.stringValue == "" {
                    return nil
                }
                let hm = Date.parseHHmm(self.startDateTextField!.stringValue)
                return self.initialDate.dateByUpdating(hour: hm.hour, minute: hm.min)
            }
        }
        set {
            if let startDate = newValue {
                self.startDateTextField?.stringValue = startDate.HHmm()
            }
        }
    }
    var initialDate = Date()
	var dateEnd: Date {
		get {
            let hm = Date.parseHHmm(self.endDateTextField!.stringValue)
            return self.initialDate.dateByUpdating(hour: hm.hour, minute: hm.min)
		}
		set {
            self.initialDate = newValue
            self.endDateTextField?.stringValue = newValue.HHmm()
            self.estimateTaskType()
		}
	}
    var duration: TimeInterval {
        get {
            if self.startDateTextField!.stringValue == "" {
                return 0.0
            }
            let hm = Date.parseHHmm(self.startDateTextField!.stringValue)
            return Double(hm.min).minToSec + Double(hm.hour).hoursToSec
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
	
    override func viewDidLoad() {
        super.viewDidLoad()
        taskTypeSegmentedControl.selectedSegment = 0
        setupStartDateButtonTitle()
    }
    
    fileprivate func selectedTaskSubtype() -> TaskSubtype {
        
        switch taskTypeSegmentedControl.selectedSegment {
            case 0: return .issueEnd
            case 1: return .scrumEnd
            case 2: return .meetingEnd
            case 3: return .lunchEnd
            case 4: return .wasteEnd
            case 5: return .learningEnd
            case 6: return .coderevEnd
            default: return .issueEnd
        }
    }
    
    fileprivate func selectedTaskType() -> TaskType {
        
        switch taskTypeSegmentedControl.selectedSegment {
            case 0: return .issue
            case 1: return .scrum
            case 2: return .meeting
            case 3: return .lunch
            case 4: return .waste
            case 5: return .learning
            case 6: return .coderev
            default: return .issue
        }
    }
    
    fileprivate func estimateTaskType() {
        
        let typeEstimator = TaskTypeEstimator()
        let settings = SettingsInteractor().getAppSettings()
        let estimatedType: TaskType = typeEstimator.taskTypeAroundDate(initialDate, withSettings: settings)
        if estimatedType == .scrum {
            taskTypeSegmentedControl.selectedSegment = 1
            handleSegmentedControl(taskTypeSegmentedControl)
            
            let settingsScrumTime = gregorian.dateComponents(ymdhmsUnitFlags, from: settings.scrumTime)
            self.dateStart = self.initialDate.dateByUpdating(hour: settingsScrumTime.hour!, minute: settingsScrumTime.minute!)
        }
    }
    
    fileprivate func setupStartDateButtonTitle() {
        startDateButton.title = localPreferences.bool(.useDuration) ? "Duration:" : "Started at:"
    }
}

extension NewTaskViewController: NSTextFieldDelegate {
    
    override func controlTextDidBeginEditing (_ obj: Notification) {
        
        if let textField = obj.object as? NSTextField {
            guard textField == endDateTextField || textField == startDateTextField else {
                return
            }
            activeEditingTextFieldContent = textField.stringValue
        }
    }
    
    override func controlTextDidChange (_ obj: Notification) {
        
        if let textField = obj.object as? NSTextField {
            guard textField == endDateTextField || textField == startDateTextField else {
                return
            }
            let comps = textField.stringValue.characters.map { String($0) }
            let newDigit = activeEditingTextFieldContent.characters.count > comps.count ? "" : comps.last
            activeEditingTextFieldContent = predictor.timeByAdding(newDigit!, to: activeEditingTextFieldContent)
            textField.stringValue = activeEditingTextFieldContent
        }
    }
}

extension NewTaskViewController {
    
    @IBAction func handleSegmentedControl (_ sender: NSSegmentedControl) {
        
        let subtype = selectedTaskSubtype()
        issueIdTextField.stringValue = subtype.defaultTaskNumber ?? ""
        notesTextField.stringValue = subtype.defaultNotes
        issueIdTextField.isEnabled = sender.selectedSegment == 0
    }
    
    @IBAction func handleSaveButton (_ sender: NSButton) {
        
        let taskData = TaskCreationData(
            dateStart: self.dateStart,
            dateEnd: self.dateEnd,
            taskNumber: self.taskNumber,
            notes: self.notes,
            taskType: selectedTaskType()
        )
        self.onSave?(taskData)
    }
    
    @IBAction func handleCancelButton (_ sender: NSButton) {
        self.onCancel?()
    }
    
    @IBAction func handleDurationButton (_ sender: NSButton) {
        
        localPreferences.set(!localPreferences.bool(.useDuration), forKey: .useDuration)
        setupStartDateButtonTitle()
    }
}

extension NewTaskViewController {
    
    override func mouseDown(with event: NSEvent) {
        RCLog(event)
    }
}
