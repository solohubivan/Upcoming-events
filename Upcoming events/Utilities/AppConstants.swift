//
//  AppConstants.swift
//  Upcoming events
//
//  Created by Ivan Solohub on 11.08.2024.
//

import Foundation

enum AppConstants {
    
    enum Fonts {
        static let poppinsSemiBold = "Poppins-SemiBold"
        static let poppinsRegular = "Poppins-Regular"
        static let poppinsMedium = "Poppins-Medium"
    }
    
    enum ImageNames {
        static let trayAndArrowUpFill = "tray.and.arrow.up.fill"
        static let trayAndArrowDownFill = "tray.and.arrow.down.fill"
        static let qrcode = "qrcode"
        static let line3Horizontal = "line.3.horizontal"
        static let plus = "plus"
        static let chevronRight = "chevron.right"
        static let rightChevronAssets = "rightChevron"
        static let leftChevronAssets = "leftChevron"
    }
    
    enum ButtonTitles {
        static let settings = "Settings"
        static let cancel = "Cancel"
        static let week = "Week"
        static let month = "Month"
        static let year = "Year"
        static let custom = "Custom"
        static let ok = "OK"
        static let createNewEvent = "Create new event"
    }
    
    enum AlertMessages {
        static let titleAccessDenied = "Access Denied"
        static let messageDoesntHaveAccessToCalendar = "This app does not have access to your calendar. Please go to Settings and enable access."
        static let titleEnterEventTitlePls = "Enter event title please"
        static let messageEventsStart = "Start"
        static let messageEventsEnd = "End"
        static let titleEvent = "Event"
        static let titleAdded = "added"
        static let selectDateUpToday = "Please select a date up today"
        static let lessThanMin = "less than a min"
        static let noTitle = "No title"
        static let shareAlertAction = "Share"
        static let shareWithQRAlertAction = "Share with QR"
    }
    
    enum Identifiers {
        static let defaultTableCell = "DefaultCell"
        static let customTableCell = "CustomCell"
    }
    
    enum Keys {
        static let qrCodeInputMessageKey = "inputMessage"
    }
    
    enum MainViewController {
        static let titleSharedEvents = "Shared events"
        static let titleReceivedEvents = "Received events"
        static let titleGetEventWithQR = "Get event with QR"
        static let titleLabel = "My Events"
    }
    
    enum AddNewEventVC {
        static let titleLabelText = "Create new event here"
        static let tFPlaceholderText = "Enter the event title here"
        static let startDateLabelText = "Start date:"
        static let endDateLabelText = "End date:"
    }
    
    enum SharingEventsVC {
        static let sharedTitleLabelText = "Shared events"
        static let receivedTitleLabelText = "Received events"
        static let sharedSgmntCntrlItemText = "Shared"
        static let receivedSgmntCntrlItemText = "Received"
    }
    
    enum CustomContainerView {
        static let timetitleLabelText = "Time"
        static let amSgmntCtrlItemText = "AM"
        static let pmSgmntCtrlItemText = "PM"
    }
}
