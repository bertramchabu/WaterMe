import Foundation
import SwiftData

/// Represents a daily hydration goal and tracks progress
@Model
final class DailyGoal: Identifiable {
    var id: UUID
    var date: Date
    var goalAmount: Double // in milliliters
    var achievedAmount: Double // in milliliters
    var isCompleted: Bool

    
    init(date: Date = Date(), goalAmount: Double, achievedAmount: Double = 0) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.goalAmount = goalAmount
        self.achievedAmount = achievedAmount
        self.isCompleted = achievedAmount >= goalAmount
    }
}


extension DailyGoal {
    
    var progress: Double {
        guard goalAmount > 0 else { return 0 }
        return min(achievedAmount / goalAmount, 1.0)
    }

    
    var progressPercentage: String {
        String(format: "%.0f%%", progress * 100)
    }

    
    var remainingAmount: Double {
        max(0, goalAmount - achievedAmount)
    }

    
    var isOverAchieved: Bool {
        achievedAmount > goalAmount
    }

    
    var excessAmount: Double {
        max(0, achievedAmount - goalAmount)
    }

    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: date)
    }

    
    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }

    
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}


extension DailyGoal {
   
    func updateProgress(to amount: Double) {
        achievedAmount = amount
        isCompleted = achievedAmount >= goalAmount
    }

   
    func addWater(amount: Double) {
        achievedAmount += amount
        isCompleted = achievedAmount >= goalAmount
    }
}


extension DailyGoal {
    static var samples: [DailyGoal] {
        let calendar = Calendar.current
        return [
            DailyGoal(
                date: calendar.date(byAdding: .day, value: -6, to: Date())!,
                goalAmount: 2000,
                achievedAmount: 1800
            ),
            DailyGoal(
                date: calendar.date(byAdding: .day, value: -5, to: Date())!,
                goalAmount: 2000,
                achievedAmount: 2100
            ),
            DailyGoal(
                date: calendar.date(byAdding: .day, value: -4, to: Date())!,
                goalAmount: 2000,
                achievedAmount: 1500
            ),
            DailyGoal(
                date: calendar.date(byAdding: .day, value: -3, to: Date())!,
                goalAmount: 2000,
                achievedAmount: 2200
            ),
            DailyGoal(
                date: calendar.date(byAdding: .day, value: -2, to: Date())!,
                goalAmount: 2000,
                achievedAmount: 1900
            ),
            DailyGoal(
                date: calendar.date(byAdding: .day, value: -1, to: Date())!,
                goalAmount: 2000,
                achievedAmount: 2000
            ),
            DailyGoal(
                date: Date(),
                goalAmount: 2000,
                achievedAmount: 1200
            )
        ]
    }

    static var sample: DailyGoal {
        DailyGoal(date: Date(), goalAmount: 2000, achievedAmount: 1200)
    }
}
