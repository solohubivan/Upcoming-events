//
//  CustomContainerView.swift
//  Upcoming events
//
//  Created by Ivan Solohub on 24.08.2024.
//

import UIKit
import EventKit
import FSCalendar

enum TimeMode {
    case am
    case pm
}

class CustomContainerView: UIView {
    
    private var scrollView = UIScrollView()
    private var contentView = UIView()
    private var selectDataView = TouchPassthroughView()
    private var currentMonthLabel = UILabel()
    private var timeTitleLabel = UILabel()
    private var selectTimeButton = UIButton()
    private var timeModeSegmCntrl = UISegmentedControl()
    private var customPeriodEventsLabel = UILabel()
    private var presentEventsTable = UITableView()
    private var timePicker = UIDatePicker()
    
    private var toolBar = UIToolbar()
    private var calendar = FSCalendar()
    private var eventsManager = EventsManager()
    private let eventStore = EKEventStore()
    private var events: [EventModel] = []
    private var tableData: [EventModel] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - objc methods
    
    @objc private func donePressed() {
        guard let selectedDate = calendar.selectedDate else { return }
        let selectedTime = timePicker.date
        
        var selectedDateTimeComponents = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
        let selectedTimeComponents = Calendar.current.dateComponents([.hour, .minute], from: selectedTime)
        selectedDateTimeComponents.hour = selectedTimeComponents.hour
        selectedDateTimeComponents.minute = selectedTimeComponents.minute
        
        guard let combinedDateTime = Calendar.current.date(from: selectedDateTimeComponents) else { return }
        let filteredEvents = filterEvents(after: combinedDateTime)

        self.tableData = filteredEvents
        presentEventsTable.reloadData()
        
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene, let window = windowScene.windows.first {
            if let overlayView = window.viewWithTag(1001) {
                overlayView.removeFromSuperview()
            }
        }
    }
    
    private func filterEvents(after selectedDateTime: Date) -> [EventModel] {
        var filteringEvents = self.events
        for event in filteringEvents {
            let beginEvent = event.startDate
            if beginEvent > selectedDateTime {
                if let index = filteringEvents.firstIndex(where: { $0.startDate == beginEvent }) {
                    filteringEvents.remove(at: index)
                }
            }
        }
        return filteringEvents
    }
    
    
    @objc private func nextMonthButtonTapped() {
        guard let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: calendar.currentPage) else { return }
        calendar.setCurrentPage(nextMonth, animated: true)
    }

    @objc private func previousMonthButtonTapped() {
        guard let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: calendar.currentPage) else { return }
        calendar.setCurrentPage(previousMonth, animated: true)
    }
    
    @objc private func updateTimeButton() {
        selectTimeButton.setTitle(eventsManager.createClockTimeLabel(object: timeModeSegmCntrl), for: .normal)
    }
    
    @objc private func openTimePicker() {
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let window = windowScene.windows.first {
            let overlayView = UIView(frame: window.bounds)
            overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            overlayView.tag = 1001

            overlayView.addSubview(timePicker)
            overlayView.addSubview(toolBar)
            
            toolBar.addConstraints(to_view: overlayView, [
                .leading(anchor: overlayView.leadingAnchor, constant: 0),
                .trailing(anchor: overlayView.trailingAnchor, constant: 0),
                .bottom(anchor: timePicker.topAnchor, constant: 0),
                .height(constant: 35)
            ])
            timePicker.addConstraints(to_view: overlayView, [
                .leading(anchor: overlayView.leadingAnchor, constant: 0),
                .trailing(anchor: overlayView.trailingAnchor, constant: 0),
                .bottom(anchor: overlayView.bottomAnchor, constant: 0),
                .height(constant: 210)
            ])
            
            window.addSubview(overlayView)
        }
    }
    
    // MARK: - Public methods

    func configureCustomEvents(with manager: EventsManager) {
        self.eventsManager = manager
        let eventsForDay = manager.getEvents(for: .day, value: 1)
        self.events = eventsForDay
        self.tableData = eventsForDay
        updateСustomEvents(eventsForDay)
    }
    
    // MARK: - Private methods
    
    private func updateMonthLabel(for date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        let monthString = dateFormatter.string(from: date)

        let monthAttributedString = NSAttributedString(string: monthString, attributes: [
            .font: UIFont(name: "Poppins-Semibold", size: 20) ?? UIFont.systemFont(ofSize: 20),
            .foregroundColor: UIColor.hex5856D6
        ])

        let chevronImage = UIImage(systemName: "chevron.right")?.withTintColor(.hex5856D6, renderingMode: .alwaysOriginal)
        
        let chevronAttachment = NSTextAttachment()
        chevronAttachment.image = chevronImage
        chevronAttachment.bounds = CGRect(x: 0, y: 0, width: 14, height: 14)
        
        let chevronAttributedString = NSAttributedString(attachment: chevronAttachment)

        let combinedAttributedString = NSMutableAttributedString()
        combinedAttributedString.append(monthAttributedString)
        combinedAttributedString.append(NSAttributedString(string: " "))
        combinedAttributedString.append(chevronAttributedString)

        currentMonthLabel.attributedText = combinedAttributedString
    }
    
    private func updateСustomEvents(_ newEvents: [EventModel]) {
        self.tableData = newEvents
        presentEventsTable.reloadData()
    }
//  В логіку
    private func updateCustomPeriodLabel(from startDate: Date, to endDate: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"

        let startDateString = dateFormatter.string(from: startDate)
        let endDateString = dateFormatter.string(from: endDate)
            
        let calendar = Calendar.current
        let startYear = calendar.component(.year, from: startDate)
        let endYear = calendar.component(.year, from: endDate)
            
        if startYear == endYear {
            customPeriodEventsLabel.text = "\(startDateString) - \(endDateString), \(startYear)"
        } else {
            customPeriodEventsLabel.text = "\(startDateString), \(startYear) - \(endDateString), \(endYear)"
        }
    }
}

// MARK: - UITableView delegate

extension CustomContainerView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? CustomTableViewCell ?? CustomTableViewCell()
        let event = tableData[indexPath.row]
        cell.configureCell(with: event)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - FSCalendarDelegate

extension CustomContainerView: FSCalendarDataSource, FSCalendarDelegate {
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        updateMonthLabel(for: calendar.currentPage)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let today = Calendar.current.startOfDay(for: Date())
        let selectedDay = Calendar.current.startOfDay(for: date)
        let numberOfDays = Calendar.current.dateComponents([.day], from: today, to: selectedDay).day ?? 0
        
        if numberOfDays < 0 {
            customPeriodEventsLabel.text = "Please select a date up today :)"
            self.tableData = []
            presentEventsTable.reloadData()
        } else {
            updateCustomPeriodLabel(from: Date(), to: date)

            eventsManager.fetchEvents(for: .day, value: numberOfDays + 1) { [weak self] in
                DispatchQueue.main.async {
                    self?.events = self?.eventsManager.getEvents(for: .day, value: numberOfDays + 1) ?? []
                    self?.tableData = self?.eventsManager.getEvents(for: .day, value: numberOfDays + 1) ?? []
                    self?.presentEventsTable.reloadData()
                }
            }
        }
    }
}

// MARK: - Setup UI

extension CustomContainerView {
    private func setupUI() {
        self.backgroundColor = .white
        setupScrollView()
        setupContentView()
        setupSelectDateView()
        setupMonthLabel()
        setupLeftRightButtons()
        setupCalendar()
        setupTimeTitleLabel()
        setupTimeModeSegmCntrl()
        setupSelectTimeButton()
        setupCustomPeriodEventsLabel()
        setupTable()
        setupTimePicker()
        setupConstraints()
    }
    
    private func setupScrollView() {
        scrollView.backgroundColor = .clear
        self.addSubview(scrollView)
    }
    
    private func setupContentView() {
        contentView.backgroundColor = .white
        scrollView.addSubview(contentView)
    }
    
    private func setupSelectDateView() {
        selectDataView.backgroundColor = .white
        selectDataView.applyShadow()
        self.addSubview(selectDataView)
    }

    private func setupMonthLabel() {
        updateCustomPeriodLabel(from: Date(), to: Date())
        currentMonthLabel.font = UIFont(name: "Poppins-Semibold", size: 20)
        currentMonthLabel.textColor = .hex5856D6
        currentMonthLabel.textAlignment = .left
        selectDataView.addSubview(currentMonthLabel)
    }
    
    private func setupLeftRightButtons() {
        let rightButton = UIButton()
        let rightButtonImage = UIImage(named: "rightChevron")
        rightButton.setImage(rightButtonImage, for: .normal)
        rightButton.imageView?.contentMode = .scaleAspectFit
        rightButton.tintColor = .hex5856D6
        
        let leftButton = UIButton()
        let leftButtonImage = UIImage(named: "leftChevron")
        leftButton.setImage(leftButtonImage, for: .normal)
        leftButton.imageView?.contentMode = .scaleAspectFit
        leftButton.tintColor = .hex5856D6
        
        selectDataView.addSubview(rightButton)
        selectDataView.addSubview(leftButton)
        
        rightButton.addConstraints(to_view: selectDataView, [
            .top(anchor: selectDataView.topAnchor, constant: 16),
            .trailing(anchor: selectDataView.trailingAnchor, constant: 16),
            .width(constant: 24),
            .height(constant: 24)
        ])
        leftButton.addConstraints(to_view: selectDataView, [
            .top(anchor: selectDataView.topAnchor, constant: 16),
            .trailing(anchor: selectDataView.trailingAnchor, constant: 60),
            .width(constant: 24),
            .height(constant: 24)
        ])
        
        rightButton.addTarget(self, action: #selector(nextMonthButtonTapped), for: .touchUpInside)
        leftButton.addTarget(self, action: #selector(previousMonthButtonTapped), for: .touchUpInside)
    }
    
    private func setupCalendar() {
        calendar.dataSource = self
        calendar.delegate = self
        calendar.scrollEnabled = true
        calendar.placeholderType = .none
        calendar.headerHeight = 0
        
        calendar.appearance.selectionColor = UIColor.hex5856D6
        calendar.appearance.weekdayFont = UIFont(name: "Poppins-Semibold", size: 16)
        calendar.appearance.weekdayTextColor = UIColor.hex3C3C434D
        calendar.appearance.caseOptions = [.weekdayUsesUpperCase]
        calendar.appearance.titleFont = UIFont(name: "Poppins-Regular", size: 18)
        calendar.appearance.titleDefaultColor = .hex5856D6
        self.addSubview(calendar)
    }
    
    private func setupTimeTitleLabel() {
        timeTitleLabel.text = "Time"
        timeTitleLabel.font = UIFont(name: "Poppins-Semibold", size: 20)
        timeTitleLabel.textColor = .black
        selectDataView.addSubview(timeTitleLabel)
    }
    
    private func setupTimeModeSegmCntrl() {
        timeModeSegmCntrl = UISegmentedControl(items: ["AM", "PM"])
        timeModeSegmCntrl.selectedSegmentIndex = 0
        timeModeSegmCntrl.backgroundColor = .hex767680
        timeModeSegmCntrl.overrideUserInterfaceStyle = .light
        timeModeSegmCntrl.isUserInteractionEnabled = false
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Poppins-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        ]
        let selectedSegmAtributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Poppins-Semibold", size: 16) ?? UIFont.systemFont(ofSize: 16)
        ]
            
        timeModeSegmCntrl.setTitleTextAttributes(attributes, for: .normal)
        timeModeSegmCntrl.setTitleTextAttributes(selectedSegmAtributes, for: .selected)
        
        selectDataView.addSubview(timeModeSegmCntrl)
    }
    
    private func setupSelectTimeButton() {
        selectTimeButton.setTitle(eventsManager.createClockTimeLabel(object: timeModeSegmCntrl), for: .normal)
        selectTimeButton.titleLabel?.font = UIFont(name: "Poppins-Regular", size: 22)
        selectTimeButton.setTitleColor(.black, for: .normal)
        selectTimeButton.layer.cornerRadius = 6
        selectTimeButton.layer.backgroundColor = UIColor.hex767680.cgColor
        
        selectTimeButton.addTarget(self, action: #selector(openTimePicker), for: .touchUpInside)
        selectDataView.addSubview(selectTimeButton)
    }
    
    private func setupCustomPeriodEventsLabel() {
        customPeriodEventsLabel.text = eventsManager.getCurrentPeriodLabel(for: .day, value: 1)
        customPeriodEventsLabel.textColor = .black
        customPeriodEventsLabel.font = UIFont(name: "Poppins-SemiBold", size: 20)
        customPeriodEventsLabel.textAlignment = .left
        self.addSubview(customPeriodEventsLabel)
    }
    
    private func setupTable() {
        presentEventsTable.dataSource = self
        presentEventsTable.delegate = self
        presentEventsTable.register(CustomTableViewCell.self, forCellReuseIdentifier: "CustomCell")
        presentEventsTable.separatorStyle = .none
        presentEventsTable.backgroundColor = .white
        self.addSubview(presentEventsTable)
    }
    
    private func setupTimePicker() {
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.locale = Locale(identifier: "en_US_POSIX")
        timePicker.calendar = Calendar.current
        timePicker.backgroundColor = .white
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = 16
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        toolBar.setItems([spacer, doneButton], animated: true)
        toolBar.sizeToFit()
    }
    
    // MARK: - Setup constraints
    
    private func setupConstraints() {
        scrollView.addConstraints(to_view: self)
        
        contentView.addConstraints(to_view: scrollView, [
            .top(anchor: scrollView.topAnchor, constant: 0),
            .leading(anchor: scrollView.leadingAnchor, constant: 0),
            .trailing(anchor: scrollView.trailingAnchor, constant: 0),
            .bottom(anchor: scrollView.bottomAnchor, constant: 0),
            .height(constant: 900)
        ])
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        selectDataView.addConstraints(to_view: contentView, [
            .top(anchor: contentView.topAnchor, constant: 0),
            .leading(anchor: contentView.leadingAnchor, constant: 16),
            .trailing(anchor: contentView.trailingAnchor, constant: 16),
            .bottom(anchor: timeModeSegmCntrl.bottomAnchor, constant: -16)
        ])

        currentMonthLabel.addConstraints(to_view: selectDataView, [
            .top(anchor: selectDataView.topAnchor, constant: 16),
            .leading(anchor: selectDataView.leadingAnchor, constant: 16),
            .height(constant: 24),
            .width(constant: 200)
        ])
        
        calendar.addConstraints(to_view: selectDataView, [
            .top(anchor: currentMonthLabel.bottomAnchor, constant: 16),
            .leading(anchor: selectDataView.leadingAnchor, constant: 10),
            .trailing(anchor: selectDataView.trailingAnchor, constant: 10),
            .height(constant: 300)
        ])
        
        timeTitleLabel.addConstraints(to_view: selectDataView, [
            .top(anchor: calendar.bottomAnchor, constant: 5),
            .leading(anchor: selectDataView.leadingAnchor, constant: 16),
            .width(constant: 50),
            .height(constant: 36)
        ])
        
        timeModeSegmCntrl.addConstraints(to_view: selectDataView, [
            .top(anchor: calendar.bottomAnchor, constant: 5),
            .trailing(anchor: selectDataView.trailingAnchor, constant: 16),
            .width(constant: 100),
            .height(constant: 36)
        ])
        
        selectTimeButton.addConstraints(to_view: selectDataView, [
            .top(anchor: calendar.bottomAnchor, constant: 5),
            .trailing(anchor: selectDataView.trailingAnchor, constant: 124),
            .width(constant: 86),
            .height(constant: 37)
        ])
        
        customPeriodEventsLabel.addConstraints(to_view: contentView, [
            .top(anchor: selectDataView.bottomAnchor, constant: 16),
            .leading(anchor: contentView.leadingAnchor, constant: 16),
            .trailing(anchor: contentView.trailingAnchor, constant: 16),
            .height(constant: 30)
        ])
        
        presentEventsTable.addConstraints(to_view: contentView, [
            .top(anchor: customPeriodEventsLabel.bottomAnchor, constant: 5)
        ])
    }
}
