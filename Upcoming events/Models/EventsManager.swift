//
//  CalendarManager.swift
//  Upcoming events
//
//  Created by Ivan Solohub on 28.08.2024.
//

import Foundation
import EventKit
import UIKit

class EventsManager {
    
    private var sharedEvents: [EventModel] = []
    private var addedEvents: [EventModel] = []
    private var events: [EventModel] = []
    
    private let eventStore = EKEventStore()
    
    // MARK: - Private methods
    
    private func saveAddedEvents() {
        if let data = try? JSONEncoder().encode(addedEvents) {
            UserDefaults.standard.set(data, forKey: "addedEvents")
        }
    }

    private func loadAddedEvents() {
        if let data = UserDefaults.standard.data(forKey: "addedEvents"),
            let savedEvents = try? JSONDecoder().decode([EventModel].self, from: data) {
            addedEvents = savedEvents
        }
        removePastEvents()
    }
    
    private func removePastEvents() {
        let now = Date()
        addedEvents.removeAll { $0.endDate < now }
        events.removeAll { $0.endDate < now }
        saveAddedEvents()
    }
    
    // MARK: - Publick methods

    func getEvents() -> [EventModel] {
        loadAddedEvents()
        removePastEvents()
        return addedEvents + events
    }
    
    func addEvent(_ event: EventModel) {
        addedEvents.append(event)
        saveAddedEvents()
    }
    
    func fetchEvents(for timeInterval: Calendar.Component, value: Int, completion: @escaping () -> Void) {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: timeInterval, value: value, to: startDate)
            
        guard let endDate = endDate else { return }
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let ekEvents = eventStore.events(matching: predicate)
                    
        events.removeAll()
                    
        for ekEvent in ekEvents {
            let event = EventModel(title: ekEvent.title ?? "No title", startDate: ekEvent.startDate, endDate: ekEvent.endDate)
            events.append(event)
        }
        loadAddedEvents()
        removePastEvents()
        completion()
    }
    
    func getCurrentPeriodLabel(for timeInterval: Calendar.Component, value: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
            
        let calendar = Calendar.current
        let today = Date()

        guard let endOfPeriod = calendar.date(byAdding: timeInterval, value: value, to: today) else { return "" }
            
        let todayString = dateFormatter.string(from: today)
        let endOfPeriodString = dateFormatter.string(from: endOfPeriod)
            
        let startYear = calendar.component(.year, from: today)
        let endYear = calendar.component(.year, from: endOfPeriod)
            
        if startYear == endYear {
            return "\(todayString) - \(endOfPeriodString), \(startYear)"
        } else {
            return "\(todayString), \(startYear) - \(endOfPeriodString), \(endYear)"
        }
    }
    
    func formatTimeForLabel(_ interval: TimeInterval) -> String {
        let days = Int(interval) / 86400
        let hours = (Int(interval) % 86400) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        switch (days, hours, minutes) {
        case (let d, _, _) where d > 0:
            return "\(d)d \(hours)h \(minutes)m"
        case (_, let h, _) where h > 0:
            return "\(h)h \(minutes)m"
        case (_, _, let m) where m > 0:
            return "\(m)m"
        default:
            return "less than a min"
        }
    }
    
    func showEventDetailsAlert(for event: EventModel, in viewController: UIViewController, sourceView: UIView) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
            
        let startDateStr = dateFormatter.string(from: event.startDate)
        let endDateStr = dateFormatter.string(from: event.endDate)
            
        let message = "Start: \(startDateStr)\nEnd: \(endDateStr)"
        let alert = UIAlertController(title: "Event \"\(event.title)\"", message: message, preferredStyle: .alert)
            
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        let shareAction = UIAlertAction(title: "Share", style: .default) { _ in
            let shareUtility = ShareUtility()
            let eventInfo = "Event: \(event.title)\nStart: \(startDateStr)\nEnd: \(endDateStr)"
            let shareViewController = shareUtility.createShareViewController(contentToShare: eventInfo, sourceView: sourceView)
            viewController.present(shareViewController, animated: true, completion: nil)
        }
            
        alert.addAction(okAction)
        alert.addAction(shareAction)
            
        viewController.present(alert, animated: true, completion: nil)
    }
}
