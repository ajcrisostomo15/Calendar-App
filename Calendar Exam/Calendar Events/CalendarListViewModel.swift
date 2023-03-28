//
//  CalendarListViewModel.swift
//  Calendar Exam
//
//  Created by Allen Jeffrey Crisostomo on 3/25/23.
//

import RxSwift
import RxRelay
import EventKit

let eventStore = EKEventStore()
class CalendarListViewModel {
    var events = BehaviorRelay<[EKEvent]>(value: [])
    
    init() {
        requestCalendarAccess()
    }
    
    func getCalendarEvents() {
        
        
        let calendars = eventStore.calendars(for: .event)
        
        for calendar in calendars {
            let oneMonthAgo = Date(timeIntervalSinceNow: -120*24*3600)
            let oneMonthAfter = Date(timeIntervalSinceNow: 30*24*3600)
            let predicate =  eventStore.predicateForEvents(withStart: oneMonthAgo, end: oneMonthAfter, calendars: [calendar])
            
            let fetchedEvents = eventStore.events(matching: predicate)
            
            var oldEvents = self.events.value
            oldEvents.append(contentsOf: fetchedEvents)
            self.events.accept(oldEvents.uniqued())
        }
    }
    
    private func requestCalendarAccess() {
        eventStore.requestAccess( to: EKEntityType.event, completion:{(granted, error) in
            if granted && error == nil {
                self.getCalendarEvents()
            } else {
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                    DispatchQueue.main.async {
                        UIApplication.shared.open(appSettings)
                    }
                }
                print(error?.localizedDescription)
            }
        })
    }
    
    func deleteEvent(_ event: EKEvent) {
        do {
            try eventStore.remove(event, span: .thisEvent, commit: true)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getEvent(atIndex index: Int) -> EKEvent {
        let staleEvent = self.events.value[index]
        if let id = staleEvent.eventIdentifier {
            if let newEvent = eventStore.event(withIdentifier: id) {
                return newEvent
            }
        }
        
        return self.events.value[index]
    }
}

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
