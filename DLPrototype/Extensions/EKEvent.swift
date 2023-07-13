//
//  EKEvent.swift
//  DLPrototype
//
//  Created by Ryan Priebe on 2023-05-19.
//  Copyright © 2023 YegCollective. All rights reserved.
//

import Foundation
import SwiftUI
import EventKit

//extension EKEvent {
//    var colour: Color {
//
//    }
//}

// TODO: bah this doesn't work yet
public class DLPEKEvent: EKEvent {
    public var eventStore: EKEventStore
    public var colour: Color = Color.clear

    public init(eventStore: EKEventStore, colour: Color) {
        self.eventStore = eventStore
        self.colour = colour
    }
}
