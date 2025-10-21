
import Foundation
import SwiftData


protocol WaterTrackable {
    var amount: Double { get }
    var timestamp: Date { get }
}



@Model
final class WaterEntry: WaterTrackable, Identifiable {
    var id: UUID
    var amount: Double
    var timestamp: Date
    var note: String?

    init(amount: Double, timestamp: Date = Date(), note: String? = nil) {
        self.id = UUID()
        self.amount = amount
        self.timestamp = timestamp
        self.note = note
    }
}


extension WaterEntry {
    
    var dateOnly: Date {
        Calendar.current.startOfDay(for: timestamp)
    }

    
    var formattedAmount: String {
        String(format: "%.0f ml", amount)
    }

    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}


extension WaterEntry {

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
