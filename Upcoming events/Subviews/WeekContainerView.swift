//
//  WeekContainerView.swift
//  Upcoming events
//
//  Created by Ivan Solohub on 24.08.2024.
//

import UIKit
import EventKit

class WeekContainerView: UIView {
    
    private var currentWeekLabel = UILabel()
    private var presentEventsTable = UITableView()
    
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
    
    func updateEvents(_ newEvents: [EventModel]) {
        self.events = newEvents
        presentEventsTable.reloadData()
    }
    
    // MARK: - Private methods
    
    private func updateCurrentWeekLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        
        let calendar = Calendar.current
        let today = Date()
        let weekFromToday = calendar.date(byAdding: .day, value: 6, to: today) ?? today
        
        let todayString = dateFormatter.string(from: today)
        let weekFromTodayString = dateFormatter.string(from: weekFromToday)
        
        let year = calendar.component(.year, from: today)
        
        currentWeekLabel.text = "\(todayString) - \(weekFromTodayString), \(year)"
    }
}

// MARK: - UITableView settings

extension WeekContainerView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? CustomTableViewCell ?? CustomTableViewCell()
        
        let event = events[indexPath.row]
        cell.configure(with: event)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - Setup UI

extension WeekContainerView {
    private func setupUI() {
        self.backgroundColor = .white
        setupTitleLabel()
        setupTable()
        
        setupConstraints()
        updateCurrentWeekLabel()
    }
    
    private func setupTitleLabel() {
        currentWeekLabel.accessibilityIdentifier = "currentWeekLabel"
        currentWeekLabel.text = "Current week"
        currentWeekLabel.textColor = .black
        currentWeekLabel.font = UIFont(name: "Poppins-SemiBold", size: 20)
        currentWeekLabel.textAlignment = .left
        
        self.addSubview(currentWeekLabel)
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
        currentWeekLabel.addConstraints(to_view: self, [
            .top(anchor: self.topAnchor, constant: 10),
            .leading(anchor: self.leadingAnchor, constant: 16),
            .trailing(anchor: self.trailingAnchor, constant: 16),
            .height(constant: 30)
        ])
        
        presentEventsTable.addConstraints(to_view: self, [
            .top(anchor: currentWeekLabel.bottomAnchor, constant: 10)
        ])
    }
}
