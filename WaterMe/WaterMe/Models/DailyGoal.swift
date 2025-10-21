//
//  DailyGoal.swift
//  WaterMe
//
//  Created on 2025-10-13
//

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

    /// Initializes a daily goal
    /// - Parameters:
    ///   - date: The date for this goal
    ///   - goalAmount: Target amount in milliliters
    ///   - achievedAmount: Current progress in milliliters
    init(date: Date = Date(), goalAmount: Double, achievedAmount: Double = 0) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.goalAmount = goalAmount
        self.achievedAmount = achievedAmount
        self.isCompleted = achievedAmount >= goalAmount
    }
}

// MARK: - Computed Properties
extension DailyGoal {
    /// Progress percentage (0.0 to 1.0+)
    var progress: Double {
        guard goalAmount > 0 else { return 0 }
        return min(achievedAmount / goalAmount, 1.0)
    }

    /// Progress percentage as a string
    var progressPercentage: String {
        String(format: "%.0f%%", progress * 100)
    }

    /// Remaining amount to reach goal
    var remainingAmount: Double {
        max(0, goalAmount - achievedAmount)
    }

    /// Whether the goal has been exceeded
    var isOverAchieved: Bool {
        achievedAmount > goalAmount
    }

    /// Amount exceeded beyond goal
    var excessAmount: Double {
        max(0, achievedAmount - goalAmount)
    }

    /// Formats the date for display
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    /// Short date format (e.g., "Mon, Oct 13")
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: date)
    }

    /// Day of week
    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }

    /// Check if this goal is for today
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
}

// MARK: - Methods
extension DailyGoal {
    /// Updates the achieved amount and completion status
    /// - Parameter amount: New total achieved amount
    func updateProgress(to amount: Double) {
        achievedAmount = amount
        isCompleted = achievedAmount >= goalAmount
    }

    /// Adds water intake to the goal
    /// - Parameter amount: Amount to add in milliliters
    func addWater(amount: Double) {
        achievedAmount += amount
        isCompleted = achievedAmount >= goalAmount
    }
}

// MARK: - Sample Data
extension DailyGoal {
    /// Sample goals for previews
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
