import SwiftUI
import SwiftData


@main
struct WaterMeApp: App {
 
    let modelContainer: ModelContainer

    init() {
        do {
            
            let schema = Schema([
                WaterEntry.self,
                UserProfile.self,
                DailyGoal.self
            ])

            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )

            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )

            
            Task { @MainActor in
                DataManager.shared.configure(with: modelContainer.mainContext)
            }

        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
                .onAppear {
                    setupApp()
                }
        }
    }

    

    /// Performs initial app setup
    private func setupApp() {
        // Set up appearance
        setupAppearance()

        // Track app launch
        trackAppLaunch()
    }

    
    private func setupAppearance() {
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance

        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }

    
    private func trackAppLaunch() {
        let defaults = UserDefaults.standard

        // Increment launch count
        let launchCount = defaults.integer(forKey: Constants.UserDefaultsKeys.appLaunchCount)
        defaults.set(launchCount + 1, forKey: Constants.UserDefaultsKeys.appLaunchCount)

        // Set last launch date
        defaults.set(Date(), forKey: Constants.UserDefaultsKeys.lastLaunchDate)

        // First launch
        if launchCount == 0 {
            defaults.set(true, forKey: Constants.UserDefaultsKeys.hasCompletedOnboarding)
        }
    }
}
