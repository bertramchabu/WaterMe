//
//  HomeViewModel.swift
//  WaterMe
//
//  Created on 2025-10-13
//

import Foundation
import SwiftUI

/// ViewModel for the Home screen
/// Manages water intake tracking and daily goal progress
@MainActor
final class HomeViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published private(set) var todayIntake: Double = 0
    @Published private(set) var dailyGoal: Double = 2000
    @Published private(set) var todayEntries: [WaterEntry] = []
    @Published private(set) var userProfile: UserProfile?
    @Published private(set) var currentStreak: Int = 0

    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showSuccess = false
    @Published var successMessage = ""

    // Feedback
    @Published var showAddWaterSheet = false
    @Published var customAmount = ""

    // MARK: - Dependencies

    private let dataManager = DataManager.shared
    private let healthKitManager = HealthKitManager.shared
    private let notificationManager = NotificationManager.shared

    // MARK: - Computed Properties

    /// Progress percentage (0.0 to 1.0)
    var progress: Double {
        guard dailyGoal > 0 else { return 0 }
        return min(todayIntake / dailyGoal, 1.0)
    }

    /// Remaining amount to reach goal
    var remainingAmount: Double {
        max(0, dailyGoal - todayIntake)
    }

    /// Whether goal is completed
    var isGoalCompleted: Bool {
        todayIntake >= dailyGoal
    }

    /// Formatted progress percentage
    var progressPercentage: String {
        String(format: "%.0f%%", progress * 100)
    }

    /// Quick add button amounts
    var quickAddAmounts: [Double] {
        userProfile?.quickAddAmounts ?? [100, 250, 330, 500]
    }

    // MARK: - Initialization

    init() {
        Task {
            await loadData()
        }
    }

    // MARK: - Data Loading

    /// Loads all necessary data for the home screen
    func loadData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Load user profile
            userProfile = try await dataManager.fetchUserProfile()
            dailyGoal = userProfile?.dailyGoal ?? 2000

            // Load today's entries and calculate intake
            todayEntries = try await dataManager.fetchEntries(for: Date())
            todayIntake = todayEntries.reduce(0) { $0 + $1.amount }

            // Load streak
            currentStreak = try await dataManager.calculateStreak()

        } catch {
            handleError(error)
        }
    }

    /// Refreshes the data
    func refresh() async {
        await loadData()
    }

    // MARK: - Add Water

    /// Adds water intake with a predefined amount
    /// - Parameter amount: Amount in milliliters
    func addWater(amount: Double) async {
        do {
            guard amount > 0 else {
                throw DataError.invalidAmount
            }

            let previouslyCompleted = isGoalCompleted

            // Add to local data
            try await dataManager.addWaterEntry(amount: amount, timestamp: Date())

            // Sync to HealthKit if authorized
            if healthKitManager.isAuthorized {
                try? await healthKitManager.saveWaterIntake(amount: amount)
            }

            // Reload data
            await loadData()

            // Show success feedback
            let formatted = formatAmount(amount)
            successMessage = "\(formatted) added!"
            showSuccess = true

            // Provide haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            // Hide success message after delay
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            showSuccess = false

            // Check if goal just completed
            if !previouslyCompleted && isGoalCompleted {
                await celebrateGoalCompletion()
            }

        } catch {
            handleError(error)
        }
    }

    /// Adds custom water amount
    func addCustomAmount() async {
        guard let amount = Double(customAmount), amount > 0 else {
            errorMessage = "Please enter a valid amount"
            showError = true
            return
        }

        await addWater(amount: amount)
        customAmount = ""
        showAddWaterSheet = false
    }

    // MARK: - Delete Entry

    /// Deletes a water entry
    /// - Parameter entry: The entry to delete
    func deleteEntry(_ entry: WaterEntry) async {
        do {
            try await dataManager.deleteEntry(entry)
            await loadData()

            successMessage = "Entry deleted"
            showSuccess = true

            try? await Task.sleep(nanoseconds: 1_500_000_000)
            showSuccess = false

        } catch {
            handleError(error)
        }
    }

    // MARK: - Goal Completion

    /// Celebrates goal completion with animation and notification
    private func celebrateGoalCompletion() async {
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Send notification
        if notificationManager.isAuthorized {
            try? await notificationManager.scheduleGoalCompletionNotification()
        }

        // Show congratulations message
        successMessage = "🎉 Goal achieved! Great job!"
        showSuccess = true

        try? await Task.sleep(nanoseconds: 3_000_000_000)
        showSuccess = false
    }

    // MARK: - Formatting

    /// Formats amount based on user preference
    /// - Parameter amount: Amount in milliliters
    /// - Returns: Formatted string
    func formatAmount(_ amount: Double) -> String {
        guard let profile = userProfile else {
            return String(format: "%.0f ml", amount)
        }

        let converted = profile.preferredUnit.convert(from: amount)
        return String(format: "%.0f %@", converted, profile.preferredUnit.rawValue)
    }

    /// Formats the daily goal
    var formattedDailyGoal: String {
        formatAmount(dailyGoal)
    }

    /// Formats today's intake
    var formattedTodayIntake: String {
        formatAmount(todayIntake)
    }

    /// Formats remaining amount
    var formattedRemainingAmount: String {
        formatAmount(remainingAmount)
    }

    // MARK: - Error Handling

    /// Handles errors and displays appropriate message
    /// - Parameter error: The error to handle
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}
