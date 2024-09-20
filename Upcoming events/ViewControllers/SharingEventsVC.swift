//
//  SharingEventsVC.swift
//  Upcoming events
//
//  Created by Ivan Solohub on 20.09.2024.
//

import UIKit

class SharingEventsVC: UIViewController {
    
    private var titleLabel = UILabel()
    private var sharingModeSgmntdCntrl = UISegmentedControl()
    private var presentEventsTable = UITableView()
    
    var selectedSharingModeSgmntdCntrIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateSharingModeSegmntCntr()
    }
    
    // MARK: - Objc methods
    
    @objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
        updateTitleLabel(for: sender.selectedSegmentIndex)
    }
    
    // MARK: - Private methods
    
    private func updateTitleLabel(for index: Int) {
        switch index {
        case 0:
            titleLabel.text = "Shared events"
        case 1:
            titleLabel.text = "Received events"
        default:
            titleLabel.text = ""
        }
    }
    
    private func updateSharingModeSegmntCntr() {
        sharingModeSgmntdCntrl.selectedSegmentIndex = selectedSharingModeSgmntdCntrIndex
        updateTitleLabel(for: selectedSharingModeSgmntdCntrIndex)
    }
}

// MARK: - UITableView Delegate

extension SharingEventsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
        cell.backgroundColor = .clear
        cell.textLabel?.text = "Простий текст для рядка \(indexPath.row)"
            
        return cell
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
