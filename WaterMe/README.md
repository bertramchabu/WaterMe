# WaterMe - Smart Hydration Tracker

<div align="center">

![Platform](https://img.shields.io/badge/platform-iOS%2016.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-4.0-green.svg)
![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)

**A modern iOS app that helps you stay hydrated with smart reminders and beautiful visualizations**

</div>

---

## 📱 Overview

WaterMe is a comprehensive hydration tracking app built with Swift and SwiftUI that helps users maintain proper hydration throughout the day. The app features intelligent reminders, personalized goals, Apple Health integration, and beautiful data visualizations.

### Key Features

- ✨ **Beautiful Water Glass Animation** - Visual feedback with animated water level
- 📊 **Detailed Statistics** - Charts and insights about your hydration patterns
- ⚡ **Quick Add Buttons** - Rapidly log water intake with preset amounts
- 🔔 **Smart Reminders** - Context-aware notifications throughout the day
- 🍎 **Apple Health Integration** - Syncs with the Health app
- 🎯 **Personalized Goals** - Calculated based on weight and activity level
- 🔥 **Streak Tracking** - Maintain motivation with daily streaks
- 🌙 **Dark Mode Support** - Beautiful in both light and dark themes
- ♿ **Accessibility** - Full VoiceOver and Dynamic Type support
- 📈 **Data Export** - Export your hydration data as CSV

---

## 🏗 Architecture

WaterMe follows industry best practices with a clean, maintainable architecture:

### MVVM Pattern

```
┌─────────────┐
│    View     │  SwiftUI Views
└──────┬──────┘
       │
┌──────▼──────┐
│ ViewModel   │  Business Logic & State Management
└──────┬──────┘
       │
┌──────▼──────┐
│    Model    │  Data Models (SwiftData)
└─────────────┘
```

### Project Structure

```
WaterMe/
├── App/
│   ├── WaterMeApp.swift          # App entry point
│   └── ContentView.swift         # Main tab view
├── Models/
│   ├── WaterEntry.swift          # Water intake entries
│   ├── UserProfile.swift         # User settings & profile
│   └── DailyGoal.swift           # Daily hydration goals
├── ViewModels/
│   ├── HomeViewModel.swift       # Home screen logic
│   ├── SettingsViewModel.swift   # Settings management
│   └── HistoryViewModel.swift    # History & statistics
├── Views/
│   ├── Home/
│   │   ├── HomeView.swift        # Main home screen
│   │   ├── WaterGlassView.swift  # Animated water glass
│   │   └── QuickAddButtonView.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   └── History/
│       ├── HistoryView.swift
│       └── ChartView.swift       # Data visualization
├── Services/
│   ├── DataManager.swift         # SwiftData operations
│   ├── NotificationManager.swift # Notification scheduling
│   └── HealthKitManager.swift    # Apple Health integration
└── Utilities/
    ├── Constants.swift           # App constants
    └── Extensions.swift          # Helpful extensions
```

---

## 🚀 Getting Started

### Prerequisites

- Xcode 15.0 or later
- iOS 16.0 or later
- macOS 13.0 or later (for development)
- Swift 5.9+

### Installation

1. **Clone the repository**

```bash
git clone https://github.com/bertramchabu/WaterMe.git
cd WaterMe
```

2. **Open in Xcode**

```bash
open WaterMe.xcodeproj
```

3. **Select your development team**
   - In Xcode, select the WaterMe project
   - Go to "Signing & Capabilities"
   - Select your development team

4. **Build and Run**
   - Select a simulator or your iOS device
   - Press `Cmd + R` to build and run

### Configuration

#### HealthKit Setup

1. The app includes HealthKit capabilities
2. Ensure your device/simulator supports HealthKit
3. Grant permissions when prompted on first launch

#### Notifications

1. The app requests notification permissions on first use
2. Configure reminder schedule in Settings
3. Enable "Allow Notifications" in iOS Settings if needed

---

## 💻 Technical Details

### Technologies Used

| Technology | Purpose |
|------------|---------|
| **SwiftUI** | Modern declarative UI framework |
| **SwiftData** | Data persistence and management |
| **HealthKit** | Apple Health integration |
| **UserNotifications** | Smart reminder system |
| **Charts** | Data visualization framework |
| **Combine** | Reactive programming |

### Key Design Patterns

1. **MVVM Architecture**
   - Clean separation of concerns
   - Testable business logic
   - Reactive state management with `@Published`

2. **Protocol-Oriented Programming**
   - `WaterTrackable` protocol for data models
   - Reusable, composable code

3. **Singleton Pattern**
   - DataManager, NotificationManager, HealthKitManager
   - Centralized service access

4. **Dependency Injection**
   - ViewModels receive dependencies
   - Improved testability

### Code Quality

- **Unit Tests**: 80%+ code coverage
- **UI Tests**: Main user flows covered
- **Documentation**: Comprehensive inline documentation
- **Linting**: Follows Swift style guidelines
- **Git**: Meaningful commit messages

---

## 🎨 Design System

### Colors

```swift
Primary:   System Blue (#007AFF)
Accent:    Cyan (#00C7BE)
Success:   Green (#34C759)
Warning:   Orange (#FF9500)
Error:     Red (#FF3B30)
```

### Typography

- **Font**: SF Pro (System font)
- **Dynamic Type**: Fully supported
- **Hierarchy**: Clear visual structure

### Spacing

```swift
Small:    8pt
Medium:   16pt
Large:    24pt
XLarge:   32pt
```

---

## 📊 Features in Detail

### 1. Home Screen

The main hub for tracking daily water intake:

- **Animated Water Glass**: Visual representation with wave effects
- **Quick Add Buttons**: Tap to instantly log common amounts
- **Progress Ring**: Shows daily goal completion
- **Today's Entries**: List of all water intake for the day
- **Streak Counter**: Displays current hydration streak

**Code Example:**

```swift
Button {
    Task {
        await viewModel.addWater(amount: 250)
    }
} label: {
    QuickAddButtonView(amount: 250, unit: .milliliters)
}
```

### 2. History & Analytics

Comprehensive view of hydration history:

- **Interactive Charts**: Bar charts showing intake over time
- **Period Selection**: Week, Month, or 3 Months view
- **Statistics Cards**: Average, total, goals met, success rate
- **Streak Information**: Current and longest streaks
- **Best Day**: Highlights your top performance
- **Data Export**: CSV export for external analysis

**Chart Implementation:**

```swift
Chart {
    ForEach(data, id: \.date) { item in
        BarMark(
            x: .value("Date", item.date, unit: .day),
            y: .value("Amount", item.amount)
        )
        .foregroundStyle(Color.waterGradient)
    }

    RuleMark(y: .value("Goal", goalLine))
        .foregroundStyle(.green)
        .lineStyle(StrokeStyle(dash: [5, 5]))
}
```

### 3. Settings & Customization

Personalize your hydration experience:

- **Profile Management**: Name, weight, activity level
- **Goal Calculation**: Automatic or custom goals
- **Unit Preference**: Milliliters or fluid ounces
- **Notification Settings**: Schedule and frequency
- **HealthKit Integration**: Toggle and sync
- **Data Management**: Export or reset data

**Goal Calculation:**

```swift
// Recommended goal = weight (kg) × activity multiplier
let recommendedGoal = weight * activityLevel.multiplier

// Activity multipliers:
// Sedentary: 30ml/kg
// Lightly Active: 35ml/kg
// Moderately Active: 40ml/kg
// Very Active: 45ml/kg
// Extra Active: 50ml/kg
```

### 4. Smart Notifications

Intelligent reminders to stay hydrated:

- **Customizable Schedule**: Set wake and sleep times
- **Adjustable Intervals**: 15-240 minute spacing
- **Contextual Messages**: Variety of motivational reminders
- **Goal Completion Alerts**: Celebrate achievements
- **Quiet Hours**: Respects sleep schedule

---

## 🧪 Testing

### Running Tests

```bash
# Run all tests
cmd + U

# Run specific test suite
xcodebuild test -scheme WaterMe -destination 'platform=iOS Simulator,name=iPhone 15'

# Run with coverage
xcodebuild test -scheme WaterMe -enableCodeCoverage YES
```

### Test Coverage

- **Unit Tests**: Models, ViewModels, Utilities
- **UI Tests**: Navigation, user flows, accessibility
- **Performance Tests**: Launch time, scroll performance

### Example Unit Test

```swift
func testWaterEntryInitialization() {
    // Given
    let amount = 250.0
    let timestamp = Date()

    // When
    let entry = WaterEntry(amount: amount, timestamp: timestamp)

    // Then
    XCTAssertEqual(entry.amount, amount)
    XCTAssertEqual(entry.timestamp, timestamp)
    XCTAssertNotNil(entry.id)
}
```

---

## 🔒 Privacy & Security

WaterMe takes your privacy seriously:

- **Local Data Storage**: All data stored locally using SwiftData
- **No Cloud Sync**: Data stays on your device
- **HealthKit Integration**: Optional and user-controlled
- **No Analytics**: No tracking or data collection
- **Transparent Permissions**: Clear explanations for all permissions

### Permissions Required

| Permission | Purpose | Required |
|------------|---------|----------|
| Notifications | Hydration reminders | Optional |
| HealthKit | Sync water intake | Optional |

---

## 📈 Performance

WaterMe is optimized for speed and efficiency:

- **Launch Time**: < 2 seconds cold start
- **Memory Footprint**: < 50MB typical usage
- **Battery Impact**: Minimal (background notifications only)
- **Animations**: 60fps smooth animations
- **Data Operations**: Async/await for responsive UI

### Optimization Techniques

1. **Lazy Loading**: Views and data loaded on-demand
2. **Caching**: Efficient data fetching strategies
3. **SwiftData**: Optimized database queries
4. **Async Operations**: All network/disk I/O is async
5. **Image Optimization**: SF Symbols for lightweight icons

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

### How to Contribute

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Commit your changes**
   ```bash
   git commit -m "Add amazing feature"
   ```
4. **Push to the branch**
   ```bash
   git push origin feature/amazing-feature
   ```
5. **Open a Pull Request**

### Code Style

- Follow Swift API Design Guidelines
- Use meaningful variable names
- Add comments for complex logic
- Write tests for new features
- Update documentation

---

## 📝 Changelog

### Version 1.0.0 (2025-10-13)

**Initial Release**

- ✅ Core hydration tracking
- ✅ Animated water glass visualization
- ✅ Quick add buttons
- ✅ History and statistics
- ✅ Smart notifications
- ✅ Apple Health integration
- ✅ Data export
- ✅ Dark mode support
- ✅ Comprehensive test coverage

---

## 🎯 Roadmap

### Future Features

- [ ] Widget support for home screen
- [ ] Watch app companion
- [ ] Siri Shortcuts integration
- [ ] Custom water container presets
- [ ] Social features (optional)
- [ ] Localization (multiple languages)
- [ ] iPad optimization
- [ ] Apple Watch complications

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 WaterMe

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
```

---

## 👏 Acknowledgments

- **Apple** - For Swift, SwiftUI, and excellent frameworks
- **SF Symbols** - Beautiful iconography
- **Swift Community** - For best practices and inspiration

---

## 📧 Contact

For questions, suggestions, or feedback:

- **Issues**: [GitHub Issues](https://github.com/yourusername/WaterMe/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/WaterMe/discussions)
- **Email**: your.email@example.com

---

## 🌟 Show Your Support

If you find WaterMe helpful, please consider:

- ⭐ Starring the repository
- 🐛 Reporting bugs
- 💡 Suggesting new features
- 🔀 Contributing code
- 📢 Sharing with friends

---

<div align="center">

**Made with ❤️ and SwiftUI**

Stay Hydrated! 💧

</div>
