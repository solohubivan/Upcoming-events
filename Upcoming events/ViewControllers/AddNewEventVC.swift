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
    private var eventsManager: EventsManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setInitialDatePickers()
    }
    
    // MARK: - Public methods
    
    func setEventsManager(_ manager: EventsManager) {
        self.eventsManager = manager
    }
    
    // MARK: - Buttons actions
    
    @objc private func addNewEvent() {
        guard let eventTitle = eventTitleTextField.text, !eventTitle.isEmpty else {
            showAlertForEmptyTitle()
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
        showAlertForAdded(newEvent: newEvent)
    }
    
    // MARK: - Private methods
    
    private func setInitialDatePickers() {
        let now = Date()
        startDatePicker.date = now
        let fifteenMinutesLater = Calendar.current.date(byAdding: .minute, value: 15, to: now)
        endDatePicker.date = fifteenMinutesLater ?? now
    }
    
    private func showAlertForEmptyTitle() {
        let alert = UIAlertController(title: AppConstants.AlertMessages.titleEnterEventTitlePls, message: nil, preferredStyle: .alert)
        present(alert, animated: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    private func showAlertForAdded(newEvent: EventModel) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
            
        let startDateStr = dateFormatter.string(from: newEvent.startDate)
        let endDateStr = dateFormatter.string(from: newEvent.endDate)

        let message = "\(AppConstants.AlertMessages.messageEventsStart): \(startDateStr)\n\(AppConstants.AlertMessages.messageEventsEnd): \(endDateStr)"
            
        let alert = UIAlertController(title: "\(AppConstants.AlertMessages.titleEvent) \"\(newEvent.title)\" \(AppConstants.AlertMessages.titleAdded)", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: AppConstants.ButtonTitles.ok, style: .default, handler: nil)
        alert.addAction(okAction)
            
        present(alert, animated: true, completion: nil)
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
        titleLabel.font = .customFont(name: AppConstants.Fonts.poppinsSemiBold, size: 24, textStyle: .title1)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.text = AppConstants.AddNewEventVC.titleLabelText
        view.addSubview(titleLabel)
    }
    
    private func setupEventTitleTF() {
        eventTitleTextField.delegate = self
        eventTitleTextField.borderStyle = .none
        eventTitleTextField.layer.cornerRadius = 10
        eventTitleTextField.layer.backgroundColor = UIColor.white.cgColor
        eventTitleTextField.font = UIFont.customFont(name: AppConstants.Fonts.poppinsRegular, size: 18, textStyle: .body)
        eventTitleTextField.placeholder = AppConstants.AddNewEventVC.tFPlaceholderText
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
        startDateLabel.text = AppConstants.AddNewEventVC.startDateLabelText
        startDateLabel.font = .customFont(name: AppConstants.Fonts.poppinsMedium, size: 18, textStyle: .body)
        startDateLabel.adjustsFontForContentSizeCategory = true
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
        endDateLabel.text = AppConstants.AddNewEventVC.endDateLabelText
        endDateLabel.font = .customFont(name: AppConstants.Fonts.poppinsMedium, size: 18, textStyle: .body)
        endDateLabel.adjustsFontForContentSizeCategory = true
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
        addEventButton.setTitle(AppConstants.ButtonTitles.createNewEvent, for: .normal)
        addEventButton.setTitleColor(.white, for: .normal)
        addEventButton.titleLabel?.font = UIFont.customFont(name: AppConstants.Fonts.poppinsRegular, size: 18, textStyle: .body)
        addEventButton.backgroundColor = .violet
        addEventButton.layer.cornerRadius = 6
        addEventButton.addTarget(self, action: #selector(addNewEvent), for: .touchUpInside)
        view.addSubview(addEventButton)
    }
    
    // MARK: - Setup Constraints
    
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
