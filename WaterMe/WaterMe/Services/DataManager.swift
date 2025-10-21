//
//  DataManager.swift
//  WaterMe
//
//  Created on 2025-10-13
//

import Foundation
import SwiftData

/// Custom errors for data operations
enum DataError: Error, LocalizedError {
    case invalidAmount
    case saveFailed
    case loadFailed
    case deleteFailed
    case profileNotFound

    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "Invalid water amount. Please enter a positive value."
        case .saveFailed:
            return "Failed to save data. Please try again."
        case .loadFailed:
            return "Failed to load data. Please check your connection."
        case .deleteFailed:
            return "Failed to delete entry. Please try again."
        case .profileNotFound:
            return "User profile not found. Please create a profile first."
        }
    }
}

/// Manages all data operations for the app using SwiftData
/// Implements singleton pattern for centralized data management
@MainActor
final class DataManager: ObservableObject {
    static let shared = DataManager()

    private var modelContext: ModelContext?

    /// Configures the data manager with a model context
    /// - Parameter context: The SwiftData model context
    func configure(with context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - Water Entry Operations

    /// Adds a new water entry
    /// - Parameters:
    ///   - amount: Amount of water in milliliters
    ///   - timestamp: When the water was consumed
    ///   - note: Optional note
    /// - Throws: DataError if validation fails or save fails
    func addWaterEntry(amount: Double, timestamp: Date = Date(), note: String? = nil) async throws {
        guard amount > 0 else {
            throw DataError.invalidAmount
        }

        guard let context = modelContext else {
            throw DataError.saveFailed
        }

        let entry = WaterEntry(amount: amount, timestamp: timestamp, note: note)
        context.insert(entry)

        do {
            try context.save()
            // Update today's goal
            try await updateTodayGoal()
        } catch {
            throw DataError.saveFailed
        }
    }

    /// Fetches water entries for a specific date
    /// - Parameter date: The date to fetch entries for
    /// - Returns: Array of water entries
    func fetchEntries(for date: Date) async throws -> [WaterEntry] {
        guard let context = modelContext else {
            throw DataError.loadFailed
        }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = #Predicate<WaterEntry> { entry in
            entry.timestamp >= startOfDay && entry.timestamp < endOfDay
        }

        let descriptor = FetchDescriptor<WaterEntry>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )

        do {
            return try context.fetch(descriptor)
        } catch {
            throw DataError.loadFailed
        }
    }

    /// Fetches all water entries
    /// - Returns: Array of all water entries
    func fetchAllEntries() async throws -> [WaterEntry] {
        guard let context = modelContext else {
            throw DataError.loadFailed
        }

        let descriptor = FetchDescriptor<WaterEntry>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )

        do {
            return try context.fetch(descriptor)
        } catch {
            throw DataError.loadFailed
        }
    }

    /// Deletes a water entry
    /// - Parameter entry: The entry to delete
    func deleteEntry(_ entry: WaterEntry) async throws {
        guard let context = modelContext else {
            throw DataError.deleteFailed
        }

        context.delete(entry)

        do {
            try context.save()
            try await updateTodayGoal()
        } catch {
            throw DataError.deleteFailed
        }
    }

    /// Calculates total water intake for a specific date
    /// - Parameter date: The date to calculate for
    /// - Returns: Total amount in milliliters
    func calculateTotalIntake(for date: Date) async throws -> Double {
        let entries = try await fetchEntries(for: date)
        return entries.reduce(0) { $0 + $1.amount }
    }

    // MARK: - Daily Goal Operations

    /// Fetches or creates today's goal
    /// - Returns: The daily goal for today
    func fetchTodayGoal() async throws -> DailyGoal {
        guard let context = modelContext else {
            throw DataError.loadFailed
        }

        let today = Calendar.current.startOfDay(for: Date())

        let predicate = #Predicate<DailyGoal> { goal in
            goal.date == today
        }

        let descriptor = FetchDescriptor<DailyGoal>(predicate: predicate)

        do {
            let goals = try context.fetch(descriptor)
            if let existingGoal = goals.first {
                return existingGoal
            } else {
                // Create new goal for today
                let profile = try await fetchUserProfile()
                let newGoal = DailyGoal(date: today, goalAmount: profile.dailyGoal)
                context.insert(newGoal)
                try context.save()
                return newGoal
            }
        } catch {
            throw DataError.loadFailed
        }
    }

    /// Updates today's goal with current intake
    private func updateTodayGoal() async throws {
        let todayGoal = try await fetchTodayGoal()
        let totalIntake = try await calculateTotalIntake(for: Date())
        todayGoal.updateProgress(to: totalIntake)

        guard let context = modelContext else {
            throw DataError.saveFailed
        }

        try context.save()
    }

    /// Fetches goals for a date range
    /// - Parameters:
    ///   - startDate: Start of the range
    ///   - endDate: End of the range
    /// - Returns: Array of daily goals
    func fetchGoals(from startDate: Date, to endDate: Date) async throws -> [DailyGoal] {
        guard let context = modelContext else {
            throw DataError.loadFailed
        }

        let start = Calendar.current.startOfDay(for: startDate)
        let end = Calendar.current.startOfDay(for: endDate)

        let predicate = #Predicate<DailyGoal> { goal in
            goal.date >= start && goal.date <= end
        }

        let descriptor = FetchDescriptor<DailyGoal>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )

        do {
            return try context.fetch(descriptor)
        } catch {
            throw DataError.loadFailed
        }
    }

    // MARK: - User Profile Operations

    /// Fetches the user profile
    /// - Returns: The user profile
    func fetchUserProfile() async throws -> UserProfile {
        guard let context = modelContext else {
            throw DataError.loadFailed
        }

        let descriptor = FetchDescriptor<UserProfile>()

        do {
            let profiles = try context.fetch(descriptor)
            if let profile = profiles.first {
                return profile
            } else {
                // Create default profile
                let newProfile = UserProfile()
                context.insert(newProfile)
                try context.save()
                return newProfile
            }
        } catch {
            throw DataError.loadFailed
        }
    }

    /// Updates the user profile
    /// - Parameter profile: The updated profile
    func updateUserProfile(_ profile: UserProfile) async throws {
        guard let context = modelContext else {
            throw DataError.saveFailed
        }

        do {
            try context.save()
        } catch {
            throw DataError.saveFailed
        }
    }

    // MARK: - Statistics

    /// Calculates the current streak of completed goals
    /// - Returns: Number of consecutive days with completed goals
    func calculateStreak() async throws -> Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())

        while true {
            let predicate = #Predicate<DailyGoal> { goal in
                goal.date == currentDate
            }

            let descriptor = FetchDescriptor<DailyGoal>(predicate: predicate)

            guard let context = modelContext,
                  let goal = try context.fetch(descriptor).first,
                  goal.isCompleted else {
                break
            }

            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                break
            }
            currentDate = previousDay
        }

        return streak
    }

    /// Calculates average daily intake for the past week
    /// - Returns: Average intake in milliliters
    func calculateWeeklyAverage() async throws -> Double {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: today) else {
            return 0
        }

        let goals = try await fetchGoals(from: weekAgo, to: today)
        guard !goals.isEmpty else { return 0 }

        let total = goals.reduce(0) { $0 + $1.achievedAmount }
        return total / Double(goals.count)
    }
}
