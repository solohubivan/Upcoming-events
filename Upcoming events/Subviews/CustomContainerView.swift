//
//  CustomContainerView.swift
//  Upcoming events
//
//  Created by Ivan Solohub on 24.08.2024.
//

import UIKit
import EventKit
import FSCalendar

// винеси звідси енам в окр файл
enum TimeMode {
    case am
    case pm
}

class CustomContainerView: UIView, FSCalendarDataSource, FSCalendarDelegate {
    
    private var selectDataView = UIView()
    private var monthLabel = UILabel()
    private var calendar = FSCalendar()
    private var timeTitleLabel = UILabel()
    private var selectTimeButton = UIButton()
    private var timeModeSegmCntrl = UISegmentedControl()
    private var customPeriodEventsLabel = UILabel()
    private var presentEventsTable = UITableView()
    
    private var calendarManager = CalendarManager()
    private let eventStore = EKEventStore()
    private var events: [EventModel] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Public methods
    
    func updateCustomEvents(_ newEvents: [EventModel]) {
        self.events = newEvents
        presentEventsTable.reloadData()
    }
}

// MARK: - UITableView settings

extension CustomContainerView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? CustomTableViewCell ?? CustomTableViewCell()
        
        let event = events[indexPath.row]
        cell.configureCell(with: event)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - Setup UI

extension CustomContainerView {
    private func setupUI() {
        self.backgroundColor = .white
        setupSelectDataView()
        setupMonthLabel()
        setupLeftRightButtons()
        setupCalendar()
        setupTimeTitleLabel()
        setupTimeModeSegmCntrl()
        setupSelectTimeButton()
        setupCustomPeriodEventsLabel()
        setupTable()
        setupConstraints()
    }
    
    private func setupSelectDataView() {
        selectDataView.backgroundColor = .white
        selectDataView.applyShadow()
        self.addSubview(selectDataView)
    }
    
    private func setupMonthLabel() {
        monthLabel.text = calendarManager.getCurrentMonthLabel()
        monthLabel.font = UIFont(name: "Poppins-Semibold", size: 20)
        monthLabel.textColor = .hex5856D6
        selectDataView.addSubview(monthLabel)
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
    }
    
    private func setupCalendar() {
        calendar.dataSource = self
        calendar.delegate = self
        
        calendar.placeholderType = .none
        calendar.appearance.selectionColor = UIColor.hex5856D6
        
        calendar.headerHeight = 0
        
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
        selectTimeButton.accessibilityIdentifier = "selectTimeButton"
        selectTimeButton.setTitle(calendarManager.createClockTimeLabel(object: timeModeSegmCntrl), for: .normal)
        selectTimeButton.titleLabel?.font = UIFont(name: "Poppins-Regular", size: 22)
        selectTimeButton.setTitleColor(.black, for: .normal)
        selectTimeButton.layer.cornerRadius = 6
        selectTimeButton.layer.backgroundColor = UIColor.hex767680.cgColor
        
        selectDataView.addSubview(selectTimeButton)
    }
    
    private func setupCustomPeriodEventsLabel() {
        customPeriodEventsLabel.accessibilityIdentifier = "customPeriodEventsLabel"
        customPeriodEventsLabel.text = calendarManager.getCustomPeriodLabel(for: .month, value: 2)
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
    
    private func setupConstraints() {
        selectDataView.addConstraints(to_view: self, [
            .top(anchor: self.topAnchor, constant: 0),
            .leading(anchor: self.leadingAnchor, constant: 16),
            .trailing(anchor: self.trailingAnchor, constant: 16),
            .bottom(anchor: timeModeSegmCntrl.bottomAnchor, constant: -16)
        ])
        
        monthLabel.addConstraints(to_view: selectDataView, [
            .top(anchor: selectDataView.topAnchor, constant: 16),
            .leading(anchor: selectDataView.leadingAnchor, constant: 16),
            .trailing(anchor: selectDataView.trailingAnchor, constant: 16),
            .height(constant: 24)
        ])
        
        calendar.addConstraints(to_view: selectDataView, [
            .top(anchor: monthLabel.bottomAnchor, constant: 16),
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
        
        customPeriodEventsLabel.addConstraints(to_view: self, [
            .top(anchor: selectDataView.bottomAnchor, constant: 16),
            .leading(anchor: self.leadingAnchor, constant: 16),
            .trailing(anchor: self.trailingAnchor, constant: 16),
            .height(constant: 30)
        ])
        
        presentEventsTable.addConstraints(to_view: self, [
            .top(anchor: customPeriodEventsLabel.bottomAnchor, constant: 5)
        ])
    }
}
