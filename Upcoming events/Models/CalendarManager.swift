//
//  CalendarManager.swift
//  Upcoming events
//
//  Created by Ivan Solohub on 28.08.2024.
//

import Foundation
import EventKit

class CalendarManager {
    
    var events: [EventModel] = []
    
    let eventStore = EKEventStore()

    func getEvents() -> [EventModel] {
        return events
    }
    
    func getEventsCount() -> Int {
        events.count
    }
    
    func fetchEvents(for timeInterval: Calendar.Component, completion: @escaping () -> Void) {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: timeInterval, value: 1, to: startDate)
            
        guard let endDate = endDate else { return }
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let ekEvents = eventStore.events(matching: predicate)
                    
        events.removeAll()
                    
        for ekEvent in ekEvents {
            let event = EventModel(title: ekEvent.title ?? "No title", startDate: ekEvent.startDate, endDate: ekEvent.endDate)
            events.append(event)
        }
        completion()
    }
    
    func getCurrentPeriodLabel(for timeInterval: Calendar.Component) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
            
        let calendar = Calendar.current
        let today = Date()
        
        let endOfPeriod = calendar.date(byAdding: timeInterval, value: 1, to: today) ?? today
        
        let todayString = dateFormatter.string(from: today)
        let endOfPeriodString = dateFormatter.string(from: endOfPeriod)
        
        let year = calendar.component(.year, from: today)
        
        return "\(todayString) - \(endOfPeriodString), \(year)"
    }
}
