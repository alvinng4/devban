import SwiftUI

/// View for user profile and settings management.
///
/// This view displays comprehensive user profile information and settings in a scrollable interface.
/// It includes:
/// - User profile section with display name, level, and experience points
/// - Team information (team name, user role, member count)
/// - Settings sections for general preferences (dark mode, theme, sound, haptics) and account actions (logout, delete)
/// - About section with app version and contact information
/// - Real-time synchronization with Firestore for team data updates
///
/// The view uses the @Observable pattern via DevbanUserContainer.shared to reactively display
/// current user data and team information. When team members sheet closes, it refreshes team data
/// to ensure all users see the latest state (especially important for admin transfers).
struct ProfileView: View {
    
    // MARK: - Environment Variables
    
    /// Current color scheme (light/dark) from system settings
    @Environment(\.colorScheme) private var colorScheme
    
    /// Horizontal size class (compact for iPhone, regular for iPad)
    /// Used to adapt layout and padding for different device sizes
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    // MARK: - State Variables for Alerts
    
    /// Controls visibility of the "Quit Team" confirmation alert
    @State private var showQuitTeamAlert: Bool = false
    
    /// Controls visibility of the "Logout" confirmation alert
    @State private var showLogoutAlert: Bool = false
    
    /// Controls visibility of the "Generate Invite Codes" sheet
    @State private var showGenerateInviteCodeSheetView: Bool = false
    
    /// Controls visibility of the "Delete Account" sheet
    @State private var showAccountDeletionSheetView: Bool = false
    
    // MARK: - State Variables for Disclosure Groups
    
    /// Tracks whether the General settings section is expanded
    @State private var settingsIsGeneralExpanded: Bool = false
    
    /// Tracks whether the Account settings section is expanded
    @State private var settingsIsAccountExpanded: Bool = false
    
    // MARK: - State Variables for Team Members Sheet
    
    /// Controls visibility of the team members management sheet
    @State private var showTeamMembersSheet: Bool = false
    
    /// Tracks whether the Members row is in "expanded" state (visual indicator only)
    @State private var isTeamMembersExpanded: Bool = false
    
    // MARK: - View Body
    
    var body: some View {
        // Determine if device is in compact size class (iPhone portrait)
        let isCompact: Bool = (horizontalSizeClass == .compact)
        
        NavigationStack {
            ZStack {
                // Background color fills entire screen
                ThemeManager.shared.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 10) {
                        
                        // MARK: Profile Section
                        /// Displays user's display name, current level, and experience progress bar
                        Text("Profile")
                            .customTitle()
                        
                        VStack(spacing: 8) {
                            // User's display name
                            Text(DevbanUserContainer.shared.authDisplayName ?? "Error")
                                .font(.system(size: 25))
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Level and experience information
                            HStack {
                                Text("LEVEL \(DevbanUserContainer.shared.getExp() / 100 + 1)")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("\(DevbanUserContainer.shared.getExp() % 100) / 100 EXP")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                            
                            // Experience progress bar
                            ProgressView(
                                value: max(0.0, Double(DevbanUserContainer.shared.getExp() % 100)),
                                total: 100.0
                            )
                            .tint(Color("expColor"))
                            .scaleEffect(y: 1.5)
                        }
                        .padding()
                        .shadowedBorderRoundedRectangle()
                        
                        // MARK: Team Section
                        /// Displays team information: name, user's role, and member management
                        Text("Team")
                            .customTitle()
                        
                        VStack(spacing: 15) {
                            // Team name row
                            HStack(spacing: 0) {
                                Label("Team Name", systemImage: "person.2.circle")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text(DevbanUserContainer.shared.getTeamName() ?? "Error")
                            }
                            
                            Divider()
                            
                            // User's role in team row
                            /// Shows "Admin" or "Member" - automatically updates via @Observable
                            HStack(spacing: 0) {
                                Label("Role", systemImage: "person.badge.shield.checkmark")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text(DevbanUserContainer.shared.getUserTeamRole()?.rawValue.capitalized ?? "Error")
                            }
                            
                            Divider()
                            
                            // Team members row with tap gesture to open sheet
                            /// Displays member count and opens team members management sheet
                            HStack(spacing: 0) {
                                Label("Members", systemImage: "person.2.circle")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack(spacing: 8) {
                                    if let numberOfMembers = DevbanUserContainer.shared.getTeamMembersCount() {
                                        Text("\(numberOfMembers)")
                                    } else {
                                        Text("Error")
                                    }
                                    
                                    // Chevron that rotates when expanded
                                    Image(systemName: isTeamMembersExpanded ? "chevron.up" : "chevron.down")
                                        .font(.system(size: 12, weight: .semibold))
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                showTeamMembersSheet = true
                            }
                            
                            Divider()
                            
                            // Generate invite codes button
                            Button {
                                showGenerateInviteCodeSheetView = true
                            } label: {
                                Label("Generate invite codes", systemImage: "person.crop.circle.fill.badge.plus")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider()
                            
                            // Exit team button
                            Button {
                                showQuitTeamAlert = true
                            } label: {
                                Label("Exit team", systemImage: "rectangle.portrait.and.arrow.right")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .shadowedBorderRoundedRectangle()
                        
                        // MARK: Settings Section
                        /// Expandable settings grouped into General and Account categories
                        Text("Settings")
                            .customTitle()
                        
                        VStack(spacing: 15) {
                            // MARK: General Settings Group
                            /// Contains appearance and behavior preferences
                            DisclosureGroup(isExpanded: $settingsIsGeneralExpanded) {
                                VStack(spacing: 15) {
                                    Divider()
                                    
                                    // Dark mode preference picker
                                    HStack(spacing: 0) {
                                        Label("Dark mode", systemImage: "moon")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Picker(
                                            selection: Binding(
                                                get: { DevbanUserContainer.shared.getPreferredColorScheme() },
                                                set: { DevbanUserContainer.shared.setPreferredColorScheme($0) }
                                            ),
                                            label: Text("Dark mode")
                                        ) {
                                            Text("Auto").tag(ThemeManager.PreferredColorScheme.auto)
                                            Text("Dark").tag(ThemeManager.PreferredColorScheme.dark)
                                            Text("Light").tag(ThemeManager.PreferredColorScheme.light)
                                        }
                                        .pickerStyle(.menu)
                                    }
                                    .onChange(of: DevbanUserContainer.shared.getPreferredColorScheme()) {
                                        ThemeManager.shared.updateTheme(
                                            theme: DevbanUserContainer.shared.getTheme(),
                                            colorScheme: colorScheme,
                                            preferredColorScheme: DevbanUserContainer.shared.getPreferredColorScheme()
                                        )
                                    }
                                    
                                    Divider()
                                    
                                    // Theme color picker
                                    HStack(spacing: 0) {
                                        Label("Theme", systemImage: "paintpalette")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Picker(
                                            selection: Binding(
                                                get: { DevbanUserContainer.shared.getTheme() },
                                                set: { DevbanUserContainer.shared.setTheme($0) }
                                            ),
                                            label: Text("Theme")
                                        ) {
                                            ForEach(ThemeManager.DefaultTheme.allCases) { themeCase in
                                                Text(themeCase.rawValue).tag(themeCase)
                                            }
                                        }
                                        .pickerStyle(.menu)
                                    }
                                    .onChange(of: DevbanUserContainer.shared.getTheme()) {
                                        ThemeManager.shared.updateTheme(
                                            theme: DevbanUserContainer.shared.getTheme(),
                                            colorScheme: colorScheme,
                                            preferredColorScheme: DevbanUserContainer.shared.getPreferredColorScheme()
                                        )
                                    }
                                    
                                    Divider()
                                    
                                    // Sound effects toggle
                                    HStack(spacing: 0) {
                                        Label("Sound effects", systemImage: "music.note")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Toggle(
                                            "",
                                            isOn: Binding(
                                                get: { DevbanUserContainer.shared.getSoundEffectSetting() },
                                                set: { DevbanUserContainer.shared.setSoundEffectSetting($0) }
                                            )
                                        )
                                        .fixedSize()
                                    }
                                    
                                    Divider()
                                    
                                    // Chat input preview toggle
                                    /// Toggles whether message preview appears while typing
                                    HStack(spacing: 0) {
                                        Label("Show input preview", systemImage: "eye")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Toggle(
                                            "",
                                            isOn: Binding(
                                                get: { DevbanUserContainer.shared.getChatInputPreviewSetting() },
                                                set: { DevbanUserContainer.shared.setChatInputPreviewSetting($0) }
                                            )
                                        )
                                        .fixedSize()
                                    }
                                    
                                    Divider()
                                    
                                    // Haptic feedback toggle
                                    HStack(spacing: 0) {
                                        Label("Haptic effects", systemImage: "iphone.gen1.radiowaves.left.and.right")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Toggle(
                                            "",
                                            isOn: Binding(
                                                get: { DevbanUserContainer.shared.getHapticEffectSetting() },
                                                set: { DevbanUserContainer.shared.setHapticEffectSetting($0) }
                                            )
                                        )
                                        .fixedSize()
                                    }
                                }
                                .padding(5)
                            } label: {
                                Label("General", systemImage: "gearshape")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .foregroundStyle(.primary)
                            
                            Divider()
                            
                            // MARK: Account Settings Group
                            /// Contains account-related actions
                            DisclosureGroup(isExpanded: $settingsIsAccountExpanded) {
                                VStack(spacing: 15) {
                                    Divider()
                                    
                                    // Logout button
                                    Button {
                                        showLogoutAlert = true
                                    } label: {
                                        Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .frame(maxWidth: .infinity)
                                    
                                    Divider()
                                    
                                    // Delete account button
                                    Button {
                                        showAccountDeletionSheetView = true
                                    } label: {
                                        Label("Delete account", systemImage: "exclamationmark.triangle")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .padding(5)
                            } label: {
                                Label("Account", systemImage: "person.crop.circle")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .foregroundStyle(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .shadowedBorderRoundedRectangle()
                        
                        // MARK: About Section
                        /// Displays app information and contact
                        Text("About")
                            .customTitle()
                        
                        VStack(spacing: 15) {
                            // App version
                            HStack(spacing: 0) {
                                Label("App Version", systemImage: "number.circle")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if let versionString: String = Bundle.main
                                    .infoDictionary?["CFBundleShortVersionString"] as? String {
                                    Text(versionString)
                                } else {
                                    Text("Unknown")
                                }
                            }
                            
                            Divider()
                            
                            // Contact email link
                            Link(destination: URL(string: "mailto:csci3100group17@gmail.com")!) {
                                Label("csci3100group17@gmail.com", systemImage: "envelope")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .tint(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .shadowedBorderRoundedRectangle()
                    }
                    .frame(maxWidth: NeobrutalismConstants.maxWidthMedium)
                    .padding(
                        .horizontal,
                        isCompact ?
                        NeobrutalismConstants.mainContentPaddingHorizontalCompact :
                        NeobrutalismConstants.mainContentPaddingHorizontalRegular
                    )
                    .padding(
                        .vertical,
                        isCompact ?
                        NeobrutalismConstants.mainContentPaddingVerticalCompact :
                        NeobrutalismConstants.mainContentPaddingVerticalRegular
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                
                .navigationBarBackButtonHidden(true)
                .toolbar(.hidden)
                .scrollContentBackground(.hidden)
            }
            
            // MARK: - Alerts
            
            /// Logout confirmation alert
            .alert("Confirm Logout", isPresented: $showLogoutAlert) {
                Button(role: .destructive) {
                    Task {
                        do {
                            try await AuthenticationHelper.signOutUser()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                } label: {
                    Text("Logout")
                }
                
                Button(role: .cancel) {
                    showLogoutAlert = false
                } label: {
                    Text("Cancel")
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
            
            /// Quit team confirmation alert
            .alert("Quit team?", isPresented: $showQuitTeamAlert) {
                Button(role: .destructive) {
                    Task {
                        do {
                            try await DevbanUserContainer.shared.quitTeam()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                } label: {
                    Text("Quit")
                }
                
                Button(role: .cancel) {
                    showQuitTeamAlert = false
                } label: {
                    Text("Cancel")
                }
            } message: {
                Text("Are you sure you want to quit the team?")
            }
            
            // MARK: - Sheets
            
            /// Account deletion sheet
            .sheet(isPresented: $showAccountDeletionSheetView) {
                AccountDeletionSheetView()
            }
            
            /// Generate invite codes sheet
            .sheet(isPresented: $showGenerateInviteCodeSheetView) {
                GenerateInviteCodeSheetView()
            }
            
            /// Team members management sheet
            /// Includes callback to refresh team data when admin is transferred
            .sheet(isPresented: $showTeamMembersSheet) {
                TeamMembersSheetView(
                    currentUserUID: DevbanUserContainer.shared.getUid(),
                    currentUserRole: DevbanUserContainer.shared.getUserTeamRole()?.rawValue,
                    teamId: DevbanUserContainer.shared.getTeamId(),
                    onAdminTransferred: {
                        Task {
                            if let teamId = DevbanUserContainer.shared.getTeamId() {
                                try await DevbanUserContainer.shared.setTeam(id: teamId)
                            }
                        }
                    }
                )
            }
            
            // MARK: - Change Handlers
            
            /// Refreshes team data when team members sheet closes
            /// This ensures real-time synchronization when other users transfer admin or modify team
            .onChange(of: showTeamMembersSheet) { oldValue, newValue in
                if oldValue == true && newValue == false {
                    Task {
                        if let teamId = DevbanUserContainer.shared.getTeamId() {
                            try await DevbanUserContainer.shared.setTeam(id: teamId)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
