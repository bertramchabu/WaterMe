import SwiftUI



struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView()
                .tabItem {
                    Label("Home", systemImage: Constants.Symbols.drop)
                }
                .tag(0)

            // History Tab
            HistoryView()
                .tabItem {
                    Label("History", systemImage: Constants.Symbols.chart)
                }
                .tag(1)

            // Settings Tab
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: Constants.Symbols.gear)
                }
                .tag(2)
        }
        .tint(Constants.Design.primaryColor)
    }
}



#Preview {
    ContentView()
        .modelContainer(for: [WaterEntry.self, UserProfile.self, DailyGoal.self])
}
