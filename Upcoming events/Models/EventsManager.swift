//
//  EventsManager.swift
//  Upcoming events
//
//  Created by Ivan Solohub on 28.08.2024.
//

import Foundation
import EventKit
import UIKit
import CoreData

class EventsManager {
    
    private var receivedEvents: [EventModel] = []
    private var sharedEvents: [EventModel] = []
    private var addedEvents: [EventModel] = []
    private var events: [EventModel] = []
    
    private let eventStore = EKEventStore()
    
    // MARK: - Private methods
    
    private func saveEventToData<T: NSManagedObject>(_ eventModel: EventModel, entityType: T.Type) {
        let newEvent = T(context: CoreDataStack.shared.context)
        
        newEvent.setValue(eventModel.title, forKey: "title")
        newEvent.setValue(eventModel.startDate, forKey: "startDate")
        newEvent.setValue(eventModel.endDate, forKey: "endDate")
        
        CoreDataStack.shared.saveContext()
    }

    private func loadEventsFromData<T: NSManagedObject>(entityType: T.Type, into array: inout [EventModel], removePastEvents: Bool = false) {
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: entityType))

        do {
            let savedEvents = try CoreDataStack.shared.context.fetch(fetchRequest)
            array = savedEvents.compactMap { event in
                guard let title = event.value(forKey: "title") as? String,
                      let startDate = event.value(forKey: "startDate") as? Date,
                      let endDate = event.value(forKey: "endDate") as? Date else {
                    return nil
                }
                return EventModel(title: title, startDate: startDate, endDate: endDate)
            }
        } catch {
            
        }
    }

    private func removePastEvents() {
        let now = Date()

        let fetchRequest: NSFetchRequest<AddedEvent> = AddedEvent.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "endDate < %@", now as NSDate)

        do {
            let pastEvents = try CoreDataStack.shared.context.fetch(fetchRequest)
            for event in pastEvents {
                CoreDataStack.shared.context.delete(event)
            }
            CoreDataStack.shared.saveContext()
        } catch {

        }
        
        addedEvents.removeAll { $0.endDate < now }
        events.removeAll { $0.endDate < now }
    }
    
    private func removeEventFromData<T: NSManagedObject>(_ event: EventModel, entityType: T.Type) {
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: entityType))
        fetchRequest.predicate = NSPredicate(format: "title == %@ AND startDate == %@ AND endDate == %@", event.title, event.startDate as NSDate, event.endDate as NSDate)

        do {
            let events = try CoreDataStack.shared.context.fetch(fetchRequest)
            if let eventToDelete = events.first {
                CoreDataStack.shared.context.delete(eventToDelete)
                CoreDataStack.shared.saveContext()
            }
        } catch {
            
        }
    }
    
    private func updateSelectedTimeLabel(for time: Date, selectTimeButton: UIButton) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "hh:mm"
            
        let formattedTime = formatter.string(from: time)
        selectTimeButton.setTitle(formattedTime, for: .normal)
    }

    private func updateSegmentControl(for time: Date, timeModeSegmCntrl: UISegmentedControl) {
        let hourFormatter = DateFormatter()
        hourFormatter.locale = Locale(identifier: "en_US_POSIX")
        hourFormatter.dateFormat = "a"
            
        let amPmString = hourFormatter.string(from: time)
        
        if amPmString == "AM" {
            timeModeSegmCntrl.selectedSegmentIndex = 0
        } else {
            timeModeSegmCntrl.selectedSegmentIndex = 1
        }
    }
    
    // MARK: - Publick methods
    
    func getEvents(for timeInterval: Calendar.Component, value: Int) -> [EventModel] {
        loadEventsFromData(entityType: AddedEvent.self, into: &addedEvents)
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
    
    func addEvent(_ event: EventModel) {
        addedEvents.append(event)
        saveEventToData(event, entityType: AddedEvent.self)
    }
    
    func addSharedEvent(_ event: EventModel) {
        sharedEvents.append(event)
        saveEventToData(event, entityType: SharedEvent.self)
    }
    
    func addReceivedEvent(_ event: EventModel) {
        receivedEvents.append(event)
        saveEventToData(event, entityType: ReceivedEvent.self)
    }
    
    func getSharedEvents() -> [EventModel] {
        loadEventsFromData(entityType: SharedEvent.self, into: &sharedEvents)
        return sharedEvents
    }
    
    func getReceivedEvents() -> [EventModel] {
        loadEventsFromData(entityType: ReceivedEvent.self, into: &receivedEvents)
        return receivedEvents
    }
    
    func removeSharedEvent(at index: Int) {
        let event = sharedEvents[index]
        sharedEvents.remove(at: index)
        removeEventFromData(event, entityType: SharedEvent.self)
    }
    
    func removeReceivedEvent(at index: Int) {
        let event = receivedEvents[index]
        receivedEvents.remove(at: index)
        removeEventFromData(event, entityType: ReceivedEvent.self)
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
        
        loadEventsFromData(entityType: AddedEvent.self, into: &addedEvents)
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
    
    func updateTimeLabelAndSegmentControl(for time: Date, selectTimeButton: UIButton, timeModeSegmCntrl: UISegmentedControl) {
        updateSelectedTimeLabel(for: time, selectTimeButton: selectTimeButton)
        updateSegmentControl(for: time, timeModeSegmCntrl: timeModeSegmCntrl)
    }
}
