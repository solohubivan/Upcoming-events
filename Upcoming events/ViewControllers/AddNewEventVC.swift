//
//  AddNewEventVC.swift
//  Upcoming events
//
//  Created by Ivan Solohub on 11.09.2024.
//

import UIKit

class AddNewEventVC: UIViewController {
    
    private var titleLabel = UILabel()
    private var eventTitleTextField = UITextField()
    private var startDateLabel = UILabel()
    private var startDatePicker = UIDatePicker()
    private var endDateLabel = UILabel()
    private var endDatePicker = UIDatePicker()
    private var addEventButton = UIButton()
    
    private var addedEvents: [EventModel] = []
    
//    private var eventManager = EventsManager()
    var eventsManager: EventsManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setInitialDatePickers()
    }
    
    // MARK: - Buttons actions
    
    @objc private func addNewEvent() {
        guard let eventTitle = eventTitleTextField.text, !eventTitle.isEmpty else {
//            showAlertForEmptyTitle()
            return
        }
        
        if endDatePicker.date <= startDatePicker.date {
            let newEndDate = Calendar.current.date(byAdding: .minute, value: 15, to: startDatePicker.date)
            endDatePicker.date = newEndDate ?? startDatePicker.date
        }
            
        let newEvent = EventModel(
            title: eventTitle,
            startDate: startDatePicker.date,
            endDate: endDatePicker.date
        )
        
        eventsManager?.addEvent(newEvent)
        
        dismissKeyboard()
        eventTitleTextField.text = ""
        setInitialDatePickers()
        
//        dismiss(animated: true, completion: nil)
        print(eventsManager?.getEvents() ?? "щось не ок")
    }
    
    // MARK: - Private methods
    
    private func setInitialDatePickers() {
        let now = Date()
        startDatePicker.date = now
        let fifteenMinutesLater = Calendar.current.date(byAdding: .minute, value: 15, to: now)
        endDatePicker.date = fifteenMinutesLater ?? now
    }
}

// MARK: - TextField delegate

extension AddNewEventVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location == 0 && string == " " {
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Setup UI

extension AddNewEventVC {
    private func setupUI() {
        setupBackGroundColor()
        setupTitleLabel()
        setupEventTitleTF()
        setupStartDateLabel()
        setupStartDatePicker()
        setupEndDateLabel()
        setupEndDatePicker()
        setupAddEventButton()
        setupConstraints()
    }
    
    private func setupBackGroundColor() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurView)
    }
    
    private func setupTitleLabel() {
        titleLabel.textColor = .black
        titleLabel.font = UIFont(name: "Poppins-SemiBold", size: 24)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.text = "Create new event here"
        view.addSubview(titleLabel)
    }
    
    private func setupEventTitleTF() {
        eventTitleTextField.delegate = self
        eventTitleTextField.borderStyle = .none
        eventTitleTextField.layer.cornerRadius = 10
        eventTitleTextField.layer.backgroundColor = UIColor.white.cgColor
        eventTitleTextField.textColor = .black
        eventTitleTextField.font = UIFont(name: "Poppins-Regular", size: 18)
        eventTitleTextField.placeholder = "Enter the event title here"
        eventTitleTextField.overrideUserInterfaceStyle = .light
        placeholderIndent()
        view.addSubview(eventTitleTextField)
    }
    
    private func placeholderIndent() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: Int(eventTitleTextField.frame.height)))
        eventTitleTextField.leftView = paddingView
        eventTitleTextField.leftViewMode = .always
    }
    
    private func setupStartDateLabel() {
        startDateLabel.text = "Start date:"
        startDateLabel.font = UIFont(name: "Poppins-Medium", size: 18)
        startDateLabel.textColor = .black
        startDateLabel.textAlignment = .left
        view.addSubview(startDateLabel)
    }
    
    private func setupStartDatePicker() {
        startDatePicker.datePickerMode = .dateAndTime
        startDatePicker.preferredDatePickerStyle = .compact
        view.addSubview(startDatePicker)
    }
    
    private func setupEndDateLabel() {
        endDateLabel.text = "End date:"
        endDateLabel.font = UIFont(name: "Poppins-Medium", size: 18)
        endDateLabel.textColor = .black
        endDateLabel.textAlignment = .left
        view.addSubview(endDateLabel)
    }
    
    private func setupEndDatePicker() {
        endDatePicker.datePickerMode = .dateAndTime
        endDatePicker.preferredDatePickerStyle = .compact
        view.addSubview(endDatePicker)
    }
    
    private func setupAddEventButton() {
        addEventButton.setTitle("Create new event", for: .normal)
        addEventButton.setTitleColor(.white, for: .normal)
        addEventButton.titleLabel?.font = UIFont(name: "Poppins-Regular", size: 18)
        addEventButton.backgroundColor = .hex5856D6
        addEventButton.layer.cornerRadius = 6
        addEventButton.addTarget(self, action: #selector(addNewEvent), for: .touchUpInside)
        view.addSubview(addEventButton)
    }
    
    private func setupConstraints() {
        titleLabel.addConstraints(to_view: view, [
            .top(anchor: view.topAnchor, constant: 10),
            .leading(anchor: view.leadingAnchor, constant: 16),
            .trailing(anchor: view.trailingAnchor, constant: 16),
            .height(constant: 40)
        ])
        
        eventTitleTextField.addConstraints(to_view: view, [
            .top(anchor: titleLabel.bottomAnchor, constant: 20),
            .leading(anchor: view.leadingAnchor, constant: 16),
            .trailing(anchor: view.trailingAnchor, constant: 16),
            .height(constant: 48)
        ])
        
        startDateLabel.addConstraints(to_view: view, [
            .top(anchor: eventTitleTextField.bottomAnchor, constant: 30),
            .leading(anchor: view.leadingAnchor, constant: 16),
            .width(constant: 120),
            .height(constant: 40)
        ])
        
        startDatePicker.addConstraints(to_view: view, [
            .top(anchor: eventTitleTextField.bottomAnchor, constant: 30),
            .leading(anchor: startDateLabel.trailingAnchor, constant: 10),
            .trailing(anchor: view.trailingAnchor, constant: 16),
            .height(constant: 40)
        ])
        
        endDateLabel.addConstraints(to_view: view, [
            .top(anchor: startDateLabel.bottomAnchor, constant: 20),
            .leading(anchor: view.leadingAnchor, constant: 16),
            .width(constant: 120),
            .height(constant: 40)
        ])
        
        endDatePicker.addConstraints(to_view: view, [
            .top(anchor: startDatePicker.bottomAnchor, constant: 20),
            .leading(anchor: endDateLabel.trailingAnchor, constant: 10),
            .trailing(anchor: view.trailingAnchor, constant: 16),
            .height(constant: 40)
        ])
        
        addEventButton.addConstraints(to_view: view, [
            .top(anchor: endDateLabel.bottomAnchor, constant: 40),
            .leading(anchor: view.leadingAnchor, constant: 16),
            .trailing(anchor: view.trailingAnchor, constant: 16),
            .height(constant: 40)
        ])
    }
}
