//
//  HistoryViewModel.swift
//  WaterMe
//
//  Created on 2025-10-13
//

import Foundation
import SwiftUI

/// Time period for viewing history
enum HistoryPeriod: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case threeMonths = "3 Months"

    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .threeMonths: return 90
        }
    }
}

/// ViewModel for the History screen
/// Manages historical data and statistics
@MainActor
final class HistoryViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var selectedPeriod: HistoryPeriod = .week
    @Published private(set) var goals: [DailyGoal] = []
    @Published private(set) var entries: [WaterEntry] = []

    @Published private(set) var currentStreak: Int = 0
    @Published private(set) var longestStreak: Int = 0
    @Published private(set) var averageIntake: Double = 0
    @Published private(set) var totalIntake: Double = 0
    @Published private(set) var goalsCompleted: Int = 0
    @Published private(set) var bestDay: DailyGoal?

    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""

    // MARK: - Dependencies

    private let dataManager = DataManager.shared

    // MARK: - Computed Properties

    /// Completion rate as percentage
    var completionRate: Double {
        guard !goals.isEmpty else { return 0 }
        let completed = goals.filter { $0.isCompleted }.count
        return Double(completed) / Double(goals.count)
    }

    /// Formatted completion rate
    var formattedCompletionRate: String {
        String(format: "%.0f%%", completionRate * 100)
    }

    /// Chart data for visualization
    var chartData: [(date: Date, amount: Double)] {
        goals.map { ($0.date, $0.achievedAmount) }
    }

    /// Goal line value for chart
    var goalLineValue: Double {
        goals.first?.goalAmount ?? 2000
    }

    // MARK: - Initialization

    init() {
        Task {
            await loadData()
        }
    }

    // MARK: - Data Loading

    /// Loads history data for selected period
    func loadData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let calendar = Calendar.current
            let endDate = calendar.startOfDay(for: Date())
            guard let startDate = calendar.date(byAdding: .day, value: -selectedPeriod.days, to: endDate) else {
                return
            }

            // Fetch goals for period
            goals = try await dataManager.fetchGoals(from: startDate, to: endDate)

            // Fill in missing days with empty goals
            goals = fillMissingDays(from: startDate, to: endDate, with: goals)

            // Fetch all entries for the period
            entries = try await fetchAllEntriesInPeriod(from: startDate, to: endDate)

            // Calculate statistics
            await calculateStatistics()

        } catch {
            handleError(error)
        }
    }

    /// Fetches all entries in the specified period
    private func fetchAllEntriesInPeriod(from startDate: Date, to endDate: Date) async throws -> [WaterEntry] {
        var allEntries: [WaterEntry] = []
        let calendar = Calendar.current

        var currentDate = startDate
        while currentDate <= endDate {
            let dayEntries = try await dataManager.fetchEntries(for: currentDate)
            allEntries.append(contentsOf: dayEntries)

            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDay
        }

        return allEntries
    }

    /// Fills in missing days with empty goals
    private func fillMissingDays(from startDate: Date, to endDate: Date, with goals: [DailyGoal]) -> [DailyGoal] {
        let calendar = Calendar.current
        var filledGoals: [DailyGoal] = []
        let goalsByDate = Dictionary(uniqueKeysWithValues: goals.map { ($0.date, $0) })

        var currentDate = startDate
        while currentDate <= endDate {
            let dayStart = calendar.startOfDay(for: currentDate)

            if let existingGoal = goalsByDate[dayStart] {
                filledGoals.append(existingGoal)
            } else {
                // Create empty goal for missing day
                let emptyGoal = DailyGoal(date: dayStart, goalAmount: 2000, achievedAmount: 0)
                filledGoals.append(emptyGoal)
            }

            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDay
        }

        return filledGoals.sorted { $0.date < $1.date }
    }

    // MARK: - Statistics

    /// Calculates all statistics
    private func calculateStatistics() async {
        // Current streak
        currentStreak = try? await dataManager.calculateStreak() ?? 0

        // Longest streak
        longestStreak = calculateLongestStreak()

        // Average intake
        let validGoals = goals.filter { $0.achievedAmount > 0 }
        if !validGoals.isEmpty {
            averageIntake = validGoals.reduce(0) { $0 + $1.achievedAmount } / Double(validGoals.count)
        } else {
            averageIntake = 0
        }

        // Total intake
        totalIntake = goals.reduce(0) { $0 + $1.achievedAmount }

        // Goals completed
        goalsCompleted = goals.filter { $0.isCompleted }.count

        // Best day
        bestDay = goals.max { $0.achievedAmount < $1.achievedAmount }
    }

    /// Calculates longest streak in the selected period
    private func calculateLongestStreak() -> Int {
        var maxStreak = 0
        var currentStreak = 0

        for goal in goals.sorted(by: { $0.date < $1.date }) {
            if goal.isCompleted {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 0
            }
        }

        return maxStreak
    }

    // MARK: - Period Selection

    /// Changes the selected period and reloads data
    /// - Parameter period: New period to display
    func changePeriod(to period: HistoryPeriod) async {
        selectedPeriod = period
        await loadData()
    }

    // MARK: - Refresh

    /// Refreshes the data
    func refresh() async {
        await loadData()
    }

    // MARK: - Export

    /// Exports data as CSV string
    /// - Returns: CSV formatted string
    func exportAsCSV() -> String {
        var csv = "Date,Intake (ml),Goal (ml),Completed\n"

        for goal in goals.sorted(by: { $0.date < $1.date }) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short

            let date = dateFormatter.string(from: goal.date)
            let intake = String(format: "%.0f", goal.achievedAmount)
            let goalAmount = String(format: "%.0f", goal.goalAmount)
            let completed = goal.isCompleted ? "Yes" : "No"

            csv += "\(date),\(intake),\(goalAmount),\(completed)\n"
        }

        return csv
    }

    /// Shares exported data
    func shareData() -> URL? {
        let csv = exportAsCSV()

        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "WaterMe_Export_\(Date().ISO8601Format()).csv"
        let fileURL = tempDir.appendingPathComponent(fileName)

        do {
            try csv.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            handleError(error)
            return nil
        }
    }

    // MARK: - Formatting

    /// Formats amount for display
    /// - Parameter amount: Amount in milliliters
    /// - Returns: Formatted string
    func formatAmount(_ amount: Double) -> String {
        String(format: "%.0f ml", amount)
    }

    /// Formats average with unit
    var formattedAverage: String {
        formatAmount(averageIntake)
    }

    /// Formats total with unit
    var formattedTotal: String {
        formatAmount(totalIntake)
    }

    // MARK: - Error Handling

    /// Handles errors
    /// - Parameter error: The error to handle
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
}

// MARK: - Date Extension
extension Date {
    /// Returns ISO8601 formatted string
    func ISO8601Format() -> String {
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
}
