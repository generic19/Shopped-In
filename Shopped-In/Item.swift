//
//  Item.swift
//  Shopped-In
//
//  Created by Basel Alasadi on 29/05/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
