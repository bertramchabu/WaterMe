//
//  SettingsViewModel.swift
//  WaterMe
//
//  Created on 2025-10-13
//

import Foundation
import SwiftUI

/// ViewModel for the Settings screen
/// Manages user profile and app preferences
@MainActor
final class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var userProfile: UserProfile?

    // Form fields (bound to UI)
    @Published var name: String = ""
    @Published var weight: String = ""
    @Published var selectedActivityLevel: ActivityLevel = .moderatelyActive
    @Published var selectedUnit: WaterUnit = .milliliters
    @Published var customGoalEnabled: Bool = false
    @Published var customGoal: String = ""
    @Published var reminderInterval: Double = 60
    @Published var notificationsEnabled: Bool = false
    @Published var wakeTime: Date = Date().setTime(hour: 8, minute: 0)
    @Published var sleepTime: Date = Date().setTime(hour: 22, minute: 0)

    // HealthKit
    @Published var healthKitEnabled: Bool = false
    @Published var healthKitAvailable: Bool = false

    // UI State
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showSuccess = false
    @Published var successMessage = ""
    @Published var showResetConfirmation = false

    // MARK: - Dependencies

    private let dataManager = DataManager.shared
    private let healthKitManager = HealthKitManager.shared
    private let notificationManager = NotificationManager.shared

    // MARK: - Computed Properties

    /// Calculated recommended goal based on weight and activity
    var recommendedGoal: Double {
        guard let weightValue = Double(weight) else { return 2000 }
        return weightValue * selectedActivityLevel.multiplier
    }

    /// Formatted recommended goal
    var formattedRecommendedGoal: String {
        let converted = selectedUnit.convert(from: recommendedGoal)
        return String(format: "%.0f %@", converted, selectedUnit.rawValue)
    }

    // Active daily goal (custom or recommended)
    var activeDailyGoal: Double {
        if customGoalEnabled, let customValue = Double(customGoal) {
            return customValue * selectedUnit.toMilliliters
        }
        return recommendedGoal
    }

    // MARK: - Initialization

    init() {
        healthKitAvailable = healthKitManager.isAvailable

        Task {
            await loadSettings()
            await checkPermissions()
        }
    }

    // MARK: - Data Loading

    /// Loads user settings
    func loadSettings() async {
        isLoading = true
        defer { isLoading = false }

        do {
            userProfile = try await dataManager.fetchUserProfile()

            guard let profile = userProfile else { return }

            // Populate form fields
            name = profile.name
            weight = String(format: "%.1f", profile.weight)
            selectedActivityLevel = profile.activityLevel
            selectedUnit = profile.preferredUnit
            reminderInterval = Double(profile.reminderInterval)
            notificationsEnabled = profile.isNotificationsEnabled
            wakeTime = profile.wakeTime ?? Date().setTime(hour: 8, minute: 0)
            sleepTime = profile.sleepTime ?? Date().setTime(hour: 22, minute: 0)

            if let custom = profile.customGoal {
                customGoalEnabled = true
                let converted = selectedUnit.convert(from: custom)
                customGoal = String(format: "%.0f", converted)
            } else {
                customGoalEnabled = false
                customGoal = ""
            }

        } catch {
            handleError(error)
        }
    }

    /// Checks permission statuses
    func checkPermissions() async {
        await notificationManager.checkAuthorizationStatus()
        notificationsEnabled = notificationManager.isAuthorized

        await healthKitManager.checkAuthorizationStatus()
        healthKitEnabled = healthKitManager.isAuthorized
    }

    // MARK: - Save Settings

    /// Saves all settings
    func saveSettings() async {
        guard let profile = userProfile else {
            errorMessage = "User profile not found"
            showError = true
            return
        }

        guard let weightValue = Double(weight), weightValue > 0 else {
            errorMessage = "Please enter a valid weight"
            showError = true
            return
        }

        do {
            // Update profile
            profile.name = name
            profile.weight = weightValue
            profile.activityLevel = selectedActivityLevel
            profile.preferredUnit = selectedUnit
            profile.reminderInterval = Int(reminderInterval)
            profile.isNotificationsEnabled = notificationsEnabled
            profile.wakeTime = wakeTime
            profile.sleepTime = sleepTime

            // Set custom goal if enabled
            if customGoalEnabled {
                if let customValue = Double(customGoal), customValue > 0 {
                    profile.customGoal = customValue * selectedUnit.toMilliliters
                } else {
                    errorMessage = "Please enter a valid custom goal"
                    showError = true
                    return
                }
            } else {
                profile.customGoal = nil
            }

            // Save to database
            try await dataManager.updateUserProfile(profile)

            // Update notifications if enabled
            if notificationsEnabled {
                try await setupNotifications()
            } else {
                await notificationManager.cancelAllReminders()
            }

            // Show success
            successMessage = "Settings saved successfully!"
            showSuccess = true

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            try? await Task.sleep(nanoseconds: 2_000_000_000)
            showSuccess = false

        } catch {
            handleError(error)
        }
    }

    // MARK: - Notifications

    /// Requests notification permission
    func requestNotificationPermission() async {
        do {
            let granted = try await notificationManager.requestPermission()
            notificationsEnabled = granted

            if granted {
                try await setupNotifications()
                successMessage = "Notifications enabled"
                showSuccess = true
            } else {
                errorMessage = "Please enable notifications in Settings"
                showError = true
            }
        } catch {
            handleError(error)
        }
    }

    /// Sets up notification schedule
    private func setupNotifications() async throws {
        try await notificationManager.scheduleReminders(
            interval: Int(reminderInterval),
            wakeTime: wakeTime,
            sleepTime: sleepTime
        )
    }

    /// Toggles notifications
    func toggleNotifications() async {
        if notificationsEnabled {
            // Turning on - request permission if needed
            if !notificationManager.isAuthorized {
                await requestNotificationPermission()
            } else {
                do {
                    try await setupNotifications()
                } catch {
                    handleError(error)
                    notificationsEnabled = false
                }
            }
        } else {
            // Turning off - cancel all
            await notificationManager.cancelAllReminders()
        }
    }

    // MARK: - HealthKit

    /// Requests HealthKit permission
    func requestHealthKitPermission() async {
        do {
            let granted = try await healthKitManager.requestAuthorization()
            healthKitEnabled = granted

            if granted {
                successMessage = "HealthKit connected"
                showSuccess = true

                // Sync existing data
                try await syncDataToHealthKit()
            } else {
                errorMessage = "Please enable HealthKit in Settings"
                showError = true
            }
        } catch {
            handleError(error)
        }
    }

    /// Syncs existing data to HealthKit
    private func syncDataToHealthKit() async throws {
        let entries = try await dataManager.fetchAllEntries()
        try await healthKitManager.syncEntries(entries)
    }

    /// Toggles HealthKit integration
    func toggleHealthKit() async {
        if healthKitEnabled {
            if !healthKitManager.isAuthorized {
                await requestHealthKitPermission()
            }
        } else {
            healthKitEnabled = false
        }
    }

    // MARK: - Data Management

    /// Shows reset confirmation dialog
    func showResetDialog() {
        showResetConfirmation = true
    }

    /// Resets all app data
    func resetAllData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Delete all entries
            let entries = try await dataManager.fetchAllEntries()
            for entry in entries {
                try await dataManager.deleteEntry(entry)
            }

            // Reset profile to defaults
            if let profile = userProfile {
                profile.name = "User"
                profile.weight = 70.0
                profile.activityLevel = .moderatelyActive
                profile.customGoal = nil
                try await dataManager.updateUserProfile(profile)
            }

            // Reload settings
            await loadSettings()

            successMessage = "All data has been reset"
            showSuccess = true

        } catch {
            handleError(error)
        }
    }

    // MARK: - Validation

    /// Validates weight input
    func validateWeight() -> Bool {
        guard let weightValue = Double(weight) else { return false }
        return weightValue > 0 && weightValue < 500
    }

    /// Validates custom goal input
    func validateCustomGoal() -> Bool {
        if !customGoalEnabled { return true }
        guard let goalValue = Double(customGoal) else { return false }
        return goalValue > 0
    }

    // MARK: - Error Handling

    /// Handles errors
    /// - Parameter error: The error to handle
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}
