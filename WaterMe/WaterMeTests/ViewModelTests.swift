

import XCTest
@testable import WaterMe

/// Unit tests for ViewModels
@MainActor
final class ViewModelTests: XCTestCase {


    func testHomeViewModelInitialization() {
        // When
        let viewModel = HomeViewModel()

        // Then
        XCTAssertEqual(viewModel.todayIntake, 0)
        XCTAssertEqual(viewModel.dailyGoal, 2000)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.showError)
        XCTAssertFalse(viewModel.showSuccess)
    }

    func testHomeViewModelProgress() {
        // Given
        let viewModel = HomeViewModel()

        // When - Set today's intake manually for testing
        viewModel.todayIntake = 1000
        viewModel.dailyGoal = 2000

        // Then
        XCTAssertEqual(viewModel.progress, 0.5, accuracy: 0.001)
    }

    func testHomeViewModelProgressCappedAtOne() {
        // Given
        let viewModel = HomeViewModel()

        // When
        viewModel.todayIntake = 3000
        viewModel.dailyGoal = 2000

        // Then
        XCTAssertEqual(viewModel.progress, 1.0)
    }

    func testHomeViewModelRemainingAmount() {
        // Given
        let viewModel = HomeViewModel()

        // When
        viewModel.todayIntake = 1200
        viewModel.dailyGoal = 2000

        // Then
        XCTAssertEqual(viewModel.remainingAmount, 800)
    }

    func testHomeViewModelIsGoalCompleted() {
        // Given
        let viewModel = HomeViewModel()

        // When - Not completed
        viewModel.todayIntake = 1500
        viewModel.dailyGoal = 2000
        XCTAssertFalse(viewModel.isGoalCompleted)

        // When - Completed
        viewModel.todayIntake = 2000
        XCTAssertTrue(viewModel.isGoalCompleted)
    }

    func testHomeViewModelProgressPercentage() {
        // Given
        let viewModel = HomeViewModel()

        // When
        viewModel.todayIntake = 750
        viewModel.dailyGoal = 1500

        // Then
        XCTAssertEqual(viewModel.progressPercentage, "50%")
    }


    func testSettingsViewModelInitialization() {
        // When
        let viewModel = SettingsViewModel()

        // Then
        XCTAssertEqual(viewModel.name, "")
        XCTAssertEqual(viewModel.weight, "")
        XCTAssertEqual(viewModel.selectedActivityLevel, .moderatelyActive)
        XCTAssertEqual(viewModel.selectedUnit, .milliliters)
        XCTAssertFalse(viewModel.customGoalEnabled)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testSettingsViewModelRecommendedGoal() {
        // Given
        let viewModel = SettingsViewModel()

        // When
        viewModel.weight = "75.0"
        viewModel.selectedActivityLevel = .veryActive

        // Then
        // 75kg × 45 = 3375ml
        XCTAssertEqual(viewModel.recommendedGoal, 3375.0)
    }

    func testSettingsViewModelActiveDailyGoal() {
        // Given
        let viewModel = SettingsViewModel()

        // When - Without custom goal
        viewModel.weight = "70.0"
        viewModel.selectedActivityLevel = .moderatelyActive
        viewModel.customGoalEnabled = false

        // Then - Should use recommended
        XCTAssertEqual(viewModel.activeDailyGoal, 2800.0)

        // When - With custom goal
        viewModel.customGoalEnabled = true
        viewModel.customGoal = "3000"
        viewModel.selectedUnit = .milliliters

        // Then - Should use custom
        XCTAssertEqual(viewModel.activeDailyGoal, 3000.0)
    }

    func testSettingsViewModelValidateWeight() {
        // Given
        let viewModel = SettingsViewModel()

        // When - Valid weight
        viewModel.weight = "75.5"
        XCTAssertTrue(viewModel.validateWeight())

        // When - Invalid weight (non-numeric)
        viewModel.weight = "abc"
        XCTAssertFalse(viewModel.validateWeight())

        // When - Invalid weight (too high)
        viewModel.weight = "600"
        XCTAssertFalse(viewModel.validateWeight())

        // When - Invalid weight (negative)
        viewModel.weight = "-10"
        XCTAssertFalse(viewModel.validateWeight())
    }

    func testSettingsViewModelValidateCustomGoal() {
        // Given
        let viewModel = SettingsViewModel()

        // When - Custom goal disabled
        viewModel.customGoalEnabled = false
        XCTAssertTrue(viewModel.validateCustomGoal())

        // When - Valid custom goal
        viewModel.customGoalEnabled = true
        viewModel.customGoal = "2500"
        XCTAssertTrue(viewModel.validateCustomGoal())

        // When - Invalid custom goal
        viewModel.customGoal = "invalid"
        XCTAssertFalse(viewModel.validateCustomGoal())
    }

 

    func testHistoryViewModelInitialization() {
        // When
        let viewModel = HistoryViewModel()

        // Then
        XCTAssertEqual(viewModel.selectedPeriod, .week)
        XCTAssertEqual(viewModel.goals, [])
        XCTAssertEqual(viewModel.currentStreak, 0)
        XCTAssertEqual(viewModel.longestStreak, 0)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testHistoryViewModelCompletionRate() {
        // Given
        let viewModel = HistoryViewModel()

        // When - No goals
        XCTAssertEqual(viewModel.completionRate, 0.0)

        // When - Some goals completed
        let goal1 = DailyGoal(date: Date(), goalAmount: 2000, achievedAmount: 2000)
        let goal2 = DailyGoal(date: Date(), goalAmount: 2000, achievedAmount: 1500)
        let goal3 = DailyGoal(date: Date(), goalAmount: 2000, achievedAmount: 2100)

        viewModel.goals = [goal1, goal2, goal3]

        // Then - 2 out of 3 = 0.666...
        XCTAssertEqual(viewModel.completionRate, 0.666, accuracy: 0.01)
    }

    func testHistoryViewModelFormattedCompletionRate() {
        // Given
        let viewModel = HistoryViewModel()

        // When
        let goal1 = DailyGoal(date: Date(), goalAmount: 2000, achievedAmount: 2000)
        let goal2 = DailyGoal(date: Date(), goalAmount: 2000, achievedAmount: 2000)
        viewModel.goals = [goal1, goal2]

        // Then
        XCTAssertEqual(viewModel.formattedCompletionRate, "100%")
    }

    func testHistoryViewModelChartData() {
        // Given
        let viewModel = HistoryViewModel()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // When
        let goal1 = DailyGoal(date: today, goalAmount: 2000, achievedAmount: 1800)
        let goal2 = DailyGoal(
            date: calendar.date(byAdding: .day, value: -1, to: today)!,
            goalAmount: 2000,
            achievedAmount: 2100
        )

        viewModel.goals = [goal2, goal1]

        // Then
        XCTAssertEqual(viewModel.chartData.count, 2)
        XCTAssertEqual(viewModel.chartData[0].amount, 2100)
        XCTAssertEqual(viewModel.chartData[1].amount, 1800)
    }

    func testHistoryViewModelExportCSV() {
        // Given
        let viewModel = HistoryViewModel()
        let goal = DailyGoal(date: Date(), goalAmount: 2000, achievedAmount: 1500)
        viewModel.goals = [goal]

        // When
        let csv = viewModel.exportAsCSV()

        // Then
        XCTAssertTrue(csv.contains("Date,Intake (ml),Goal (ml),Completed"))
        XCTAssertTrue(csv.contains("1500"))
        XCTAssertTrue(csv.contains("2000"))
    }
}
