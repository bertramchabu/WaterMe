//
//  WaterEntry.swift
//  WaterMe
//
//  Created on 2025-10-13
//

import Foundation
import SwiftData

/// Protocol defining the core requirements for tracking water consumption
protocol WaterTrackable {
    var amount: Double { get }
    var timestamp: Date { get }
}

/// Represents a single water intake entry
/// Uses SwiftData for persistence and follows protocol-oriented design
@Model
final class WaterEntry: WaterTrackable, Identifiable {
    var id: UUID
    var amount: Double
    var timestamp: Date
    var note: String?

    /// Initializes a new water entry
    /// - Parameters:
    ///   - amount: Amount of water in milliliters
    ///   - timestamp: When the water was consumed (defaults to now)
    ///   - note: Optional note about the entry
    init(amount: Double, timestamp: Date = Date(), note: String? = nil) {
        self.id = UUID()
        self.amount = amount
        self.timestamp = timestamp
        self.note = note
    }
}

// MARK: - Computed Properties
extension WaterEntry {
    /// Returns the date component of the timestamp (ignoring time)
    var dateOnly: Date {
        Calendar.current.startOfDay(for: timestamp)
    }

    /// Formats the amount for display
    var formattedAmount: String {
        String(format: "%.0f ml", amount)
    }

    /// Formats the timestamp for display
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

// MARK: - Sample Data for Previews
extension WaterEntry {
    /// Sample entries for SwiftUI previews and testing
    static var sampleEntries: [WaterEntry] {
        [
            WaterEntry(amount: 250, timestamp: Date().addingTimeInterval(-3600)),
            WaterEntry(amount: 500, timestamp: Date().addingTimeInterval(-7200)),
            WaterEntry(amount: 330, timestamp: Date().addingTimeInterval(-10800)),
            WaterEntry(amount: 250, timestamp: Date().addingTimeInterval(-14400))
        ]
    }

    static var sampleEntry: WaterEntry {
        WaterEntry(amount: 250, timestamp: Date())
    }
}
