//
//  SharingEventsVC.swift
//  Upcoming events
//
//  Created by Ivan Solohub on 20.09.2024.
//

import UIKit

enum SharingMode: Int {
    case shared = 0
    case received = 1
}

class SharingEventsVC: UIViewController {
    
    private var titleLabel = UILabel()
    private var sharingModeSgmntdCntrl = UISegmentedControl()
    private var presentEventsTable = UITableView()
    
    private var sharingEvents: [EventModel] = []
    var eventsManager: EventsManager?
    
    var selectedSharingMode: SharingMode = .shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateSharingModeSegmntCntr()
        updateUI(for: selectedSharingMode)
    }
    
    // MARK: - Objc methods
    
    @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
        if let mode = SharingMode(rawValue: sender.selectedSegmentIndex) {
            updateUI(for: mode)
        }
    }
    
    // MARK: - Private methods
    
    private func updateUI(for mode: SharingMode) {
        switch mode {
        case .shared:
            titleLabel.text = "Shared events"
            loadSharedEvents()
        case .received:
            titleLabel.text = "Received events"
            loadReceivedEvents()
        }
    }
    
    private func loadReceivedEvents() {
        sharingEvents = eventsManager?.getRecievedEvents() ?? []
        presentEventsTable.reloadData()
    }
    
    private func loadSharedEvents() {
        sharingEvents = eventsManager?.getSharedEvents() ?? []
        presentEventsTable.reloadData()
    }
    
    private func updateSharingModeSegmntCntr() {
        sharingModeSgmntdCntrl.selectedSegmentIndex = selectedSharingMode.rawValue
        updateUI(for: selectedSharingMode)
    }
    
    private func showInfoAboutEvent(_ event: EventModel) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let startDateStr = dateFormatter.string(from: event.startDate)
        let endDateStr = dateFormatter.string(from: event.endDate)
        let message = "Start: \(startDateStr)\nEnd: \(endDateStr)"
        
        let alert = UIAlertController(title: event.title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)

        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableView Delegate

extension SharingEventsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sharingEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
        cell.backgroundColor = .clear
        let event = sharingEvents[indexPath.row]
        cell.textLabel?.text = event.title
        cell.detailTextLabel?.text = "Start: \(event.startDate), End: \(event.endDate)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = sharingEvents[indexPath.row]
        showInfoAboutEvent(event)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            switch sharingModeSgmntdCntrl.selectedSegmentIndex {
                case SharingMode.shared.rawValue:
                    eventsManager?.removeSharedEvent(at: indexPath.row)
                case SharingMode.received.rawValue:
                    eventsManager?.removeRecievedEvent(at: indexPath.row)
                default:
                    break
                }
            
            sharingEvents.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

// MARK: - Setup UI

extension SharingEventsVC {
    private func setupUI() {
        setupBackGroundColor()
        setupTitleLabel()
        setupSharingModeSgmntdCntrl()
        setupPresentEventsTable()
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
        titleLabel.text = "Received/Sharing events"
        view.addSubview(titleLabel)
    }
    
    private func setupSharingModeSgmntdCntrl() {
        sharingModeSgmntdCntrl = UISegmentedControl(items: ["Shared", "Received"])
        sharingModeSgmntdCntrl.backgroundColor = .white
        sharingModeSgmntdCntrl.overrideUserInterfaceStyle = .light
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Poppins-Regular", size: 18) ?? UIFont.systemFont(ofSize: 16)
        ]
        let selectedSegmAtributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Poppins-Semibold", size: 18) ?? UIFont.systemFont(ofSize: 16)
        ]
        
        sharingModeSgmntdCntrl.setTitleTextAttributes(attributes, for: .normal)
        sharingModeSgmntdCntrl.setTitleTextAttributes(selectedSegmAtributes, for: .selected)
        sharingModeSgmntdCntrl.addTarget(self, action: #selector(segmentedControlChanged(_:)), for: .valueChanged)
        view.addSubview(sharingModeSgmntdCntrl)
    }
    
    private func setupPresentEventsTable() {
        presentEventsTable.dataSource = self
        presentEventsTable.delegate = self
        presentEventsTable.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
        presentEventsTable.backgroundColor = .clear
        
        view.addSubview(presentEventsTable)
    }
    
    // MARK: - Setup constraints
    
    private func setupConstraints() {
        titleLabel.addConstraints(to_view: view, [
            .top(anchor: view.topAnchor, constant: 10),
            .leading(anchor: view.leadingAnchor, constant: 16),
            .trailing(anchor: view.trailingAnchor, constant: 16),
            .height(constant: 40)
        ])
        
        sharingModeSgmntdCntrl.addConstraints(to_view: view, [
            .top(anchor: titleLabel.bottomAnchor, constant: 20),
            .leading(anchor: view.leadingAnchor, constant: 16),
            .trailing(anchor: view.trailingAnchor, constant: 16),
            .height(constant: 40)
        ])
        
        presentEventsTable.addConstraints(to_view: view, [
            .top(anchor: sharingModeSgmntdCntrl.bottomAnchor, constant: 16)
        ])
    }
}
