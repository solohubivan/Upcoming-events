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
            UIAction(title: AppConstants.MainViewController.titleSharedEvents, image: UIImage(systemName: AppConstants.ImageNames.trayAndArrowUpFill), handler: { [weak self] _ in
                self?.dismissKeyboard()
                
                let sharingEventsVC = SharingEventsVC()
                sharingEventsVC.eventsManager = self?.eventsManager
                sharingEventsVC.modalPresentationStyle = .formSheet
                sharingEventsVC.selectedSharingMode = .shared
                self?.present(sharingEventsVC, animated: true, completion: nil)
            }),
            
            UIAction(title: AppConstants.MainViewController.titleReceivedEvents, image: UIImage(systemName: AppConstants.ImageNames.trayAndArrowDownFill), handler: { [weak self] _ in
                self?.dismissKeyboard()
                
                let sharingEventsVC = SharingEventsVC()
                sharingEventsVC.eventsManager = self?.eventsManager
                sharingEventsVC.modalPresentationStyle = .formSheet
                sharingEventsVC.selectedSharingMode = .received
                self?.present(sharingEventsVC, animated: true, completion: nil)
            }),
            UIAction(title: AppConstants.MainViewController.titleGetEventWithQR, image: UIImage(systemName: AppConstants.ImageNames.qrcode), handler: { [weak self] _ in
                self?.dismissKeyboard()
                
                let QRScannerVC = QRScannerVC()
                QRScannerVC.modalPresentationStyle = .formSheet
                self?.present(QRScannerVC, animated: true, completion: nil)
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
                self.customContainerView.configureCustomEvents(with: self.eventsManager)
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
            title: AppConstants.AlertMessages.titleAccessDenied,
            message: AppConstants.AlertMessages.messageDoesntHaveAccessToCalendar,
            preferredStyle: .alert
        )

        let settingsAction = UIAlertAction(title: AppConstants.ButtonTitles.settings, style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }

        let cancelAction = UIAlertAction(title: AppConstants.ButtonTitles.cancel, style: .cancel, handler: nil)

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
        let buttonImage = UIImage(systemName: AppConstants.ImageNames.line3Horizontal)
        menuButton.setImage(buttonImage, for: .normal)
        menuButton.imageView?.contentMode = .scaleAspectFit
        menuButton.tintColor = UIColor.hex5856D6
        menuButton.addTarget(self, action: #selector(showMenu(_:)), for: .touchUpInside)
        view.addSubview(menuButton)
    }
    
    private func setupTitleLabel() {
        titleLabel.setCustomFont(name: AppConstants.Fonts.poppinsSemiBold, size: 34, textStyle: .title1)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.text = AppConstants.MainViewController.titleLabel
        view.addSubview(titleLabel)
    }
    
    private func setupAddButton() {
        let buttonImage = UIImage(systemName: AppConstants.ImageNames.plus)
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
        
        let buttonsTitles = [AppConstants.ButtonTitles.week,
                             AppConstants.ButtonTitles.month,
                             AppConstants.ButtonTitles.year,
                             AppConstants.ButtonTitles.custom]
        
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
        buttonName.titleLabel?.font = UIFont(name: AppConstants.Fonts.poppinsRegular, size: 16)
        buttonName.titleLabel?.textAlignment = .center
        buttonName.layer.cornerRadius = 13
        
        if let customFont = UIFont(name: AppConstants.Fonts.poppinsRegular, size: 16) {
            buttonName.titleLabel?.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: customFont)
            buttonName.titleLabel?.adjustsFontForContentSizeCategory = true
        }
        
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
