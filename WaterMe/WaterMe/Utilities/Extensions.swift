//
//  Extensions.swift
//  WaterMe
//
//  Created on 2025-10-13
//

import SwiftUI

// MARK: - View Extensions

extension View {
    /// Applies a card-like styling to the view
    func cardStyle() -> some View {
        self
            .background(Color(.systemBackground))
            .cornerRadius(Constants.Design.mediumCornerRadius)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    /// Applies standard padding
    func standardPadding() -> some View {
        self.padding(Constants.Design.mediumPadding)
    }

    /// Conditionally applies a modifier
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Hides the view based on a condition
    @ViewBuilder
    func hidden(_ hidden: Bool) -> some View {
        if hidden {
            self.hidden()
        } else {
            self
        }
    }

    /// Applies a shimmer effect for loading states
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

// MARK: - Color Extensions

extension Color {
    /// Creates a color from hex string
    /// - Parameter hex: Hex string (e.g., "FF5733" or "#FF5733")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// Water gradient colors
    static let waterGradient = LinearGradient(
        colors: [Color.blue.opacity(0.6), Color.cyan.opacity(0.4)],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Glass effect color
    static let glassEffect = Color.white.opacity(0.1)
}

// MARK: - Date Extensions

extension Date {
    /// Returns true if the date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    /// Returns true if the date is in the current week
    var isThisWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }

    /// Returns true if the date is in the current month
    var isThisMonth: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }

    /// Returns the start of the day
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// Returns the end of the day
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    /// Returns the start of the week
    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components)!
    }

    /// Returns the start of the month
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }

    /// Formats date as relative string (Today, Yesterday, etc.)
    func relativeString() -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else if calendar.isDateInTomorrow(self) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: self)
        }
    }

    /// Sets the time component of the date
    func setTime(hour: Int, minute: Int) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        components.hour = hour
        components.minute = minute
        components.second = 0
        return Calendar.current.date(from: components) ?? self
    }
}

// MARK: - Double Extensions

extension Double {
    /// Rounds to specified decimal places
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    /// Converts milliliters to liters
    var toLiters: Double {
        self / 1000.0
    }

    /// Converts liters to milliliters
    var toMilliliters: Double {
        self * 1000.0
    }

    /// Converts milliliters to fluid ounces
    var toFluidOunces: Double {
        self / 29.5735
    }

    /// Converts fluid ounces to milliliters
    var fromFluidOunces: Double {
        self * 29.5735
    }
}

// MARK: - String Extensions

extension String {
    /// Validates if string is a valid number
    var isValidNumber: Bool {
        Double(self) != nil
    }

    /// Validates if string is a valid email
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }

    /// Trims whitespace and newlines
    var trimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Int Extensions

extension Int {
    /// Formats as ordinal string (1st, 2nd, 3rd, etc.)
    var ordinal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

// MARK: - Array Extensions

extension Array where Element == WaterEntry {
    /// Total amount from all entries
    var totalAmount: Double {
        self.reduce(0) { $0 + $1.amount }
    }

    /// Entries for a specific date
    func entries(for date: Date) -> [WaterEntry] {
        let calendar = Calendar.current
        return self.filter { calendar.isDate($0.timestamp, inSameDayAs: date) }
    }
}

extension Array where Element == DailyGoal {
    /// Completed goals count
    var completedCount: Int {
        self.filter { $0.isCompleted }.count
    }

    /// Completion rate
    var completionRate: Double {
        guard !self.isEmpty else { return 0 }
        return Double(completedCount) / Double(count)
    }

    /// Average achieved amount
    var averageAchieved: Double {
        guard !self.isEmpty else { return 0 }
        let total = self.reduce(0) { $0 + $1.achievedAmount }
        return total / Double(count)
    }
}

// MARK: - Custom Modifiers

/// Shimmer effect modifier for loading states
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .clear,
                        .white.opacity(0.3),
                        .clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 200
                }
            }
    }
}

// MARK: - Custom Shapes

/// Rounded corner shape with specific corners
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension View {
    /// Applies corner radius to specific corners
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - Haptic Feedback

enum HapticFeedback {
    case success
    case warning
    case error
    case light
    case medium
    case heavy

    func generate() {
        switch self {
        case .success, .warning, .error:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(
                self == .success ? .success :
                self == .warning ? .warning : .error
            )
        case .light, .medium, .heavy:
            let generator = UIImpactFeedbackGenerator(
                style: self == .light ? .light :
                       self == .medium ? .medium : .heavy
            )
            generator.impactOccurred()
        }
    }
}

extension View {
    /// Adds haptic feedback on tap
    func hapticFeedback(_ feedback: HapticFeedback = .light) -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded {
                feedback.generate()
            }
        )
    }
}
