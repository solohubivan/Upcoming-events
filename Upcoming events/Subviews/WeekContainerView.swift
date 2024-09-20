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
    
    private var eventsManager = EventsManager()
    private var events: [EventModel] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Private methods
    
    private func updateWeekEvents(_ newEvents: [EventModel]) {
        self.events = newEvents
        presentEventsTable.reloadData()
    }
    
    // MARK: - Public methods
    
    func configureWeekEvents(with manager: EventsManager) {
        self.eventsManager = manager
        currentWeekLabel.text = manager.getCurrentPeriodLabel(for: .weekOfMonth, value: 1)
        updateWeekEvents(manager.getEvents())
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
        cell.configureCell(with: event)
        
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
    }
    
    private func setupTitleLabel() {
        currentWeekLabel.text = eventsManager.getCurrentPeriodLabel(for: .weekOfMonth, value: 1)
        currentWeekLabel.text = ""
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
