
import XCTest
// UI tests for main user flows
final class WaterMeUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    

    func testAppLaunches() throws {
        // Verify app launches successfully
        XCTAssertTrue(app.state == .runningForeground)
    }

    func testTabBarExists() throws {
        // Verify all tabs are present
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists)

        XCTAssertTrue(app.tabBars.buttons["Home"].exists)
        XCTAssertTrue(app.tabBars.buttons["History"].exists)
        XCTAssertTrue(app.tabBars.buttons["Settings"].exists)
    }

    

    func testHomeScreenElements() throws {
        // Verify home screen key elements exist
        XCTAssertTrue(app.navigationBars["WaterMe"].exists)

        // Check for water glass visualization (could be an image or custom view)
        // This depends on accessibility identifiers you add to views
    }

    func testQuickAddButtons() throws {
        // Verify quick add buttons are present
        // You'll need to add accessibility identifiers to your quick add buttons

        // Example:
        // XCTAssertTrue(app.buttons["250ml"].exists)
        // XCTAssertTrue(app.buttons["500ml"].exists)
    }

    func testAddWaterFlow() throws {
        // Test adding water using quick add button
        // This assumes you've added accessibility identifiers

        // Example flow:
        // 1. Tap a quick add button
        // let quickAddButton = app.buttons["250ml"]
        // XCTAssertTrue(quickAddButton.exists)
        // quickAddButton.tap()

        // 2. Verify success message appears
    // ...existing code...
        // XCTAssertTrue(successMessage.firstMatch.exists)
    }

    func testCustomAmountSheet() throws {
        // Test opening custom amount sheet
        // This assumes you've added an accessibility identifier to the custom button

        // Example:
        // let customButton = app.buttons["Custom"]
        // XCTAssertTrue(customButton.exists)
        // customButton.tap()

        // Verify sheet appeared
        // XCTAssertTrue(app.navigationBars["Add Custom Amount"].exists)
    }


    func testNavigateToHistory() throws {
        // Navigate to history tab
        app.tabBars.buttons["History"].tap()

        // Verify history screen elements
        XCTAssertTrue(app.navigationBars["History"].exists)

        // Check for period selector (segmented control)
        // XCTAssertTrue(app.segmentedControls.firstMatch.exists)
    }

    func testHistoryPeriodSelector() throws {
        // Navigate to history
        app.tabBars.buttons["History"].tap()

        // Test period selector
        let segmentedControl = app.segmentedControls.firstMatch
        if segmentedControl.exists {
            let buttons = segmentedControl.buttons

            // Tap different periods
            if buttons.count > 1 {
                buttons.element(boundBy: 1).tap()

                // Verify period changed (chart should update)
                // This is tricky to test without specific accessibility identifiers
            }
        }
    }

    func testNavigateToSettings() throws {
        // Navigate to settings tab
        app.tabBars.buttons["Settings"].tap()

        // Verify settings screen elements
        XCTAssertTrue(app.navigationBars["Settings"].exists)

        // Check for form elements
        XCTAssertTrue(app.staticTexts["Profile"].exists)
    }

    func testSettingsFormElements() throws {
        // Navigate to settings
        app.tabBars.buttons["Settings"].tap()

        // Verify form sections exist
        XCTAssertTrue(app.staticTexts["Profile"].exists)
        XCTAssertTrue(app.staticTexts["Hydration Goal"].exists)
        XCTAssertTrue(app.staticTexts["Notifications"].exists)
    }

    func testSettingsToggleNotifications() throws {
        // Navigate to settings
        app.tabBars.buttons["Settings"].tap()

        // Find and toggle notifications switch
        let notificationSwitch = app.switches["Enable Reminders"]
        if notificationSwitch.exists {
            let initialValue = notificationSwitch.value as? String
            notificationSwitch.tap()

            // Verify toggle changed
            let newValue = notificationSwitch.value as? String
            XCTAssertNotEqual(initialValue, newValue)
        }
    }


    func testTabNavigation() throws {
        // Test navigating between all tabs

        // Start at Home
        XCTAssertTrue(app.navigationBars["WaterMe"].exists)

        // Go to History
        app.tabBars.buttons["History"].tap()
        XCTAssertTrue(app.navigationBars["History"].exists)

        // Go to Settings
        app.tabBars.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].exists)

        // Back to Home
        app.tabBars.buttons["Home"].tap()
        XCTAssertTrue(app.navigationBars["WaterMe"].exists)
    }


    func testAccessibilityLabels() throws {
        // Verify important elements have accessibility labels
        // This helps with VoiceOver support

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists)

        // Tab bar buttons should have labels
        let homeButton = app.tabBars.buttons["Home"]
        XCTAssertTrue(homeButton.exists)
        XCTAssertTrue(homeButton.isHittable)
    }



    func testAppLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    func testScrollPerformance() throws {
        // Navigate to History which has scrollable content
        app.tabBars.buttons["History"].tap()

        let scrollView = app.scrollViews.firstMatch

        measure(metrics: [XCTOSSignpostMetric.scrollDecelerationMetric]) {
            scrollView.swipeUp()
            scrollView.swipeDown()
        }
    }
}
