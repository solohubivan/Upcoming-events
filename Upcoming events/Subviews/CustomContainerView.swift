//
//  CustomContainerView.swift
//  Upcoming events
//
//  Created by Ivan Solohub on 24.08.2024.
//

import UIKit
//import EventKit
//import FSCalendar
//
//enum TimeMode {
//    case am
//    case pm
//}
//
class CustomContainerView: UIView {
//    
//    private var scrollView = UIScrollView()
//    private var contentView = UIView()
//    private var selectDataView = TouchPassthroughView()
//    private var openYearCalendarButton = UIButton()
//    private var timeTitleLabel = UILabel()
//    private var selectTimeButton = UIButton()
//    private var timeModeSegmCntrl = UISegmentedControl()
//    private var customPeriodEventsLabel = UILabel()
//    private var presentEventsTable = UITableView()
//    private var timePicker = UIDatePicker()
//    private var toolBar = UIToolbar()
//    private var calendar = FSCalendar()
//    private var calendarManager = EventsManager()
//    private let eventStore = EKEventStore()
//    private var events: [EventModel] = []
//    private var currentMonth: Date
//    
    override init(frame: CGRect) {
//        currentMonth = Date()
        super.init(frame: frame)
//        setupUI()
        self.backgroundColor = .orange
    }
    
    required init?(coder: NSCoder) {
//        currentMonth = Date()
        super.init(coder: coder)
//        setupUI()
        self.backgroundColor = .orange
    }
//
//    // MARK: - objc methods
//    
//    @objc private func nextMonthButtonTapped() {
//        guard let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: calendar.currentPage) else { return }
//        calendar.setCurrentPage(nextMonth, animated: true)
//    }
//
//    @objc private func previousMonthButtonTapped() {
//        guard let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: calendar.currentPage) else { return }
//        if Calendar.current.compare(previousMonth, to: currentMonth, toGranularity: .month) != .orderedAscending {
//            calendar.setCurrentPage(previousMonth, animated: true)
//        }
//    }
//    
//    @objc private func updateTimeButton() {
//        selectTimeButton.setTitle(calendarManager.createClockTimeLabel(for: Date(), amPmSwitcher: timeModeSegmCntrl), for: .normal)
//    }
//    
//    @objc private func donePressed() {
//        let selectedTime = timePicker.date
//        let timeString = calendarManager.createClockTimeLabel(for: selectedTime, amPmSwitcher: timeModeSegmCntrl)
//        selectTimeButton.setTitle(timeString, for: .normal)
//        
//        guard let selectedDate = self.calendar.selectedDate else { return }
//        let filteredEvents = calendarManager.filterEventsBySelectedTime(selectedTime, forDate: selectedDate)
//
//        self.events = filteredEvents
//        presentEventsTable.reloadData()
//        
//        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
//           let window = windowScene.windows.first {
//            if let overlayView = window.viewWithTag(1001) {
//                    overlayView.removeFromSuperview()
//            }
//        }
//    }
//    
//    @objc private func openTimePicker() {
//        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
//           let window = windowScene.windows.first {
//            let overlayView = UIView(frame: window.bounds)
//            overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
//            overlayView.tag = 1001
//
//            overlayView.addSubview(timePicker)
//            overlayView.addSubview(toolBar)
//            
//            toolBar.addConstraints(to_view: overlayView, [
//                .leading(anchor: overlayView.leadingAnchor, constant: 0),
//                .trailing(anchor: overlayView.trailingAnchor, constant: 0),
//                .bottom(anchor: timePicker.topAnchor, constant: 0),
//                .height(constant: 35)
//            ])
//            timePicker.addConstraints(to_view: overlayView, [
//                .leading(anchor: overlayView.leadingAnchor, constant: 0),
//                .trailing(anchor: overlayView.trailingAnchor, constant: 0),
//                .bottom(anchor: overlayView.bottomAnchor, constant: 0),
//                .height(constant: 210)
//            ])
//            
//            window.addSubview(overlayView)
//        }
//    }
//    
//    // MARK: - Public methods
//    
//    func updateCustomEvents(_ newEvents: [EventModel]) {
//        self.events = newEvents
//        presentEventsTable.reloadData()
//    }
//    
//    // MARK: - Private methods
//    
//    private func updateMonthLabel(for date: Date) {
//        let monthString = calendarManager.getMonthDate(for: date)
//        openYearCalendarButton.setTitle(monthString, for: .normal)
//    }
//
//    private func topViewController() -> UIViewController? {
//        guard let rootVC = UIApplication.shared.windows.first?.rootViewController else { return nil }
//        var topController = rootVC
//        while let presentedVC = topController.presentedViewController {
//            topController = presentedVC
//        }
//        return topController
//    }
}
//
//// MARK: - UITableView delegate
//
//extension CustomContainerView: UITableViewDataSource, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return events.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? CustomTableViewCell ?? CustomTableViewCell()
//        
//        let event = events[indexPath.row]
//        cell.configureCell(with: event)
//        
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 60
//    }
//}
//
//// MARK: - FSCalendarDelegate
//
//extension CustomContainerView: FSCalendarDataSource, FSCalendarDelegate {
//    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
//        updateMonthLabel(for: calendar.currentPage)
//    }
//    
//    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
//
//        let calendar = Calendar.current
//        let today = calendar.startOfDay(for: Date())
//        let selectedDay = calendar.startOfDay(for: date)
//        let components = calendar.dateComponents([.day], from: today, to: selectedDay)
//                
//        guard let numberOfDays = components.day else { return }
//        if numberOfDays < 0 {
//            customPeriodEventsLabel.text = "Please select date up today :)"
//            self.events = []
//            presentEventsTable.reloadData()
//        } else {
//            let newLabel = calendarManager.getCurrentPeriodLabel(for: .day, value: numberOfDays)
//            customPeriodEventsLabel.text = newLabel
//            calendarManager.fetchEvents(for: .day, value: numberOfDays) { [weak self] in
//                DispatchQueue.main.async {
//                    self?.events = self?.calendarManager.getEvents() ?? []
//                    self?.presentEventsTable.reloadData()
//                    self?.updateTimeButton()
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Setup UI
//
//extension CustomContainerView {
//    private func setupUI() {
//        self.backgroundColor = .white
//        setupScrollView()
//        setupContentView()
//        setupSelectDateView()
//        setupOpenYearCalendarButton()
//        setupLeftRightButtons()
//        setupCalendar()
//        setupTimeTitleLabel()
//        setupTimeModeSegmCntrl()
//        setupSelectTimeButton()
//        setupCustomPeriodEventsLabel()
//        setupTable()
//        setupTimePicker()
//        setupConstraints()
//    }
//    
//    private func setupTimePicker() {
//        timePicker.datePickerMode = .time
//        timePicker.preferredDatePickerStyle = .wheels
//        timePicker.locale = Locale(identifier: "en_US_POSIX")
//        timePicker.calendar = Calendar.current
//        timePicker.backgroundColor = .white
//        
//        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
//        spacer.width = 16
//        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
//        toolBar.setItems([spacer, doneButton], animated: true)
//        toolBar.sizeToFit()
//    }
//    
//    private func setupScrollView() {
//        scrollView.backgroundColor = .clear
//        self.addSubview(scrollView)
//    }
//    
//    private func setupContentView() {
//        contentView.backgroundColor = .white
//        scrollView.addSubview(contentView)
//    }
//    
//    private func setupSelectDateView() {
//        selectDataView.backgroundColor = .white
//        selectDataView.applyShadow()
//        self.addSubview(selectDataView)
//    }
//
//    private func setupOpenYearCalendarButton() {
//        updateMonthLabel(for: calendar.currentPage)
//        openYearCalendarButton.titleLabel?.font = UIFont(name: "Poppins-Semibold", size: 20)
//        openYearCalendarButton.setTitleColor(.hex5856D6, for: .normal)
//        openYearCalendarButton.titleLabel?.textAlignment = .left
//        
//        selectDataView.addSubview(openYearCalendarButton)
//    }
//    
//    private func setupLeftRightButtons() {
//        let rightButton = UIButton()
//        let rightButtonImage = UIImage(named: "rightChevron")
//        rightButton.setImage(rightButtonImage, for: .normal)
//        rightButton.imageView?.contentMode = .scaleAspectFit
//        rightButton.tintColor = .hex5856D6
//        
//        let leftButton = UIButton()
//        let leftButtonImage = UIImage(named: "leftChevron")
//        leftButton.setImage(leftButtonImage, for: .normal)
//        leftButton.imageView?.contentMode = .scaleAspectFit
//        leftButton.tintColor = .hex5856D6
//        
//        selectDataView.addSubview(rightButton)
//        selectDataView.addSubview(leftButton)
//        
//        rightButton.addConstraints(to_view: selectDataView, [
//            .top(anchor: selectDataView.topAnchor, constant: 16),
//            .trailing(anchor: selectDataView.trailingAnchor, constant: 16),
//            .width(constant: 24),
//            .height(constant: 24)
//        ])
//        leftButton.addConstraints(to_view: selectDataView, [
//            .top(anchor: selectDataView.topAnchor, constant: 16),
//            .trailing(anchor: selectDataView.trailingAnchor, constant: 60),
//            .width(constant: 24),
//            .height(constant: 24)
//        ])
//        
//        rightButton.addTarget(self, action: #selector(nextMonthButtonTapped), for: .touchUpInside)
//        leftButton.addTarget(self, action: #selector(previousMonthButtonTapped), for: .touchUpInside)
//    }
//    
//    private func setupCalendar() {
//        calendar.dataSource = self
//        calendar.delegate = self
//        calendar.scrollEnabled = true
//        calendar.placeholderType = .none
//        calendar.headerHeight = 0
//        
//        calendar.appearance.selectionColor = UIColor.hex5856D6
//        calendar.appearance.weekdayFont = UIFont(name: "Poppins-Semibold", size: 16)
//        calendar.appearance.weekdayTextColor = UIColor.hex3C3C434D
//        calendar.appearance.caseOptions = [.weekdayUsesUpperCase]
//        calendar.appearance.titleFont = UIFont(name: "Poppins-Regular", size: 18)
//        calendar.appearance.titleDefaultColor = .hex5856D6
//        self.addSubview(calendar)
//    }
//    
//    private func setupTimeTitleLabel() {
//        timeTitleLabel.text = "Time"
//        timeTitleLabel.font = UIFont(name: "Poppins-Semibold", size: 20)
//        timeTitleLabel.textColor = .black
//        selectDataView.addSubview(timeTitleLabel)
//    }
//    
//    private func setupTimeModeSegmCntrl() {
//        timeModeSegmCntrl = UISegmentedControl(items: ["AM", "PM"])
//        timeModeSegmCntrl.selectedSegmentIndex = 0
//        timeModeSegmCntrl.backgroundColor = .hex767680
//        timeModeSegmCntrl.overrideUserInterfaceStyle = .light
//        timeModeSegmCntrl.isUserInteractionEnabled = false
//        
//        let attributes: [NSAttributedString.Key: Any] = [
//            .font: UIFont(name: "Poppins-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
//        ]
//        let selectedSegmAtributes: [NSAttributedString.Key: Any] = [
//            .font: UIFont(name: "Poppins-Semibold", size: 16) ?? UIFont.systemFont(ofSize: 16)
//        ]
//            
//        timeModeSegmCntrl.setTitleTextAttributes(attributes, for: .normal)
//        timeModeSegmCntrl.setTitleTextAttributes(selectedSegmAtributes, for: .selected)
//        
//        selectDataView.addSubview(timeModeSegmCntrl)
//    }
//    
//    private func setupSelectTimeButton() {
//        selectTimeButton.accessibilityIdentifier = "selectTimeButton"
//        selectTimeButton.setTitle(calendarManager.createClockTimeLabel(for: Date(), amPmSwitcher: timeModeSegmCntrl), for: .normal)
//        selectTimeButton.titleLabel?.font = UIFont(name: "Poppins-Regular", size: 22)
//        selectTimeButton.setTitleColor(.black, for: .normal)
//        selectTimeButton.layer.cornerRadius = 6
//        selectTimeButton.layer.backgroundColor = UIColor.hex767680.cgColor
//        
//        selectTimeButton.addTarget(self, action: #selector(openTimePicker), for: .touchUpInside)
//        selectDataView.addSubview(selectTimeButton)
//    }
//    
//    private func setupCustomPeriodEventsLabel() {
//        customPeriodEventsLabel.accessibilityIdentifier = "customPeriodEventsLabel"
//        customPeriodEventsLabel.text = calendarManager.getCurrentPeriodLabel(for: .day, value: 1)
//        customPeriodEventsLabel.textColor = .black
//        customPeriodEventsLabel.font = UIFont(name: "Poppins-SemiBold", size: 20)
//        customPeriodEventsLabel.textAlignment = .left
//        self.addSubview(customPeriodEventsLabel)
//    }
//    
//    private func setupTable() {
//        presentEventsTable.dataSource = self
//        presentEventsTable.delegate = self
//        presentEventsTable.register(CustomTableViewCell.self, forCellReuseIdentifier: "CustomCell")
//        presentEventsTable.separatorStyle = .none
//        presentEventsTable.backgroundColor = .white
//        self.addSubview(presentEventsTable)
//    }
//    
//    private func setupConstraints() {
//        scrollView.addConstraints(to_view: self)
//        
//        contentView.addConstraints(to_view: scrollView, [
//            .top(anchor: scrollView.topAnchor, constant: 0),
//            .leading(anchor: scrollView.leadingAnchor, constant: 0),
//            .trailing(anchor: scrollView.trailingAnchor, constant: 0),
//            .bottom(anchor: scrollView.bottomAnchor, constant: 0),
//            .height(constant: 900)
//        ])
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
//        ])
//        
//        selectDataView.addConstraints(to_view: contentView, [
//            .top(anchor: contentView.topAnchor, constant: 0),
//            .leading(anchor: contentView.leadingAnchor, constant: 16),
//            .trailing(anchor: contentView.trailingAnchor, constant: 16),
//            .bottom(anchor: timeModeSegmCntrl.bottomAnchor, constant: -16)
//        ])
//
//        openYearCalendarButton.addConstraints(to_view: selectDataView, [
//            .top(anchor: selectDataView.topAnchor, constant: 16),
//            .leading(anchor: selectDataView.leadingAnchor, constant: 16),
//            .height(constant: 24),
//            .width(constant: 120)
//        ])
//        
//        calendar.addConstraints(to_view: selectDataView, [
//            .top(anchor: openYearCalendarButton.bottomAnchor, constant: 16),
//            .leading(anchor: selectDataView.leadingAnchor, constant: 10),
//            .trailing(anchor: selectDataView.trailingAnchor, constant: 10),
//            .height(constant: 300)
//        ])
//        
//        timeTitleLabel.addConstraints(to_view: selectDataView, [
//            .top(anchor: calendar.bottomAnchor, constant: 5),
//            .leading(anchor: selectDataView.leadingAnchor, constant: 16),
//            .width(constant: 50),
//            .height(constant: 36)
//        ])
//        
//        timeModeSegmCntrl.addConstraints(to_view: selectDataView, [
//            .top(anchor: calendar.bottomAnchor, constant: 5),
//            .trailing(anchor: selectDataView.trailingAnchor, constant: 16),
//            .width(constant: 100),
//            .height(constant: 36)
//        ])
//        
//        selectTimeButton.addConstraints(to_view: selectDataView, [
//            .top(anchor: calendar.bottomAnchor, constant: 5),
//            .trailing(anchor: selectDataView.trailingAnchor, constant: 124),
//            .width(constant: 86),
//            .height(constant: 37)
//        ])
//        
//        customPeriodEventsLabel.addConstraints(to_view: contentView, [
//            .top(anchor: selectDataView.bottomAnchor, constant: 16),
//            .leading(anchor: contentView.leadingAnchor, constant: 16),
//            .trailing(anchor: contentView.trailingAnchor, constant: 16),
//            .height(constant: 30)
//        ])
//        
//        presentEventsTable.addConstraints(to_view: contentView, [
//            .top(anchor: customPeriodEventsLabel.bottomAnchor, constant: 5)
//        ])
//    }
//}
