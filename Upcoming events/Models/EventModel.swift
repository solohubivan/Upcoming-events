//
//  EventModel.swift
//  Upcoming events
//
//  Created by Ivan Solohub on 27.08.2024.
//

import EventKit

struct EventModel: Codable {
    let title: String
    let startDate: Date
    let endDate: Date
}
