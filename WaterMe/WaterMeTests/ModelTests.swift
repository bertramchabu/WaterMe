//
//  ModelTests.swift
//  WaterMeTests
//
//  Created on 2025-10-13
//

import XCTest
@testable import WaterMe

/// Unit tests for data models
final class ModelTests: XCTestCase {

    // MARK: - WaterEntry Tests

    func testWaterEntryInitialization() {
        // Given
        let amount = 250.0
        let timestamp = Date()
        let note = "Morning water"

        // When
        let entry = WaterEntry(amount: amount, timestamp: timestamp, note: note)

        // Then
        XCTAssertEqual(entry.amount, amount)
        XCTAssertEqual(entry.timestamp, timestamp)
        XCTAssertEqual(entry.note, note)
        XCTAssertNotNil(entry.id)
    }

    func testWaterEntryFormattedAmount() {
        // Given
        let entry = WaterEntry(amount: 250.0)

        // When
        let formatted = entry.formattedAmount

        // Then
        XCTAssertEqual(formatted, "250 ml")
    }

    func testWaterEntryDateOnly() {
        // Given
        let calendar = Calendar.current
        let components = DateComponents(year: 2025, month: 10, day: 13, hour: 14, minute: 30)
        let timestamp = calendar.date(from: components)!
        let entry = WaterEntry(amount: 250.0, timestamp: timestamp)

        // When
        let dateOnly = entry.dateOnly

        // Then
        let expectedDate = calendar.startOfDay(for: timestamp)
        XCTAssertEqual(dateOnly, expectedDate)
    }

    // MARK: - UserProfile Tests

    func testUserProfileDefaultInitialization() {
        // When
        let profile = UserProfile()

        // Then
        XCTAssertEqual(profile.name, "User")
        XCTAssertEqual(profile.weight, 70.0)
        XCTAssertEqual(profile.activityLevel, .moderatelyActive)
        XCTAssertEqual(profile.preferredUnit, .milliliters)
        XCTAssertNil(profile.customGoal)
        XCTAssertTrue(profile.isNotificationsEnabled)
    }

    func testUserProfileRecommendedGoalCalculation() {
        // Given
        let profile = UserProfile(weight: 80.0, activityLevel: .veryActive)

        // When
        let recommendedGoal = profile.recommendedDailyGoal

        // Then
        // 80kg × 45 (very active multiplier) = 3600ml
        XCTAssertEqual(recommendedGoal, 3600.0)
    }

    func testUserProfileDailyGoalWithCustom() {
        // Given
        let profile = UserProfile(weight: 70.0, customGoal: 2500.0)

        // When
        let dailyGoal = profile.dailyGoal

        // Then
        XCTAssertEqual(dailyGoal, 2500.0)
    }

    func testUserProfileDailyGoalWithoutCustom() {
        // Given
        let profile = UserProfile(weight: 70.0, activityLevel: .moderatelyActive)

        // When
        let dailyGoal = profile.dailyGoal

        // Then
        // Should use recommended: 70 × 40 = 2800
        XCTAssertEqual(dailyGoal, 2800.0)
    }

    func testUserProfileQuickAddAmounts() {
        // Given
        let mlProfile = UserProfile(preferredUnit: .milliliters)
        let ozProfile = UserProfile(preferredUnit: .fluidOunces)

        // When
        let mlAmounts = mlProfile.quickAddAmounts
        let ozAmounts = ozProfile.quickAddAmounts

        // Then
        XCTAssertEqual(mlAmounts, [100, 250, 330, 500, 750])
        XCTAssertEqual(ozAmounts, [237, 355, 473, 591])
    }

    // MARK: - DailyGoal Tests

    func testDailyGoalInitialization() {
        // Given
        let date = Date()
        let goalAmount = 2000.0
        let achievedAmount = 1500.0

        // When
        let goal = DailyGoal(date: date, goalAmount: goalAmount, achievedAmount: achievedAmount)

        // Then
        XCTAssertEqual(goal.goalAmount, goalAmount)
        XCTAssertEqual(goal.achievedAmount, achievedAmount)
        XCTAssertFalse(goal.isCompleted)
    }

    func testDailyGoalProgress() {
        // Given
        let goal = DailyGoal(date: Date(), goalAmount: 2000.0, achievedAmount: 1000.0)

        // When
        let progress = goal.progress

        // Then
        XCTAssertEqual(progress, 0.5, accuracy: 0.001)
    }

    func testDailyGoalProgressCappedAtOne() {
        // Given
        let goal = DailyGoal(date: Date(), goalAmount: 2000.0, achievedAmount: 3000.0)

        // When
        let progress = goal.progress

        // Then
        XCTAssertEqual(progress, 1.0)
    }

    func testDailyGoalIsCompleted() {
        // Given
        let incompletGoal = DailyGoal(date: Date(), goalAmount: 2000.0, achievedAmount: 1500.0)
        let completedGoal = DailyGoal(date: Date(), goalAmount: 2000.0, achievedAmount: 2000.0)

        // Then
        XCTAssertFalse(incompletGoal.isCompleted)
        XCTAssertTrue(completedGoal.isCompleted)
    }

    func testDailyGoalRemainingAmount() {
        // Given
        let goal = DailyGoal(date: Date(), goalAmount: 2000.0, achievedAmount: 1300.0)

        // When
        let remaining = goal.remainingAmount

        // Then
        XCTAssertEqual(remaining, 700.0)
    }

    func testDailyGoalUpdateProgress() {
        // Given
        let goal = DailyGoal(date: Date(), goalAmount: 2000.0, achievedAmount: 1000.0)

        // When
        goal.updateProgress(to: 2000.0)

        // Then
        XCTAssertEqual(goal.achievedAmount, 2000.0)
        XCTAssertTrue(goal.isCompleted)
    }

    func testDailyGoalAddWater() {
        // Given
        let goal = DailyGoal(date: Date(), goalAmount: 2000.0, achievedAmount: 1500.0)

        // When
        goal.addWater(amount: 500.0)

        // Then
        XCTAssertEqual(goal.achievedAmount, 2000.0)
        XCTAssertTrue(goal.isCompleted)
    }

    func testDailyGoalIsToday() {
        // Given
        let todayGoal = DailyGoal(date: Date(), goalAmount: 2000.0)
        let yesterdayGoal = DailyGoal(
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            goalAmount: 2000.0
        )

        // Then
        XCTAssertTrue(todayGoal.isToday)
        XCTAssertFalse(yesterdayGoal.isToday)
    }

    // MARK: - ActivityLevel Tests

    func testActivityLevelMultipliers() {
        XCTAssertEqual(ActivityLevel.sedentary.multiplier, 30.0)
        XCTAssertEqual(ActivityLevel.lightlyActive.multiplier, 35.0)
        XCTAssertEqual(ActivityLevel.moderatelyActive.multiplier, 40.0)
        XCTAssertEqual(ActivityLevel.veryActive.multiplier, 45.0)
        XCTAssertEqual(ActivityLevel.extraActive.multiplier, 50.0)
    }

    // MARK: - WaterUnit Tests

    func testWaterUnitConversion() {
        // Test milliliters (no conversion)
        XCTAssertEqual(WaterUnit.milliliters.convert(from: 1000.0), 1000.0)

        // Test fluid ounces conversion
        let mlToOz = WaterUnit.fluidOunces.convert(from: 1000.0)
        XCTAssertEqual(mlToOz, 33.814, accuracy: 0.01)
    }

    func testWaterUnitToMilliliters() {
        XCTAssertEqual(WaterUnit.milliliters.toMilliliters, 1.0)
        XCTAssertEqual(WaterUnit.fluidOunces.toMilliliters, 29.5735, accuracy: 0.0001)
    }
}
