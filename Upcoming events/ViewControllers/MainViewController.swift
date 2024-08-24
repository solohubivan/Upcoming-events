//
//  MainViewController.swift
//  Upcoming events
//
//  Created by Ivan Solohub on 11.08.2024.
//

import UIKit

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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - @objc methods
    
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
            weekContainerView.isHidden = false
        case .month:
            monthContainerView.isHidden = false
        case .year:
            yearContainerView.isHidden = false
        case .custom:
            customContainerView.isHidden = false
        }
        
        selectedInfoMode = mode
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
