import SwiftUI

/// The root view of the application responsible for state initialization and content routing.
///
/// `MainView` acts as the primary controller that decides which view hierarchy to present based on the user's
/// current state (authentication status and team membership). It also manages global configurations such as
/// theme application and initialization tasks.
///
/// ## Key Responsibilities
/// - **Initialization:** Displays a loading indicator while fetching initial user auth status asynchronously.
/// - **Routing logic:**
///   - If not logged in: Shows `AuthenticationView`.
///   - If logged in but no team: Shows `TeamAuthenticationView`.
///   - If fully authenticated: Shows the main `TabView` (Home, Calendar, etc.).
/// - **Theme Management:** Observes system `colorScheme` changes and user preferences to update the global theme via `ThemeManager`.
/// - **Launch & Login Animation:** Handles the launch animation for both cold starts (for logged-in users) and successful logins.
struct MainView: View {
    
    @Environment(\.colorScheme) private var colorScheme

    /// Tracks the currently selected tab in the main interface.
    @State private var selectedTab: String = "home"
    
    /// Indicates whether the app has finished its initial data loading and auth checks.
    @State private var isInitialized: Bool = false

    /// Controls the visibility of the animation overlay.
    @State private var showAnimation: Bool = false

    var body: some View {
        ZStack {

            // 1. Initialization State Handling
            if !isInitialized {
                // Show loading screen while checking auth status
                ZStack {
                    Color(.darkBackground)
                        .ignoresSafeArea()

                    // ProgressView can be removed as animation will cover it,
                    // but kept for fallback.
                    ProgressView()
                        .tint(.white)
                }
                .task {
                    // Perform async initialization
                    await AuthenticationHelper.updateUserAuthStatus()
                    updateTheme()
                    isInitialized = true
                    
                    // if already logged in, show launch animation
                    if DevbanUserContainer.shared.loggedIn {
                        showAnimation = true
                    }
                }
            } else {
                // 2. Main Content Routing
                getMainContent()
                    .tint(ThemeManager.shared.buttonColor)
                    // React to system dark/light mode changes
                    .onChange(of: colorScheme) {
                        updateTheme()
                    }
                    
                    // React to login state changes
                    .onChange(of: DevbanUserContainer.shared.loggedIn) { _, isLoggedIn in
                        updateTheme()
                        if isLoggedIn {
                            showAnimation = true
                        }
                    }
                    // Enforce specific color scheme if user overrode system settings
                    .preferredColorScheme(
                        ThemeManager.getActualColorScheme(
                            preferredColorScheme: DevbanUserContainer.shared.getPreferredColorScheme(),
                            colorScheme: colorScheme
                        )
                    )
            }

            // 3. Global Animation Overlay
            if showAnimation {
                LoginSuccessAnimationView {
                    withAnimation {
                        showAnimation = false
                    }
                }
                .zIndex(999) // Ensure animation is always on top
                .transition(.opacity)
            }
        }
    }

    // MARK: - Private Views
    
    // Note: The duplicated `loadingView` and `mainContentView` properties are kept
    // to minimize structural changes as per the request, but are not directly used by the body.
    
    /// A standalone loading view used during the initialization phase.
    private var loadingView: some View {
        ZStack {
            Color(.darkBackground).ignoresSafeArea()
            ProgressView().tint(.white)
        }
        .task {
            await AuthenticationHelper.updateUserAuthStatus()
            updateTheme()
            isInitialized = true
        }
    }

    /// The main content wrapper that applies global theme modifiers.
    private var mainContentView: some View {
        getMainContent()
            .tint(ThemeManager.shared.buttonColor)
            .onChange(of: colorScheme) { updateTheme() }
            .onChange(of: DevbanUserContainer.shared.loggedIn) { updateTheme() }
            .preferredColorScheme(
                ThemeManager.getActualColorScheme(
                    preferredColorScheme: DevbanUserContainer.shared.getPreferredColorScheme(),
                    colorScheme: colorScheme
                )
            )
    }

    /// Determines the appropriate view hierarchy based on the user's authentication and team status.
    private func getMainContent() -> some View {
        Group {
            if (!DevbanUserContainer.shared.loggedIn) {
                AuthenticationView()
            } else if (!DevbanUserContainer.shared.hasTeam) {
                TeamAuthenticationView()
            } else {
                // Main App Interface
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tabItem { Label("Home", systemImage: "house") }
                        .tag("home")

                    CalendarView()
                        .tabItem { Label("Calendar", systemImage: "calendar") }
                        .tag("calendar")

                    AskLLMView()
                        .tabItem { Label("AskLLM", systemImage: "apple.intelligence") }
                        .tag("askLLM")

                    ProfileView()
                        .tabItem { Label("Profile", systemImage: "person.crop.circle") }
                        .tag("profile")
                }
            }
        }
    }

    /// Refreshes the app's visual theme.
    private func updateTheme() {
        ThemeManager.shared.updateTheme(
            theme: DevbanUserContainer.shared.getTheme(),
            colorScheme: colorScheme,
            preferredColorScheme: DevbanUserContainer.shared.getPreferredColorScheme()
        )
    }
}
