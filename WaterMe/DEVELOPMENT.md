# Development Guide

## Setting Up Your Development Environment

### Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later
- iOS 16.0 SDK or later
- Swift 5.9+
- An Apple Developer account (for device testing)

### Initial Setup

1. **Install Xcode**
   ```bash
   # Download from App Store or
   xcode-select --install
   ```

2. **Clone and Setup**
   ```bash
   git clone https://github.com/yourusername/WaterMe.git
   cd WaterMe
   ```

3. **Open Project**
   ```bash
   open WaterMe.xcodeproj
   ```

## Project Configuration

### Bundle Identifier

Update in Xcode:
- Select project → Target → General
- Bundle Identifier: `com.yourcompany.waterme`

### Signing

- Select your Team under Signing & Capabilities
- Automatic signing is recommended for development

### Capabilities

The following capabilities are already configured:

- HealthKit
- Push Notifications
- Background Modes

## Architecture Overview

### MVVM Pattern

**Models** (Data Layer)
```swift
@Model
final class WaterEntry {
    var id: UUID
    var amount: Double
    var timestamp: Date
}
```

**ViewModels** (Business Logic)
```swift
@MainActor
final class HomeViewModel: ObservableObject {
    @Published var todayIntake: Double = 0

    func addWater(amount: Double) async {
        // Business logic here
    }
}
```

**Views** (Presentation)
```swift
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        // UI code
    }
}
```

### Data Flow

```
User Action → View → ViewModel → Service → SwiftData
                ↑                           ↓
                └───── Published State ─────┘
```

## Code Style Guidelines

### Naming Conventions

```swift
// Classes and Structs: UpperCamelCase
class DataManager { }
struct WaterEntry { }

// Properties and Methods: lowerCamelCase
var todayIntake: Double
func addWater(amount: Double) { }

// Constants: lowerCamelCase (in enum)
enum Constants {
    static let appName = "WaterMe"
}

// Private properties: prefix with underscore
private var _internalState: Int
```

### Code Organization

```swift
// MARK: - Section Name

/// Documentation comment
/// - Parameter amount: The amount in milliliters
/// - Returns: Success status
func addWater(amount: Double) -> Bool {
    // Implementation
}

// MARK: - Private Methods

private func helperMethod() {
    // Implementation
}
```

### SwiftUI Best Practices

1. **Keep Views Small**
   ```swift
   struct HomeView: View {
       var body: some View {
           VStack {
               headerSection
               contentSection
               footerSection
           }
       }

       private var headerSection: some View {
           // Header implementation
       }
   }
   ```

2. **Use @ViewBuilder**
   ```swift
   @ViewBuilder
   private func conditionalView() -> some View {
       if condition {
           ViewA()
       } else {
           ViewB()
       }
   }
   ```

3. **Prefer Structs over Classes**
   - Views should be structs
   - Only use classes for reference types (ViewModels)

### Async/Await

Always use async/await for data operations:

```swift
func loadData() async {
    do {
        let data = try await dataManager.fetchData()
        await updateUI(with: data)
    } catch {
        handleError(error)
    }
}
```

## Testing Strategy

### Unit Tests

Test files should mirror source structure:

```
WaterMe/Models/WaterEntry.swift
WaterMeTests/ModelTests.swift
```

Example test:

```swift
func testWaterEntryInitialization() {
    // Given
    let amount = 250.0

    // When
    let entry = WaterEntry(amount: amount)

    // Then
    XCTAssertEqual(entry.amount, amount)
}
```

### UI Tests

Test user flows:

```swift
func testAddWaterFlow() {
    let app = XCUIApplication()
    app.launch()

    app.buttons["250ml"].tap()

    XCTAssertTrue(app.staticTexts["Added!"].exists)
}
```

### Running Tests

```bash
# All tests
cmd + U

# Specific test class
xcodebuild test -scheme WaterMe -only-testing:WaterMeTests/ModelTests

# With coverage
xcodebuild test -scheme WaterMe -enableCodeCoverage YES
```

## Debugging

### Common Issues

**1. SwiftData Context Not Found**
```swift
// Solution: Ensure ModelContainer is configured
DataManager.shared.configure(with: modelContainer.mainContext)
```

**2. HealthKit Permission Denied**
```swift
// Solution: Check Info.plist has usage descriptions
NSHealthShareUsageDescription
NSHealthUpdateUsageDescription
```

**3. Notifications Not Appearing**
```swift
// Solution: Request authorization first
await notificationManager.requestPermission()
```

### Xcode Debugging Tools

1. **View Hierarchy Debugger** - `cmd + shift + D`
2. **Memory Graph Debugger** - Debug Navigator → Memory
3. **Instruments** - `cmd + I`
   - Time Profiler for performance
   - Leaks for memory issues

## Performance Optimization

### Checklist

- [ ] Use lazy loading for lists
- [ ] Implement pagination for large datasets
- [ ] Cache expensive computations
- [ ] Use `@Published` only when needed
- [ ] Profile with Instruments regularly

### SwiftData Optimization

```swift
// Good: Specific fetch
let descriptor = FetchDescriptor<WaterEntry>(
    predicate: #Predicate { $0.timestamp >= startDate },
    sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
)

// Bad: Fetch all then filter
let all = try context.fetch(FetchDescriptor<WaterEntry>())
let filtered = all.filter { $0.timestamp >= startDate }
```

## Git Workflow

### Branch Strategy

```
main          (production)
  ├── develop (integration)
      ├── feature/user-profile
      ├── feature/notifications
      └── bugfix/data-sync
```

### Commit Messages

Follow conventional commits:

```bash
feat: Add water glass animation
fix: Resolve notification scheduling issue
docs: Update README with installation steps
refactor: Simplify DataManager implementation
test: Add unit tests for UserProfile
```

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] UI tests pass
- [ ] Manual testing completed

## Screenshots
If applicable, add screenshots
```

## Continuous Integration

### GitHub Actions Example

```yaml
name: iOS Build and Test

on: [push, pull_request]

jobs:
  build:
    runs-on: macos-13

    steps:
    - uses: actions/checkout@v3

    - name: Build
      run: xcodebuild -scheme WaterMe build

    - name: Test
      run: xcodebuild -scheme WaterMe test
```

## Release Process

### Version Numbering

Follow Semantic Versioning (semver):

- `MAJOR.MINOR.PATCH` (e.g., 1.0.0)
- MAJOR: Breaking changes
- MINOR: New features
- PATCH: Bug fixes

### Pre-Release Checklist

- [ ] All tests passing
- [ ] Code review completed
- [ ] Documentation updated
- [ ] Changelog updated
- [ ] Version bumped
- [ ] Screenshots updated
- [ ] App Store metadata ready

### Build for Release

1. **Set Release Scheme**
   - Product → Scheme → Edit Scheme
   - Build Configuration: Release

2. **Archive**
   ```
   Product → Archive
   ```

3. **Upload to App Store Connect**
   - Window → Organizer
   - Select archive → Distribute App

## Troubleshooting

### Build Errors

**"SwiftData model not found"**
```bash
# Clean build folder
cmd + shift + K

# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData
```

**"Module not found"**
```bash
# Update Swift packages
File → Packages → Update to Latest Package Versions
```

### Runtime Issues

**"Data not persisting"**
- Check ModelConfiguration
- Verify model is in container schema
- Check file permissions

**"Notifications not working"**
- Verify Info.plist keys
- Check notification permissions
- Test on physical device

## Resources

### Official Documentation

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [HealthKit Documentation](https://developer.apple.com/documentation/healthkit)

### Community Resources

- [Swift Forums](https://forums.swift.org/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/swift)
- [iOS Dev Weekly](https://iosdevweekly.com/)

### Tools

- [SF Symbols App](https://developer.apple.com/sf-symbols/)
- [Create ML](https://developer.apple.com/machine-learning/create-ml/)
- [TestFlight](https://developer.apple.com/testflight/)

## Getting Help

If you encounter issues:

1. Check this documentation
2. Search GitHub Issues
3. Ask in GitHub Discussions
4. Create a new issue with:
   - Xcode version
   - iOS version
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots/logs

---

Happy coding! 💧
