

import SwiftUI



extension View {

    func cardStyle() -> some View {
        self
            .background(Color(.systemBackground))
            .cornerRadius(Constants.Design.mediumCornerRadius)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    
    func standardPadding() -> some View {
        self.padding(Constants.Design.mediumPadding)
    }

    
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    
    @ViewBuilder
    func hidden(_ hidden: Bool) -> some View {
        if hidden {
            self.hidden()
        } else {
            self
        }
    }

    
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}



extension Color {
    
    
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

    
    static let waterGradient = LinearGradient(
        colors: [Color.blue.opacity(0.6), Color.cyan.opacity(0.4)],
        startPoint: .top,
        endPoint: .bottom
    )

    
    static let glassEffect = Color.white.opacity(0.1)
}



extension Date {

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }


    var isThisWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }

    
    var isThisMonth: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }

    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    
    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components)!
    }

    
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }

    
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

    func setTime(hour: Int, minute: Int) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: self)
        components.hour = hour
        components.minute = minute
        components.second = 0
        return Calendar.current.date(from: components) ?? self
    }
}



extension Double {
    /// Rounds to specified decimal places
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }


    var toLiters: Double {
        self / 1000.0
    }


    var toMilliliters: Double {
        self * 1000.0
    }


    var toFluidOunces: Double {
        self / 29.5735
    }


    var fromFluidOunces: Double {
        self * 29.5735
    }
}



extension String {

    var isValidNumber: Bool {
        Double(self) != nil
    }


    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }


    var trimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}



extension Int {

    var ordinal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}



extension Array where Element == WaterEntry {

    var totalAmount: Double {
        self.reduce(0) { $0 + $1.amount }
    }


    func entries(for date: Date) -> [WaterEntry] {
        let calendar = Calendar.current
        return self.filter { calendar.isDate($0.timestamp, inSameDayAs: date) }
    }
}

extension Array where Element == DailyGoal {

    var completedCount: Int {
        self.filter { $0.isCompleted }.count
    }


    var completionRate: Double {
        guard !self.isEmpty else { return 0 }
        return Double(completedCount) / Double(count)
    }


    var averageAchieved: Double {
        guard !self.isEmpty else { return 0 }
        let total = self.reduce(0) { $0 + $1.achievedAmount }
        return total / Double(count)
    }
}




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
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}



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
