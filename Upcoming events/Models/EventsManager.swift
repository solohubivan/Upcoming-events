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
    
    private var receivedEvents: [EventModel] = []
    private var sharedEvents: [EventModel] = []
    private var addedEvents: [EventModel] = []
    private var events: [EventModel] = []
    
    private let eventStore = EKEventStore()
    
    // MARK: - Private methods
    
    private func saveReceivedEvents() {
        if let data = try? JSONEncoder().encode(receivedEvents) {
            UserDefaults.standard.set(data, forKey: AppConstants.Keys.userDefaultsReceivedEventsKey)
        }
    }
    
    private func loadReceivedEvents() {
        if let data = UserDefaults.standard.data(forKey: AppConstants.Keys.userDefaultsReceivedEventsKey),
           let savedEvents = try? JSONDecoder().decode([EventModel].self, from: data) {
            receivedEvents = savedEvents
        }
    }
    
    private func saveSharedEvents() {
        if let data = try? JSONEncoder().encode(sharedEvents) {
            UserDefaults.standard.set(data, forKey: AppConstants.Keys.userDefaultsSharedEventsKey)
        }
    }

    private func loadSharedEvents() {
        if let data = UserDefaults.standard.data(forKey: AppConstants.Keys.userDefaultsSharedEventsKey),
            let savedEvents = try? JSONDecoder().decode([EventModel].self, from: data) {
            sharedEvents = savedEvents
        }
    }
    
    private func saveAddedEvents() {
        if let data = try? JSONEncoder().encode(addedEvents) {
            UserDefaults.standard.set(data, forKey: AppConstants.Keys.userDefaultsAddedEventsKey)
        }
    }

    private func loadAddedEvents() {
        if let data = UserDefaults.standard.data(forKey: AppConstants.Keys.userDefaultsAddedEventsKey),
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

    func getEvents(for timeInterval: Calendar.Component, value: Int) -> [EventModel] {
        loadAddedEvents()
        removePastEvents()

        let startDate = Date()
        guard let endDate = Calendar.current.date(byAdding: timeInterval, value: value, to: startDate) else { return [] }
        let filteredAddedEvents = addedEvents.filter { event in
            return event.startDate >= startDate && event.startDate <= endDate
        }
        let filteredEvents = events.filter { event in
            return event.startDate >= startDate && event.startDate <= endDate
        }
        let combinedEvents = (filteredAddedEvents + filteredEvents).sorted { $0.startDate < $1.startDate }
        
        return combinedEvents
    }
    
    func getReceivedEvents() -> [EventModel] {
        loadReceivedEvents()
        return receivedEvents
    }
    
    func removeReceivedEvent(at index: Int) {
        receivedEvents.remove(at: index)
        saveReceivedEvents()
    }
    
    func getSharedEvents() -> [EventModel] {
        loadSharedEvents()
        return sharedEvents
    }
    
    func removeSharedEvent(at index: Int) {
        sharedEvents.remove(at: index)
        saveSharedEvents()
    }
    
    func addEvent(_ event: EventModel) {
        addedEvents.append(event)
        saveAddedEvents()
    }
    
    func addSharedEvent(_ event: EventModel) {
        sharedEvents.append(event)
        saveSharedEvents()
    }
    
    func addReceivedEvent(_ event: EventModel) {
        receivedEvents.append(event)
        saveReceivedEvents()
    }
    
    func fetchEvents(for timeInterval: Calendar.Component, value: Int, completion: @escaping () -> Void) {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: timeInterval, value: value, to: startDate)
            
        guard let endDate = endDate else { return }
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let ekEvents = eventStore.events(matching: predicate)
                    
        events.removeAll()
                    
        for ekEvent in ekEvents {
            let event = EventModel(title: ekEvent.title ?? AppConstants.AlertMessages.noTitle, startDate: ekEvent.startDate, endDate: ekEvent.endDate)
            events.append(event)
        }
        loadAddedEvents()
        removePastEvents()
        completion()
    }
    
    func showEventDetailsAlert(for event: EventModel, in viewController: UIViewController, sourceView: UIView) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
            
        let startDateStr = dateFormatter.string(from: event.startDate)
        let endDateStr = dateFormatter.string(from: event.endDate)
            
        let message = "\(AppConstants.AlertMessages.messageEventsStart): \(startDateStr)\n\(AppConstants.AlertMessages.messageEventsEnd): \(endDateStr)"
        let alert = UIAlertController(title: "\(AppConstants.AlertMessages.titleEvent) \"\(event.title)\"", message: message, preferredStyle: .alert)
            
        let okAction = UIAlertAction(title: AppConstants.ButtonTitles.ok, style: .default, handler: nil)
        let shareAction = UIAlertAction(title: AppConstants.AlertMessages.shareAlertAction, style: .default) { _ in
            self.addSharedEvent(event)
            let shareUtility = ShareUtility()
            let eventInfo = "\(AppConstants.AlertMessages.titleEvent): \(event.title)\n\(AppConstants.AlertMessages.messageEventsStart): \(startDateStr)\n\(AppConstants.AlertMessages.messageEventsEnd): \(endDateStr)"
            let shareViewController = shareUtility.createShareViewController(contentToShare: eventInfo, sourceView: sourceView)
            viewController.present(shareViewController, animated: true, completion: nil)
        }
        
        let qrCodeAction = UIAlertAction(title: AppConstants.AlertMessages.shareWithQRAlertAction, style: .default) { _ in
            let qrVC = ShowQRViewController()
            let eventInfoString = "\(AppConstants.AlertMessages.titleEvent): \(event.title)\n\(AppConstants.AlertMessages.messageEventsStart): \(startDateStr)\n\(AppConstants.AlertMessages.messageEventsEnd): \(endDateStr)"
            qrVC.makeQRCodeForString(text: eventInfoString)
            qrVC.modalPresentationStyle = .formSheet
            viewController.present(qrVC, animated: true)
        }
            
        alert.addAction(okAction)
        alert.addAction(shareAction)
        alert.addAction(qrCodeAction)
            
        viewController.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Calendar settings
    
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
            return AppConstants.AlertMessages.lessThanMin
        }
    }
    
    func createClockTimeLabel(object: UISegmentedControl) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "hh : mm"
            
        let currentTime = formatter.string(from: Date())
            
        let hourFormatter = DateFormatter()
        hourFormatter.locale = Locale(identifier: "en_US_POSIX")
        hourFormatter.dateFormat = "a"
        let amPmString = hourFormatter.string(from: Date())

        let timeMode: TimeMode = amPmString == "AM" ? .am : .pm
        switch timeMode {
        case .am:
            object.selectedSegmentIndex = 0
        case .pm:
            object.selectedSegmentIndex = 1
        }
        
        return currentTime
    }
}
