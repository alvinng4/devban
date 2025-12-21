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
/// - **Global Overlays:** Handles the `LoginSuccessAnimationView` triggered via NotificationCenter.
struct MainView: View {
    
    @Environment(\.colorScheme) private var colorScheme

    /// Tracks the currently selected tab in the main interface.
    @State private var selectedTab: String = "home"
    
    /// Indicates whether the app has finished its initial data loading and auth checks.
    @State private var isInitialized: Bool = false

    /// Controls the visibility of the login success animation overlay.
    @State private var showLoginAnimation: Bool = false

    var body: some View {
        ZStack {

            // 1. Initialization State Handling
            if !isInitialized {
                // Show loading screen while checking auth status
                ZStack {
                    Color(.darkBackground)
                        .ignoresSafeArea()

                    ProgressView()
                        .tint(.white)
                }
                .task {
                    // Perform async initialization
                    await AuthenticationHelper.updateUserAuthStatus()
                    updateTheme()
                    isInitialized = true
                }
            } else {
                // 2. Main Content Routing
                getMainContent()
                    .tint(ThemeManager.shared.buttonColor)
                    // React to system dark/light mode changes
                    .onChange(of: colorScheme) {
                        updateTheme()
                    }
                    // React to login status changes (e.g. logout)
                    .onChange(of: DevbanUserContainer.shared.loggedIn) {
                        updateTheme()
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
            if showLoginAnimation {
                LoginSuccessAnimationView {
                    withAnimation {
                        showLoginAnimation = false
                    }
                }
                .zIndex(999) // Ensure animation is always on top
                .transition(.opacity)
            }
        }
        // Listen for login success event to trigger animation
        .onReceive(
            NotificationCenter.default.publisher(
                for: .loginSuccessAnimation
            )
        ) { _ in
            showLoginAnimation = true
        }
    }

    // MARK: - Private Views
    
    /// A standalone loading view used during the initialization phase.
    ///
    /// Note: This property duplicates the logic inside `body`.
    /// Ideally, the body should utilize this property to reduce code duplication.
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
    ///
    /// Note: This property duplicates the logic inside `body`.
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
    ///
    /// - Returns: A view corresponding to the current state:
    ///   - `AuthenticationView`: If the user is not logged in.
    ///   - `TeamAuthenticationView`: If logged in but hasn't joined/created a team.
    ///   - `TabView`: If fully authenticated and part of a team.
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
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                        .tag("home")

                    CalendarView()
                        .tabItem {
                            Label("Calendar", systemImage: "calendar")
                        }
                        .tag("calendar")

                    AskLLMView()
                        .tabItem {
                            Label("AskLLM", systemImage: "apple.intelligence")
                        }
                        .tag("askLLM")

                    ProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person.crop.circle")
                        }
                        .tag("profile")
                }
            }
        }
    }

    /// Refreshes the app's visual theme.
    ///
    /// This method synchronizes the `ThemeManager` with the current user preferences stored in
    /// `DevbanUserContainer` and the current system `colorScheme`.
    private func updateTheme() {
        ThemeManager.shared.updateTheme(
            theme: DevbanUserContainer.shared.getTheme(),
            colorScheme: colorScheme,
            preferredColorScheme: DevbanUserContainer.shared.getPreferredColorScheme()
        )
    }
}
