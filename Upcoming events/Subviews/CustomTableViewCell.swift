//
//  CustomTableViewCell.swift
//  Upcoming events
//
//  Created by Ivan Solohub on 25.08.2024.
//

import UIKit
import EventKit

class CustomTableViewCell: UITableViewCell {
    
    private var eventNameLabel = UILabel()
    private var remainingTimeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let margin: CGFloat = 16
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 4, left: margin, bottom: 4, right: margin))
    }
    
//  переіменуй метод
    func configure(with event: EventModel) {
        eventNameLabel.text = event.title
        let remainingTime = event.startDate.timeIntervalSince(Date())
        remainingTimeLabel.text = formatTime(remainingTime)
    }
//  винести метод в модель
    private func formatTime(_ interval: TimeInterval) -> String {
        let days = Int(interval) / 86400
        let hours = (Int(interval) % 86400) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if days > 0 {
            return "\(days)d \(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "less than a min"
        }
    }

    // MARK: - Setup UI

    private func setupCell() {
        contentView.backgroundColor = UIColor.hexF2F2F2
        contentView.layer.cornerRadius = 3
        contentView.layer.masksToBounds = true
    }

    private func setupUI() {
        self.backgroundColor = .white
        setupEventNameLabel()
        setupRemainingTimeLabel()
        
        setupConstraints()
    }
    
    private func setupEventNameLabel() {
        eventNameLabel.text = "Event Item"
        eventNameLabel.textColor = .black
        eventNameLabel.font = UIFont(name: "Poppins-Regular", size: 17)
        eventNameLabel.textAlignment = .left
        
        self.addSubview(eventNameLabel)
    }
    
    private func setupRemainingTimeLabel() {
        remainingTimeLabel.text = "less than a min"
        remainingTimeLabel.textColor = UIColor.hex5856D6
        remainingTimeLabel.font = UIFont(name: "Poppins-Regular", size: 17)
        remainingTimeLabel.textAlignment = .right
        
        self.addSubview(remainingTimeLabel)
    }
    
    private func setupConstraints() {
        eventNameLabel.addConstraints(to_view: self, [
            .leading(anchor: self.leadingAnchor, constant: 32),
            .width(constant: 150),
        ])
        
        remainingTimeLabel.addConstraints(to_view: self, [
            .trailing(anchor: self.trailingAnchor, constant: 32),
            .width(constant: 150),
        ])
    }
}
