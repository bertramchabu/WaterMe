
import SwiftUI

/// Settings screen for user profile and app preferences
struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationStack {
            Form {
                // Profile section
                profileSection

                // Goal settings
                goalSection

                // Notification settings
                notificationSection

                // HealthKit integration
                healthKitSection

                // About section
                aboutSection

                // Data management
                dataSection
            }
            .navigationTitle("Settings")
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .alert("Reset All Data", isPresented: $viewModel.showResetConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    Task {
                        await viewModel.resetAllData()
                    }
                }
            } message: {
                Text("This will delete all your water entries and reset your profile. This action cannot be undone.")
            }
            .overlay(alignment: .top) {
                if viewModel.showSuccess {
                    successBanner
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await viewModel.saveSettings()
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }


    private var profileSection: some View {
        Section("Profile") {
            HStack {
                Label("Name", systemImage: Constants.Symbols.person)
                Spacer()
                TextField("Your name", text: $viewModel.name)
                    .multilineTextAlignment(.trailing)
            }

            HStack {
                Label("Weight", systemImage: "scalemass")
                Spacer()
                TextField("kg", text: $viewModel.weight)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 60)
                Text("kg")
                    .foregroundColor(.secondary)
            }

            Picker("Activity Level", selection: $viewModel.selectedActivityLevel) {
                ForEach(ActivityLevel.allCases, id: \.self) { level in
                    VStack(alignment: .leading) {
                        Text(level.rawValue)
                        Text(level.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .tag(level)
                }
            }

            Picker("Unit", selection: $viewModel.selectedUnit) {
                ForEach(WaterUnit.allCases, id: \.self) { unit in
                    Text(unit.rawValue).tag(unit)
                }
            }
        }
    }



    private var goalSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Label("Daily Goal", systemImage: Constants.Symbols.drop)

                Text("Recommended: \(viewModel.formattedRecommendedGoal)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Toggle("Use Custom Goal", isOn: $viewModel.customGoalEnabled)

            if viewModel.customGoalEnabled {
                HStack {
                    TextField("Goal", text: $viewModel.customGoal)
                        .keyboardType(.decimalPad)
                    Text(viewModel.selectedUnit.rawValue)
                        .foregroundColor(.secondary)
                }
            }
        } header: {
            Text("Hydration Goal")
        } footer: {
            if !viewModel.customGoalEnabled {
                Text("Your goal is calculated based on your weight and activity level.")
            }
        }
    }



    private var notificationSection: some View {
        Section {
            Toggle("Enable Reminders", isOn: $viewModel.notificationsEnabled)
                .onChange(of: viewModel.notificationsEnabled) { _, _ in
                    Task {
                        await viewModel.toggleNotifications()
                    }
                }

            if viewModel.notificationsEnabled {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Reminder Interval")
                    HStack {
                        Text("\(Int(viewModel.reminderInterval)) minutes")
                            .foregroundColor(.secondary)
                        Spacer()
                        Slider(
                            value: $viewModel.reminderInterval,
                            in: Double(Constants.Limits.minReminderInterval)...Double(Constants.Limits.maxReminderInterval),
                            step: 15
                        )
                        .frame(width: 150)
                    }
                }

                DatePicker(
                    "Wake Time",
                    selection: $viewModel.wakeTime,
                    displayedComponents: .hourAndMinute
                )

                DatePicker(
                    "Sleep Time",
                    selection: $viewModel.sleepTime,
                    displayedComponents: .hourAndMinute
                )
            }
        } header: {
            Text("Notifications")
        } footer: {
            Text("Receive reminders to drink water throughout the day.")
        }
    }


    private var healthKitSection: some View {
        Section {
            if viewModel.healthKitAvailable {
                Toggle("Sync with Apple Health", isOn: $viewModel.healthKitEnabled)
                    .onChange(of: viewModel.healthKitEnabled) { _, _ in
                        Task {
                            await viewModel.toggleHealthKit()
                        }
                    }

                if viewModel.healthKitEnabled {
                    Label("Connected to Apple Health", systemImage: Constants.Symbols.checkmark)
                        .foregroundColor(.green)
                        .font(.caption)
                }
            } else {
                Label("Apple Health not available", systemImage: Constants.Symbols.xmark)
                    .foregroundColor(.secondary)
            }
        } header: {
            Text("Apple Health Integration")
        } footer: {
            Text("Sync your water intake data with the Apple Health app.")
        }
    }

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text(Constants.appVersion)
                    .foregroundColor(.secondary)
            }

            HStack {
                Text("Build")
                Spacer()
                Text(Constants.appBuild)
                    .foregroundColor(.secondary)
            }

            Link(destination: URL(string: "https://github.com/bertramchabu/WaterMe.git")!) {
                Label("View on GitHub", systemImage: "link")
            }

        }
    }


    private var dataSection: some View {
        Section {
            Button(role: .destructive) {
                viewModel.showResetDialog()
            } label: {
                Label("Reset All Data", systemImage: "trash")
            }
        } header: {
            Text("Data Management")
        } footer: {
            Text("This will permanently delete all your data and cannot be undone.")
        }
    }


    private var successBanner: some View {
        Text(viewModel.successMessage)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Constants.Design.successColor)
                    .shadow(radius: 8)
            )
            .padding(.top, 8)
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.spring(), value: viewModel.showSuccess)
    }
}


#Preview {
    SettingsView()
}
