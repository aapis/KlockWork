//
//  SyncMonitor.swift
//  DLPrototype
//
//  Created by https://stackoverflow.com/a/63927190
//

import Combine
import CoreData

class SyncMonitor {
    /// Where we store Combine cancellables for publishers we're listening to, e.g. NSPersistentCloudKitContainer's notifications.
    fileprivate var disposables = Set<AnyCancellable>()
    
    public var publisher = NotificationCenter.default.publisher(for: NSPersistentCloudKitContainer.eventChangedNotification)
    public var event: NSPersistentCloudKitContainer.EventType
    public var ready: Bool = false

    init() {
        self.event = NSPersistentCloudKitContainer.EventType.import // default import?
        run()
    }
    
    public func run() -> Void {
        publisher.sink(receiveValue: { notification in
                print("SM: \(notification)")
                if let cloudEvent = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey]
                    as? NSPersistentCloudKitContainer.Event {
                    // NSPersistentCloudKitContainer sends a notification when an event starts, and another when it
                    // ends. If it has an endDate, it means the event finished.
                    if cloudEvent.endDate == nil {
                        print("SM: Starting an event...") // You could check the type, but I'm trying to keep this brief.
                    } else {
                        self.event = cloudEvent.type
                        var setupEventComplete = false
                        
                        switch self.event {
                        case .setup:
                            print("SM: Setup finished!")
                            setupEventComplete = true
                        case .import:
                            print("SM: An import finished!")
                        case .export:
                            print("SM: An export finished!")
                        @unknown default:
                            assertionFailure("SM: NSPersistentCloudKitContainer added a new event type.")
                        }

                        if cloudEvent.succeeded {
                            if setupEventComplete {
                                self.ready = true
                            }
                            print("SM: And it succeeded!")
                        } else {
                            print("SM: But it failed!")
                        }

                        if let error = cloudEvent.error {
                            print("SM: Error: \(error.localizedDescription)")
                        }
                    }
                }
            })
            .store(in: &disposables)
    }
}
