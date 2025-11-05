

import SwiftUI

// Main home screen showing water intake tracking
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showCustomAmountSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.05),
                        Color.cyan.opacity(0.02)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header with streak
                        headerSection

                        // Water glass visualization
                        waterGlassSection

                        // Progress summary
                        progressSummarySection

                        // Quick add buttons
                        quickAddSection

                        // Today's entries
                        entriesSection
                    }
                    .padding()
                }
            }
            .navigationTitle("WaterMe")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await viewModel.refresh()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .overlay(alignment: .bottom) {
                if viewModel.showSuccess {
                    successBanner
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .sheet(isPresented: $showCustomAmountSheet) {
                customAmountSheet
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }



    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(Date().relativeString())
                    .font(.title3)
                    .fontWeight(.semibold)

                if let profile = viewModel.userProfile {
                    Text("Hello, \(profile.name)!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Streak indicator
            if viewModel.currentStreak > 0 {
                HStack(spacing: 6) {
                    Image(systemName: Constants.Symbols.flame)
                        .foregroundColor(.orange)
                    Text("\(viewModel.currentStreak)")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.orange.opacity(0.1))
                )
            }
        }
    }

    
    private var waterGlassSection: some View {
        VStack(spacing: 16) {
            WaterGlassView(
                progress: viewModel.progress,
                isCompleted: viewModel.isGoalCompleted
            )

            VStack(spacing: 8) {
                Text(viewModel.formattedTodayIntake)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Constants.Design.primaryColor)

                Text("of \(viewModel.formattedDailyGoal)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical)
    }

    

    private var progressSummarySection: some View {
        HStack(spacing: 16) {
            // Progress card
            VStack(spacing: 8) {
                Image(systemName: Constants.Symbols.chart)
                    .font(.title2)
                    .foregroundColor(Constants.Design.accentColor)

                Text(viewModel.progressPercentage)
                    .font(.title3)
                    .fontWeight(.bold)

                Text("Progress")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .cardStyle()

            // ...existing code...
            VStack(spacing: 8) {
                Image(systemName: Constants.Symbols.dropTriangle)
                    .font(.title2)
                    .foregroundColor(Constants.Design.primaryColor)

                Text(viewModel.formattedRemainingAmount)
                    .font(.title3)
                    .fontWeight(.bold)

                Text("Remaining")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .cardStyle()
        }
    }

    

    private var quickAddSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Add")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(viewModel.quickAddAmounts, id: \.self) { amount in
                    QuickAddButtonView(
                        amount: amount,
                        unit: viewModel.userProfile?.preferredUnit ?? .milliliters
                    ) {
                        Task {
                            await viewModel.addWater(amount: amount)
                        }
                    }
                }

                // Custom amount button
                Button {
                    showCustomAmountSheet = true
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: Constants.Symbols.plus)
                            .font(.system(size: 24))
                            .foregroundColor(Constants.Design.accentColor)

                        Text("Custom")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: Constants.Design.mediumCornerRadius)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }



    private var entriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Entries")
                .font(.headline)

            if viewModel.todayEntries.isEmpty {
                emptyEntriesView
            } else {
                ForEach(viewModel.todayEntries) { entry in
                    entryRow(entry)
                }
            }
        }
    }

    private var emptyEntriesView: some View {
        VStack(spacing: 12) {
            Image(systemName: Constants.Symbols.drop)
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.5))

            Text("No entries yet")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("Add your first water intake above!")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .cardStyle()
    }

    private func entryRow(_ entry: WaterEntry) -> some View {
        HStack {
            Image(systemName: Constants.Symbols.drop)
                .foregroundColor(Constants.Design.primaryColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.formattedAmount)
                    .font(.body)
                    .fontWeight(.medium)

                Text(entry.formattedTime)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button {
                Task {
                    await viewModel.deleteEntry(entry)
                }
            } label: {
                Image(systemName: Constants.Symbols.xmark)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding()
        .cardStyle()
    }



    private var customAmountSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Add Custom Amount")
                    .font(.title2)
                    .fontWeight(.bold)

                TextField(
                    "Enter amount",
                    text: $viewModel.customAmount
                )
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

                Text(viewModel.userProfile?.preferredUnit.rawValue ?? "ml")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Button {
                    Task {
                        await viewModel.addCustomAmount()
                    }
                } label: {
                    Text("Add Water")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Constants.Design.primaryColor)
                        .cornerRadius(Constants.Design.mediumCornerRadius)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        showCustomAmountSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
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
            .padding(.bottom, 20)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.spring(), value: viewModel.showSuccess)
    }
}



#Preview {
    HomeView()
}
