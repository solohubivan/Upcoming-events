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
        eventsManager?.fetchEvents(for: .weekOfMonth, value: 1) { [weak self] in
            guard let self = self else { return }
            let eventsForWeek = self.eventsManager?.getEvents(for: .weekOfMonth, value: 1) ?? []
            self.updateWeekEvents(eventsForWeek)
            self.refreshControl.endRefreshing()
        }
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
        let eventsForWeek = manager.getEvents(for: .weekOfMonth, value: 1)
        updateWeekEvents(eventsForWeek)
    }
}

// MARK: - UITableView settings

extension WeekContainerView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AppConstants.Identifiers.customTableCell, for: indexPath) as? CustomTableViewCell ?? CustomTableViewCell()
        
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

extension WeekContainerView {
    private func setupUI() {
        self.backgroundColor = .white
        setupTitleLabel()
        setupTable()
        setupConstraints()
    }
    
    private func setupTitleLabel() {
        currentWeekLabel.text = ""
        currentWeekLabel.textColor = .black
        currentWeekLabel.font = UIFont.customFont(name: AppConstants.Fonts.poppinsSemiBold, size: 20, textStyle: .title1)
        currentWeekLabel.adjustsFontForContentSizeCategory = true
        
        currentWeekLabel.textAlignment = .left
        self.addSubview(currentWeekLabel)
    }
    
    private func setupTable() {
        presentEventsTable.dataSource = self
        presentEventsTable.delegate = self
        presentEventsTable.register(CustomTableViewCell.self, forCellReuseIdentifier: AppConstants.Identifiers.customTableCell)
        presentEventsTable.separatorStyle = .none
        presentEventsTable.backgroundColor = .white
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        presentEventsTable.refreshControl = refreshControl
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
