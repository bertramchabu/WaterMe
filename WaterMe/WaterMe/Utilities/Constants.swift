//
//  Constants.swift
//  WaterMe
//
//  Created on 2025-10-13
//

import SwiftUI

/// App-wide constants
enum Constants {
    // MARK: - App Information

    static let appName = "WaterMe"
    static let appVersion = "1.0.0"
    static let appBuild = "1"

    // MARK: - Design System

    enum Design {
        // Colors
        static let primaryColor = Color.blue
        static let accentColor = Color.cyan
        static let successColor = Color.green
        static let warningColor = Color.orange
        static let errorColor = Color.red

        static let waterColor = Color.blue.opacity(0.6)
        static let waterColorDark = Color.blue.opacity(0.8)

        // Spacing
        static let smallPadding: CGFloat = 8
        static let mediumPadding: CGFloat = 16
        static let largePadding: CGFloat = 24
        static let extraLargePadding: CGFloat = 32

        // Corner Radius
        static let smallCornerRadius: CGFloat = 8
        static let mediumCornerRadius: CGFloat = 12
        static let largeCornerRadius: CGFloat = 20

        // Icon Sizes
        static let smallIconSize: CGFloat = 16
        static let mediumIconSize: CGFloat = 24
        static let largeIconSize: CGFloat = 32

        // Animation
        static let standardAnimation: Animation = .easeInOut(duration: 0.3)
        static let waterAnimation: Animation = .easeInOut(duration: 0.5)
        static let springAnimation: Animation = .spring(response: 0.3, dampingFraction: 0.7)
    }

    // MARK: - Default Values

    enum Defaults {
        static let defaultWeight: Double = 70.0 // kg
        static let defaultActivityLevel: ActivityLevel = .moderatelyActive
        static let defaultGoal: Double = 2000 // ml
        static let defaultUnit: WaterUnit = .milliliters
        static let defaultReminderInterval: Int = 60 // minutes
        static let defaultWakeTime: (hour: Int, minute: Int) = (8, 0)
        static let defaultSleepTime: (hour: Int, minute: Int) = (22, 0)

        // Quick add amounts in ml
        static let quickAddAmountsML: [Double] = [100, 250, 330, 500, 750]
        static let quickAddAmountsOz: [Double] = [237, 355, 473, 591] // 8, 12, 16, 20 oz
    }

    // MARK: - Limits

    enum Limits {
        static let minWeight: Double = 20.0
        static let maxWeight: Double = 500.0
        static let minGoal: Double = 500.0
        static let maxGoal: Double = 10000.0
        static let minReminderInterval: Int = 15
        static let maxReminderInterval: Int = 240
        static let minWaterAmount: Double = 1.0
        static let maxWaterAmount: Double = 5000.0
    }

    // MARK: - UserDefaults Keys

    enum UserDefaultsKeys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let lastLaunchDate = "lastLaunchDate"
        static let appLaunchCount = "appLaunchCount"
    }

    // MARK: - Notification Identifiers

    enum NotificationIdentifiers {
        static let hydrationReminder = "hydration-reminder"
        static let goalCompleted = "goal-completed"
        static let motivational = "motivational-reminder"
    }

    // MARK: - HealthKit

    enum HealthKit {
        static let waterIdentifier = "HKQuantityTypeIdentifierDietaryWater"
    }

    // MARK: - Formatting

    enum Format {
        static let dateFormat = "MMM d, yyyy"
        static let timeFormat = "h:mm a"
        static let shortDateFormat = "MMM d"
        static let dayFormat = "EEEE"
    }

    // MARK: - Achievements

    enum Achievements {
        static let streakMilestones = [3, 7, 14, 30, 60, 90, 180, 365]

        static func streakMessage(for days: Int) -> String {
            switch days {
            case 3: return "3 Day Streak! Keep it up!"
            case 7: return "One Week Streak! You're doing great!"
            case 14: return "Two Weeks Strong! Amazing!"
            case 30: return "30 Days! You've built a habit!"
            case 60: return "60 Days! Hydration Master!"
            case 90: return "90 Days! Incredible commitment!"
            case 180: return "Half Year Streak! Legendary!"
            case 365: return "365 Days! Hydration Champion!"
            default: return "\(days) Day Streak!"
            }
        }
    }

    // MARK: - SF Symbols

    enum Symbols {
        static let drop = "drop.fill"
        static let dropTriangle = "drop.triangle"
        static let chart = "chart.bar.fill"
        static let gear = "gearshape.fill"
        static let plus = "plus.circle.fill"
        static let checkmark = "checkmark.circle.fill"
        static let bell = "bell.fill"
        static let heart = "heart.fill"
        static let flame = "flame.fill"
        static let trophy = "trophy.fill"
        static let person = "person.fill"
        static let clock = "clock.fill"
        static let calendar = "calendar"
        static let arrowUp = "arrow.up.circle.fill"
        static let arrowDown = "arrow.down.circle.fill"
        static let xmark = "xmark.circle.fill"
        static let info = "info.circle.fill"
    }
}
