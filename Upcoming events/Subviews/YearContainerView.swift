//
//  YearContainerView.swift
//  Upcoming events
//
//  Created by Ivan Solohub on 24.08.2024.
//

import UIKit
import EventKit

class YearContainerView: UIView {
    
    private var currentYearLabel = UILabel()
    private var presentEventsTable = UITableView()
    
    private let eventStore = EKEventStore()
    private var calendarManager = CalendarManager()
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
    
    func updateYearEvents(_ newEvents: [EventModel]) {
        self.events = newEvents
        presentEventsTable.reloadData()
    }
}

// MARK: - UITableView settings

extension YearContainerView: UITableViewDataSource, UITableViewDelegate {
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

extension YearContainerView {
    private func setupUI() {
        self.backgroundColor = .white
        setupTitleLabel()
        setupTable()
        setupConstraints()
    }
    
    private func setupTitleLabel() {
        currentYearLabel.accessibilityIdentifier = "currentYearLabel"
        currentYearLabel.text = calendarManager.getCurrentPeriodLabel(for: .year)
        currentYearLabel.textColor = .black
        currentYearLabel.font = UIFont(name: "Poppins-SemiBold", size: 20)
        currentYearLabel.textAlignment = .left
        self.addSubview(currentYearLabel)
    }
    
    private func setupTable() {
        presentEventsTable.dataSource = self
        presentEventsTable.delegate = self
        presentEventsTable.register(CustomTableViewCell.self, forCellReuseIdentifier: "CustomCell")
        presentEventsTable.separatorStyle = .none
        presentEventsTable.backgroundColor = .white
        self.addSubview(presentEventsTable)
    }
    
    // MARK: - Setup constraints
    
    private func setupConstraints() {
        currentYearLabel.addConstraints(to_view: self, [
            .top(anchor: self.topAnchor, constant: 10),
            .leading(anchor: self.leadingAnchor, constant: 16),
            .trailing(anchor: self.trailingAnchor, constant: 16),
            .height(constant: 30)
        ])
        
        presentEventsTable.addConstraints(to_view: self, [
            .top(anchor: currentYearLabel.bottomAnchor, constant: 10)
        ])
    }
}
