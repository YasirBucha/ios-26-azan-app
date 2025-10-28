import Foundation
import EventKit
import Combine

@MainActor
class CalendarManager: ObservableObject {
    private let eventStore = EKEventStore()
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    @Published var isInMeeting: Bool = false
    
    init() {
        checkAuthorizationStatus()
    }
    
    func requestCalendarAccess() async -> Bool {
        let status = await eventStore.requestFullAccessToEvents()
        await MainActor.run {
            self.authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        }
        return status
    }
    
    private func checkAuthorizationStatus() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
    }
    
    func checkIfCurrentlyInMeeting() -> Bool {
        guard authorizationStatus == .fullAccess else { return false }
        
        let now = Date()
        let calendar = Calendar.current
        
        // Create a predicate to find events happening now
        let predicate = eventStore.predicateForEvents(
            withStart: now,
            end: now,
            calendars: nil
        )
        
        let events = eventStore.events(matching: predicate)
        
        // Check if any event is currently happening
        for event in events {
            if event.startDate <= now && event.endDate >= now {
                // Check if this looks like a meeting (has attendees, is not all-day, etc.)
                if !event.isAllDay && (event.hasAttendees || event.title.lowercased().contains("meeting") || event.title.lowercased().contains("call")) {
                    return true
                }
            }
        }
        
        return false
    }
    
    func checkIfInMeetingAtTime(_ date: Date) -> Bool {
        guard authorizationStatus == .fullAccess else { return false }
        
        let calendar = Calendar.current
        
        // Create a predicate to find events at the given time
        let predicate = eventStore.predicateForEvents(
            withStart: date,
            end: date,
            calendars: nil
        )
        
        let events = eventStore.events(matching: predicate)
        
        // Check if any event is happening at the given time
        for event in events {
            if event.startDate <= date && event.endDate >= date {
                // Check if this looks like a meeting
                if !event.isAllDay && (event.hasAttendees || event.title.lowercased().contains("meeting") || event.title.lowercased().contains("call")) {
                    return true
                }
            }
        }
        
        return false
    }
    
    func getUpcomingMeetings(withinMinutes: Int = 30) -> [EKEvent] {
        guard authorizationStatus == .fullAccess else { return [] }
        
        let now = Date()
        let endDate = Calendar.current.date(byAdding: .minute, value: withinMinutes, to: now) ?? now
        
        let predicate = eventStore.predicateForEvents(
            withStart: now,
            end: endDate,
            calendars: nil
        )
        
        let events = eventStore.events(matching: predicate)
        
        return events.filter { event in
            !event.isAllDay && (event.hasAttendees || event.title.lowercased().contains("meeting") || event.title.lowercased().contains("call"))
        }
    }
}
