//
//  MonthContainerView.swift
//  Upcoming events
//
//  Created by Ivan Solohub on 24.08.2024.
//

import UIKit
import EventKit

class MonthContainerView: UIView {
    
    private var currentMonthLabel = UILabel()
    private var presentEventsTable = UITableView()
    
    private var refreshControl = UIRefreshControl()
    private var eventsManager: EventsManager?
    private var events: [EventModel] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - @objc methods
    
    @objc private func refreshData() {
        eventsManager?.fetchEvents(for: .month, value: 1) { [weak self] in
            guard let self = self else { return }
            let eventsForMonth = self.eventsManager?.getEvents(for: .month, value: 1) ?? []
            self.updateMonthEvents(eventsForMonth)
            self.refreshControl.endRefreshing()
        }
    }
    
    // MARK: - Public methods
    
    func configureMonthEvents(with manager: EventsManager) {
        self.eventsManager = manager
        currentMonthLabel.text = manager.getCurrentPeriodLabel(for: .month, value: 1)
        let eventsForMonth = manager.getEvents(for: .month, value: 1)
        updateMonthEvents(eventsForMonth)
    }
    
    // MARK: - Private methods
    
    private func updateMonthEvents(_ newEvents: [EventModel]) {
        self.events = newEvents
        presentEventsTable.reloadData()
    }
}

// MARK: - UITableView settings

extension MonthContainerView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as? CustomTableViewCell ?? CustomTableViewCell()
        
        let event = events[indexPath.row]
        cell.configureCell(with: event)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = events[indexPath.row]

        if let viewController = self.findViewController() {
            if let cell = tableView.cellForRow(at: indexPath) {
                eventsManager?.showEventDetailsAlert(for: event, in: viewController, sourceView: cell)
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - Setup UI

extension MonthContainerView {
    private func setupUI() {
        self.backgroundColor = .white
        setupTitleLabel()
        setupTable()
        setupConstraints()
    }
    
    private func setupTitleLabel() {
        currentMonthLabel.text = ""
        currentMonthLabel.textColor = .black
        currentMonthLabel.font = UIFont(name: "Poppins-SemiBold", size: 20)
        currentMonthLabel.textAlignment = .left
        self.addSubview(currentMonthLabel)
    }
    
    private func setupTable() {
        presentEventsTable.dataSource = self
        presentEventsTable.delegate = self
        presentEventsTable.register(CustomTableViewCell.self, forCellReuseIdentifier: "CustomCell")
        presentEventsTable.separatorStyle = .none
        presentEventsTable.backgroundColor = .white
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        presentEventsTable.refreshControl = refreshControl
        self.addSubview(presentEventsTable)
    }
    
    // MARK: - Setup constraints
    
    private func setupConstraints() {
        currentMonthLabel.addConstraints(to_view: self, [
            .top(anchor: self.topAnchor, constant: 10),
            .leading(anchor: self.leadingAnchor, constant: 16),
            .trailing(anchor: self.trailingAnchor, constant: 16),
            .height(constant: 30)
        ])
        
        presentEventsTable.addConstraints(to_view: self, [
            .top(anchor: currentMonthLabel.bottomAnchor, constant: 10)
        ])
    }
}
