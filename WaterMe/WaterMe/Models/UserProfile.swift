import Foundation
import SwiftData


enum ActivityLevel: String, Codable, CaseIterable {
    case sedentary = "Sedentary"
    case lightlyActive = "Lightly Active"
    case moderatelyActive = "Moderately Active"
    case veryActive = "Very Active"
    case extraActive = "Extra Active"

    
    var multiplier: Double {
        switch self {
        case .sedentary: return 30.0
        case .lightlyActive: return 35.0
        case .moderatelyActive: return 40.0
        case .veryActive: return 45.0
        case .extraActive: return 50.0
        }
    }

    
    var description: String {
        switch self {
        case .sedentary:
            return "Little to no exercise"
        case .lightlyActive:
            return "Light exercise 1-3 days/week"
        case .moderatelyActive:
            return "Moderate exercise 3-5 days/week"
        case .veryActive:
            return "Hard exercise 6-7 days/week"
        case .extraActive:
            return "Very hard exercise & physical job"
        }
    }
}


enum WaterUnit: String, Codable, CaseIterable {
    case milliliters = "ml"
    case fluidOunces = "fl oz"


    var toMilliliters: Double {
        switch self {
        case .milliliters: return 1.0
        case .fluidOunces: return 29.5735
        }
    }


    func convert(from milliliters: Double) -> Double {
        switch self {
        case .milliliters:
            return milliliters
        case .fluidOunces:
            return milliliters / toMilliliters
        }
    }
}



@Model
final class UserProfile {
    var id: UUID
    var name: String
    var weight: Double 
    var activityLevel: ActivityLevel
    var preferredUnit: WaterUnit
    var customGoal: Double? 
    var wakeTime: Date?
    var sleepTime: Date?
    var reminderInterval: Int 
    var isNotificationsEnabled: Bool


    init(
        name: String = "User",
        weight: Double = 70.0,
        activityLevel: ActivityLevel = .moderatelyActive,
        preferredUnit: WaterUnit = .milliliters,
        customGoal: Double? = nil,
        wakeTime: Date? = nil,
        sleepTime: Date? = nil,
        reminderInterval: Int = 60,
        isNotificationsEnabled: Bool = true
    ) {
        self.id = UUID()
        self.name = name
        self.weight = weight
        self.activityLevel = activityLevel
        self.preferredUnit = preferredUnit
        self.customGoal = customGoal
        self.wakeTime = wakeTime
        self.sleepTime = sleepTime
        self.reminderInterval = reminderInterval
        self.isNotificationsEnabled = isNotificationsEnabled
    }
}


extension UserProfile {


    var recommendedDailyGoal: Double {
        weight * activityLevel.multiplier
    }


    var dailyGoal: Double {
        customGoal ?? recommendedDailyGoal
    }


    var formattedDailyGoal: String {
        let converted = preferredUnit.convert(from: dailyGoal)
        return String(format: "%.0f %@", converted, preferredUnit.rawValue)
    }


    var quickAddAmounts: [Double] {
        switch preferredUnit {
        case .milliliters:
            return [100, 250, 330, 500, 750]
        case .fluidOunces:
            // Common US fluid ounce amounts converted to ml
            return [237, 355, 473, 591] // 8oz, 12oz, 16oz, 20oz
        }
    }
}


extension UserProfile {

    static var sample: UserProfile {
        UserProfile(
            name: "Alex",
            weight: 75.0,
            activityLevel: .moderatelyActive,
            preferredUnit: .milliliters,
            reminderInterval: 60,
            isNotificationsEnabled: true
        )
    }
}
