//
//  MainViewController.swift
//  Upcoming events
//
//  Created by Ivan Solohub on 11.08.2024.
//

import UIKit
import EventKit

class MainViewController: UIViewController {
    
    private var menuButton = UIButton(type: .system)
    private var titleLabel = UILabel()
    private var addButton = UIButton(type: .system)
    private var infoModeButtonsStackView = UIStackView()
    
    private var weekContainerView = WeekContainerView()
    private var monthContainerView = MonthContainerView()
    private var yearContainerView = YearContainerView()
    private var customContainerView = CustomContainerView()
    
    private var infoModesButtons: [UIButton] = []
    private var selectedInfoMode: CalendarInfoMode = .week
    private let eventStore = EKEventStore()
    private var eventsManager = EventsManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        requestCalendarAccess()
    }
    
    // MARK: - @objc methods
    
    @objc private func addButtonTapped () {
        let vc = AddNewEventVC()
        vc.modalPresentationStyle = .formSheet
        vc.setEventsManager(self.eventsManager)
        present(vc, animated: true)
    }
    
    @objc private func showMenu(_ sender: UIButton) {
        let menuItems: [UIAction] = [
            UIAction(title: "Shared events", image: UIImage(systemName: "tray.and.arrow.up.fill"), handler: { [weak self] _ in
                self?.dismissKeyboard()
                
                let sharingEventsVC = SharingEventsVC()
                sharingEventsVC.eventsManager = self?.eventsManager
                sharingEventsVC.modalPresentationStyle = .formSheet
                sharingEventsVC.selectedSharingModeSgmntdCntrIndex = 0
                self?.present(sharingEventsVC, animated: true, completion: nil)
            }),
            
            UIAction(title: "Received events", image: UIImage(systemName: "tray.and.arrow.down.fill"), handler: { [weak self] _ in
                self?.dismissKeyboard()
                
                let sharingEventsVC = SharingEventsVC()
                sharingEventsVC.eventsManager = self?.eventsManager
                sharingEventsVC.modalPresentationStyle = .formSheet
                sharingEventsVC.selectedSharingModeSgmntdCntrIndex = 1
                self?.present(sharingEventsVC, animated: true, completion: nil)
            }),
            UIAction(title: "Get event with QR", image: UIImage(systemName: "qrcode"), handler: { [weak self] _ in
                self?.dismissKeyboard()
                
                print("3d button tapped")
            })
        ]
            
        let menu = UIMenu(children: menuItems)
        sender.menu = menu
        sender.showsMenuAsPrimaryAction = true
    }
    
    @objc private func toggleButtonSelection(_ sender: UIButton) {
        guard let index = infoModesButtons.firstIndex(of: sender), let mode = CalendarInfoMode(rawValue: index) else { return }
        infoModesButtons.forEach {
            $0.isSelected = false
            $0.backgroundColor = UIColor.hex767680
        }
        sender.isSelected = true
        sender.backgroundColor = UIColor.hex5856D6
               
        updateVisibleContainer(for: mode)
    }

    // MARK: - Private methods
    
    private func updateVisibleContainer(for mode: CalendarInfoMode) {
        weekContainerView.isHidden = true
        monthContainerView.isHidden = true
        yearContainerView.isHidden = true
        customContainerView.isHidden = true
        
        switch mode {
        case .week:
            eventsManager.fetchEvents(for: .weekOfMonth, value: 1) { [weak self] in
                guard let self = self else { return }
                self.weekContainerView.configureWeekEvents(with: self.eventsManager)
                self.weekContainerView.isHidden = false
            }
        case .month:
            eventsManager.fetchEvents(for: .month, value: 1) { [weak self] in
                guard let self = self else { return }
                self.monthContainerView.configureMonthEvents(with: self.eventsManager)
                self.monthContainerView.isHidden = false
            }
        case .year:
            eventsManager.fetchEvents(for: .year, value: 1) { [weak self] in
                guard let self = self else { return }
                self.yearContainerView.configureYearEvents(with: self.eventsManager)
                self.yearContainerView.isHidden = false
            }
        case .custom:
            eventsManager.fetchEvents(for: .day, value: 1) { [weak self] in
                guard let self = self else { return }
 //               self.customContainerView.updateCustomEvents(self.eventsManager.getEvents())
                self.customContainerView.isHidden = false
            }
        }
        
        selectedInfoMode = mode
    }
    
    private func requestCalendarAccess() {
        eventStore.requestAccess(to: .event) { [weak self] (granted, error) in
            DispatchQueue.main.async {
                if granted {
                    self?.setupUI()
                } else {
                    self?.showCalendarAccessAlert()
                }
            }
        }
    }
    
    private func showCalendarAccessAlert() {
        let alertController = UIAlertController(
            title: "Access Denied",
            message: "This app does not have access to your calendar. Please go to Settings and enable access.",
            preferredStyle: .alert
        )

        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Setup UI

extension MainViewController {
    private func setupUI() {
        view.backgroundColor = .white
        setupMenuButton()
        setupTitleLabel()
        setupAddButton()
        setupInfoModeButtonsStackView()
        setupInfoModeViewContainers()
        
        setupConstraints()
    }
    
    private func setupMenuButton() {
        let buttonImage = UIImage(systemName: "line.3.horizontal")
        menuButton.setImage(buttonImage, for: .normal)
        menuButton.imageView?.contentMode = .scaleAspectFit
        menuButton.tintColor = UIColor.hex5856D6
        menuButton.addTarget(self, action: #selector(showMenu(_:)), for: .touchUpInside)
        view.addSubview(menuButton)
    }
    
    private func setupTitleLabel() {
        titleLabel.accessibilityIdentifier = "titleLabel"
        titleLabel.textColor = .black
        titleLabel.font = UIFont(name: "Poppins-SemiBold", size: 34)
        titleLabel.textAlignment = .center
        titleLabel.text = "My Events"
        
        view.addSubview(titleLabel)
    }
    
    private func setupAddButton() {
        addButton.accessibilityIdentifier = "addButton"
        let buttonImage = UIImage(systemName: "plus")
        addButton.setImage(buttonImage, for: .normal)
        addButton.imageView?.contentMode = .scaleAspectFit
        addButton.tintColor = UIColor.hex5856D6
        
        view.addSubview(addButton)
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    private func setupInfoModeButtonsStackView() {
        infoModeButtonsStackView.axis = .horizontal
        infoModeButtonsStackView.alignment = .center
        infoModeButtonsStackView.distribution = .equalSpacing
        infoModeButtonsStackView.spacing = 6
        
        let buttonsTitles = ["Week", "Month", "Year", "Custom"]
        
        for title in buttonsTitles {
            let button = UIButton()
            createSearchingModeButtons(buttonName: button, buttonTitle: title)
            infoModesButtons.append(button)
            infoModeButtonsStackView.addArrangedSubview(button)
        }
        
        view.addSubview(infoModeButtonsStackView)
        
        if let firstButton = infoModesButtons.first {
            toggleButtonSelection(firstButton)
        }
    }
    
    private func createSearchingModeButtons(buttonName: UIButton, buttonTitle: String) {
        buttonName.setTitle(buttonTitle, for: .normal)
        buttonName.setTitleColor(UIColor.black, for: .normal)
        buttonName.setTitleColor(.white, for: .selected)
        buttonName.titleLabel?.font = UIFont(name: "Poppins-Regular", size: 16)
        buttonName.titleLabel?.textAlignment = .center
        buttonName.layer.cornerRadius = 13
        
        buttonName.sizeToFit()
        
        let buttonWidth = buttonName.frame.width + 30
        let buttonHeight = buttonName.frame.height + 20
        NSLayoutConstraint.activate([
            buttonName.widthAnchor.constraint(equalToConstant: buttonWidth),
            buttonName.heightAnchor.constraint(equalToConstant: buttonHeight)
        ])
        
        buttonName.addTarget(self, action: #selector(toggleButtonSelection(_:)), for: .touchUpInside)
    }
    
    private func setupInfoModeViewContainers() {
        view.addSubview(weekContainerView)
        view.addSubview(monthContainerView)
        view.addSubview(yearContainerView)
        view.addSubview(customContainerView)
    }
    
    // MARK: - Setup constraints
    
    private func setupConstraints() {
        menuButton.addConstraints(to_view: view, [
            .top(anchor: view.topAnchor, constant: 60),
            .leading(anchor: view.leadingAnchor, constant: 16),
            .height(constant: 41),
            .width(constant: 24)
        ])
        
        titleLabel.addConstraints(to_view: view, [
            .top(anchor: view.topAnchor, constant: 60),
            .centerX(anchor: view.centerXAnchor, constant: 0),
            .height(constant: 41)
        ])
        
        addButton.addConstraints(to_view: view, [
            .top(anchor: view.topAnchor, constant: 60),
            .trailing(anchor: view.trailingAnchor, constant: 16),
            .height(constant: 41),
            .width(constant: 24)
        ])
        
        infoModeButtonsStackView.addConstraints(to_view: view, [
            .top(anchor: titleLabel.bottomAnchor, constant: 16),
            .leading(anchor: view.leadingAnchor, constant: 16),
            .trailing(anchor: view.trailingAnchor, constant: 16),
            .height(constant: 60)
        ])
        
        weekContainerView.addConstraints(to_view: view, [
            .top(anchor: infoModeButtonsStackView.bottomAnchor, constant: 16)
        ])
        
        yearContainerView.addConstraints(to_view: view, [
            .top(anchor: infoModeButtonsStackView.bottomAnchor, constant: 16)
        ])
        
        monthContainerView.addConstraints(to_view: view, [
            .top(anchor: infoModeButtonsStackView.bottomAnchor, constant: 16)
        ])
        
        customContainerView.addConstraints(to_view: view, [
            .top(anchor: infoModeButtonsStackView.bottomAnchor, constant: 16)
        ])
    }
}
