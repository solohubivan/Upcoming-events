//
//  CalendarManager.swift
//  Upcoming events
//
//  Created by Ivan Solohub on 28.08.2024.
//

import Foundation
import EventKit

class EventsManager {
    
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
    
//    static let shared = EventsManager()
//    
//    private var addedEvents: [EventModel] = []
//    private var events: [EventModel] = []
//    
//    private let eventStore = EKEventStore()
//    
//    init() {
//        loadAddedEvents()
//        removePastEvents()
//    }
//    
//    private func saveAddedEvents() {
//        if let data = try? JSONEncoder().encode(addedEvents) {
//            UserDefaults.standard.set(data, forKey: "addedEvents")
//        }
//    }
//
//    private func loadAddedEvents() {
//        if let data = UserDefaults.standard.data(forKey: "addedEvents"),
//            let savedEvents = try? JSONDecoder().decode([EventModel].self, from: data) {
//            addedEvents = savedEvents
//        }
//        removePastEvents()
//    }
//    
//    private func removePastEvents() {
//        let now = Date()
//        addedEvents.removeAll { $0.endDate < now }
//        events.removeAll { $0.endDate < now }
//        saveAddedEvents()
//    }
//
//    func getEvents() -> [EventModel] {
//        removePastEvents()
//        return events + addedEvents
//    }
//    
//    func addEvent(_ event: EventModel) {
//        addedEvents.append(event)
//        saveAddedEvents()
//    }
//    
//    func fetchEvents(for timeInterval: Calendar.Component, value: Int, completion: @escaping () -> Void) {
//        let startDate = Date()
//        let endDate = Calendar.current.date(byAdding: timeInterval, value: value, to: startDate)
//            
//        guard let endDate = endDate else { return }
//        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
//        let ekEvents = eventStore.events(matching: predicate)
//                    
//        events.removeAll()
//                    
//        for ekEvent in ekEvents {
//            let event = EventModel(title: ekEvent.title ?? "No title", startDate: ekEvent.startDate, endDate: ekEvent.endDate)
//            events.append(event)
//        }
//        removePastEvents()
//        completion()
//    }
//    
//    func getCurrentPeriodLabel(for timeInterval: Calendar.Component, value: Int) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MMM d"
//            
//        let calendar = Calendar.current
//        let today = Date()
//
//        guard let endOfPeriod = calendar.date(byAdding: timeInterval, value: value, to: today) else { return "" }
//            
//        let todayString = dateFormatter.string(from: today)
//        let endOfPeriodString = dateFormatter.string(from: endOfPeriod)
//            
//        let startYear = calendar.component(.year, from: today)
//        let endYear = calendar.component(.year, from: endOfPeriod)
//            
//        if startYear == endYear {
//            return "\(todayString) - \(endOfPeriodString), \(startYear)"
//        } else {
//            return "\(todayString), \(startYear) - \(endOfPeriodString), \(endYear)"
//        }
//    }
//    
//    func formatTimeForLabel(_ interval: TimeInterval) -> String {
//        let days = Int(interval) / 86400
//        let hours = (Int(interval) % 86400) / 3600
//        let minutes = (Int(interval) % 3600) / 60
//        
//        switch (days, hours, minutes) {
//        case (let d, _, _) where d > 0:
//            return "\(d)d \(hours)h \(minutes)m"
//        case (_, let h, _) where h > 0:
//            return "\(h)h \(minutes)m"
//        case (_, _, let m) where m > 0:
//            return "\(m)m"
//        default:
//            return "less than a min"
//        }
//    }
    
//    func filterEventsBySelectedTime(_ selectedTime: Date, forDate selectedDate: Date) -> [EventModel] {
//        let calendar = Calendar.current
//        let timeZone = TimeZone.current
//
//        let selectedDateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
//        let selectedTimeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
//
//        var combinedComponents = DateComponents()
//        combinedComponents.year = selectedDateComponents.year
//        combinedComponents.month = selectedDateComponents.month
//        combinedComponents.day = selectedDateComponents.day
//        combinedComponents.hour = selectedTimeComponents.hour
//        combinedComponents.minute = selectedTimeComponents.minute
//
//        guard let combinedDateTime = calendar.date(from: combinedComponents) else { return [] }
//        let localSelectedTime = combinedDateTime.addingTimeInterval(TimeInterval(timeZone.secondsFromGMT(for: combinedDateTime)))
//
//        let filteredEvents = events.filter { event in
//            let localStartTime = event.startDate.addingTimeInterval(TimeInterval(timeZone.secondsFromGMT(for: event.startDate)))
//            let localEndTime = event.endDate.addingTimeInterval(TimeInterval(timeZone.secondsFromGMT(for: event.endDate)))
//
//            return localSelectedTime >= localStartTime && localSelectedTime <= localEndTime
//        }
//        return filteredEvents
//    }
}
