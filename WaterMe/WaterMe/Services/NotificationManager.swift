

import Foundation
import UserNotifications


enum NotificationError: Error, LocalizedError {
    case permissionDenied
    case scheduleFailed
    case invalidTimeRange

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Notification permission denied. Please enable notifications in Settings."
        case .scheduleFailed:
            return "Failed to schedule notification. Please try again."
        case .invalidTimeRange:
            return "Invalid time range. Wake time must be before sleep time."
        }
    }
}


@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    private let notificationCenter = UNUserNotificationCenter.current()

    @Published private(set) var isAuthorized = false

    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }


    func requestPermission() async throws -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            isAuthorized = granted
            return granted
        } catch {
            throw NotificationError.permissionDenied
        }
    }


    func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    
    func scheduleReminders(
        interval: Int,
        wakeTime: Date = Date().setTime(hour: 8, minute: 0),
        sleepTime: Date = Date().setTime(hour: 22, minute: 0)
    ) async throws {
        guard isAuthorized else {
            throw NotificationError.permissionDenied
        }

        
        await cancelAllReminders()

        let calendar = Calendar.current
        let wakeComponents = calendar.dateComponents([.hour, .minute], from: wakeTime)
        let sleepComponents = calendar.dateComponents([.hour, .minute], from: sleepTime)

        guard let wakeHour = wakeComponents.hour,
              let wakeMinute = wakeComponents.minute,
              let sleepHour = sleepComponents.hour,
              let sleepMinute = sleepComponents.minute else {
            throw NotificationError.invalidTimeRange
        }

        
        let wakeMinutes = wakeHour * 60 + wakeMinute
        let sleepMinutes = sleepHour * 60 + sleepMinute
        let activeMinutes = sleepMinutes - wakeMinutes

        guard activeMinutes > 0 else {
            throw NotificationError.invalidTimeRange
        }

        let reminderCount = activeMinutes / interval

        
        for i in 0..<reminderCount {
            let reminderMinutes = wakeMinutes + (i * interval)
            let hour = reminderMinutes / 60
            let minute = reminderMinutes % 60

            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute

            let content = UNMutableNotificationContent()
            content.title = "Time to Hydrate!"
            content.body = getRandomReminderMessage()
            content.sound = .default
            content.categoryIdentifier = "HYDRATION_REMINDER"

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: true
            )

            let identifier = "hydration-reminder-\(i)"
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )

            do {
                try await notificationCenter.add(request)
            } catch {
                throw NotificationError.scheduleFailed
            }
        }
    }

    
    func scheduleGoalCompletionNotification(delay: TimeInterval = 1) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Goal Achieved!"
        content.body = "Congratulations! You've reached your daily hydration goal!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: delay,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "goal-completed",
            content: content,
            trigger: trigger
        )

        try await notificationCenter.add(request)
    }

    
    func scheduleMotivationalReminder(at hour: Int) async throws {
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = 0

        let content = UNMutableNotificationContent()
        content.title = "Stay Hydrated!"
        content.body = "You're doing great! Keep up with your hydration today."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: "motivational-reminder",
            content: content,
            trigger: trigger
        )

        try await notificationCenter.add(request)
    }

    
    func cancelAllReminders() async {
        notificationCenter.removeAllPendingNotificationRequests()
    }

    
    
    func cancelReminder(withIdentifier identifier: String) async {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    
    private func getRandomReminderMessage() -> String {
        let messages = [
            "Time to drink some water! Stay hydrated!",
            "Don't forget to drink water! Your body will thank you.",
            "Hydration check! Have you had water recently?",
            "A quick water break will boost your energy!",
            "Keep your hydration streak going! Time for water.",
            "Your body is 60% water. Time to replenish!",
            "Stay refreshed! Drink some water now.",
            "Water break! Your brain will thank you.",
            "Feeling tired? Water might help! Time to hydrate.",
            "Remember: proper hydration = better focus!"
        ]

        return messages.randomElement() ?? "Time to drink water!"
    }

    
    func getPendingNotificationCount() async -> Int {
        let requests = await notificationCenter.pendingNotificationRequests()
        return requests.count
    }

    
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        await notificationCenter.pendingNotificationRequests()
    }
}


extension Date {
    
    static func setTime(hour: Int, minute: Int) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        components.second = 0
        return Calendar.current.date(from: components) ?? Date()
    }
}
