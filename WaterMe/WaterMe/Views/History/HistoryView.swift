//
//  HistoryView.swift
//  WaterMe
//
//  Created on 2025-10-13
//

import SwiftUI

/// History screen showing past water intake and statistics
struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @State private var showShareSheet = false
    @State private var shareURL: URL?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Period selector
                    periodSelector

                    // Chart
                    chartSection

                    // Statistics
                    statisticsSection

                    // Streak information
                    streakSection

                    // Best day
                    if let bestDay = viewModel.bestDay {
                        bestDaySection(bestDay)
                    }
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.05),
                        Color.cyan.opacity(0.02)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            shareData()
                        } label: {
                            Label("Export Data", systemImage: "square.and.arrow.up")
                        }

                        Button {
                            Task {
                                await viewModel.refresh()
                            }
                        } label: {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = shareURL {
                    ShareSheet(items: [url])
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }

    // MARK: - Period Selector

    private var periodSelector: some View {
        Picker("Period", selection: $viewModel.selectedPeriod) {
            ForEach(HistoryPeriod.allCases, id: \.self) { period in
                Text(period.rawValue).tag(period)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: viewModel.selectedPeriod) { _, newPeriod in
            Task {
                await viewModel.changePeriod(to: newPeriod)
            }
        }
    }

    // MARK: - Chart Section

    private var chartSection: some View {
        WaterIntakeChartView(
            data: viewModel.chartData,
            goalLine: viewModel.goalLineValue,
            period: viewModel.selectedPeriod
        )
    }

    // MARK: - Statistics Section

    private var statisticsSection: some View {
        VStack(spacing: 16) {
            Text("Statistics")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                statCard(
                    title: "Average",
                    value: viewModel.formattedAverage,
                    icon: Constants.Symbols.chart,
                    color: .blue
                )

                statCard(
                    title: "Total",
                    value: viewModel.formattedTotal,
                    icon: Constants.Symbols.drop,
                    color: .cyan
                )

                statCard(
                    title: "Goals Met",
                    value: "\(viewModel.goalsCompleted)",
                    icon: Constants.Symbols.checkmark,
                    color: .green
                )

                statCard(
                    title: "Success Rate",
                    value: viewModel.formattedCompletionRate,
                    icon: Constants.Symbols.trophy,
                    color: .orange
                )
            }
        }
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            VStack(spacing: 4) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)

                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .cardStyle()
    }

    // MARK: - Streak Section

    private var streakSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Current Streak", systemImage: Constants.Symbols.flame)
                        .font(.headline)

                    Text("\(viewModel.currentStreak) days")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)

                    if viewModel.currentStreak > 0 {
                        Text(Constants.Achievements.streakMessage(for: viewModel.currentStreak))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    Label("Longest", systemImage: Constants.Symbols.trophy)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("\(viewModel.longestStreak)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)

                    Text("days")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .cardStyle()
        }
    }

    // MARK: - Best Day Section

    private func bestDaySection(_ goal: DailyGoal) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Best Day", systemImage: Constants.Symbols.arrowUp)
                .font(.headline)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.shortDate)
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text(viewModel.formatAmount(goal.achievedAmount))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Constants.Design.primaryColor)
                }

                Spacer()

                if goal.isCompleted {
                    Image(systemName: Constants.Symbols.checkmark)
                        .font(.system(size: 32))
                        .foregroundColor(.green)
                }
            }
            .padding()
            .cardStyle()
        }
    }

    // MARK: - Share Data

    private func shareData() {
        if let url = viewModel.shareData() {
            shareURL = url
            showShareSheet = true
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview {
    HistoryView()
}
