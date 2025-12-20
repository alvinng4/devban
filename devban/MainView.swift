import SwiftUI

/// The main view of the application that handles routing between authentication and main content.
///
/// This view manages the application's initialization, theme updates, and displays different
/// content based on user authentication and team membership status.
struct MainView: View
{
    @Environment(\.colorScheme) private var colorScheme

    @State private var selectedTab: String = "home"
    @State private var isInitialized: Bool = false

    @State private var showLoginAnimation: Bool = false

    var body: some View {
        ZStack {

            if !isInitialized {
                ZStack {
                    Color(.darkBackground)
                        .ignoresSafeArea()

                    ProgressView()
                        .tint(.white)
                }
                .task {
                    await AuthenticationHelper.updateUserAuthStatus()
                    updateTheme()
                    isInitialized = true
                }
            } else {
                getMainContent()
                    .tint(ThemeManager.shared.buttonColor)
                    .onChange(of: colorScheme) {
                        updateTheme()
                    }
                    .onChange(of: DevbanUserContainer.shared.loggedIn) {
                        updateTheme()
                    }
                    .preferredColorScheme(
                        ThemeManager.getActualColorScheme(
                            preferredColorScheme: DevbanUserContainer.shared.getPreferredColorScheme(),
                            colorScheme: colorScheme
                        )
                    )
            }

            if showLoginAnimation {
                LoginSuccessAnimationView {
                    withAnimation {
                        showLoginAnimation = false
                    }
                }
                .zIndex(999)
                .transition(.opacity)
            }
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: .loginSuccessAnimation
            )
        ) { _ in
            showLoginAnimation = true
        }
    }

    // MARK: - Private Views
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

    /// Returns the appropriate content based on authentication and team membership status.
    private func getMainContent() -> some View
    {
        Group
        {
            if (!DevbanUserContainer.shared.loggedIn)
            {
                AuthenticationView()
            }
            else if (!DevbanUserContainer.shared.hasTeam)
            {
                TeamAuthenticationView()
            }
            else
            {
                TabView(
                    selection: $selectedTab,
                )
                {
                    HomeView()
                        .tabItem
                        {
                            Label("Home", systemImage: "house")
                        }
                        .tag("home")

                    CalendarView()
                        .tabItem
                        {
                            Label("Calendar", systemImage: "calendar")
                        }
                        .tag("calendar")

                    AskLLMView()
                        .tabItem
                        {
                            Label("AskLLM", systemImage: "apple.intelligence")
                        }
                        .tag("askLLM")

                    ProfileView()
                        .tabItem
                        {
                            Label("Profile", systemImage: "person.crop.circle")
                        }
                        .tag("profile")
                }
            }
        }
    }

    /// Updates the theme based on user preferences and system color scheme.
    private func updateTheme()
    {
        ThemeManager.shared.updateTheme(
            theme: DevbanUserContainer.shared.getTheme(),
            colorScheme: colorScheme,
            preferredColorScheme: DevbanUserContainer.shared.getPreferredColorScheme(),
        )
    }
}
