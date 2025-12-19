import SwiftUI

/// View for user profile and settings management.
struct ProfileView: View
{
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var showQuitTeamAlert: Bool = false
    @State private var showLogoutAlert: Bool = false
    @State private var showGenerateInviteCodeSheetView: Bool = false
    @State private var showAccountDeletionSheetView: Bool = false
    @State private var settingsIsGeneralExpanded: Bool = false
    @State private var settingsIsAccountExpanded: Bool = false

    var body: some View
    {
        let isCompact: Bool = (horizontalSizeClass == .compact)

        NavigationStack
        {
            ZStack
            {
                ThemeManager.shared.backgroundColor
                    .ignoresSafeArea()

                ScrollView
                {
                    VStack(spacing: 10)
                    {
                        // MARK: Profile

                        Text("Profile")
                            .customTitle()

                        VStack(spacing: 8)
                        {
                            Text(DevbanUserContainer.shared.authDisplayName ?? "Error")
                                .font(.system(size: 25))
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            HStack
                            {
                                Text("LEVEL \(DevbanUserContainer.shared.getExp() / 100 + 1)")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(.secondary)

                                Spacer()

                                Text("\(DevbanUserContainer.shared.getExp() % 100) / 100 EXP")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                            }

                            ProgressView(
                                value: max(0.0, Double(DevbanUserContainer.shared.getExp() % 100)),
                                total: 100.0,
                            )
                            .tint(Color("expColor"))
                            .scaleEffect(y: 1.5)
                        }
                        .padding()
                        .shadowedBorderRoundedRectangle()

                        // MARK: Team

                        Text("Team")
                            .customTitle()

                        VStack(spacing: 15)
                        {
                            HStack(spacing: 0)
                            {
                                Label("Team Name", systemImage: "person.2.circle")
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text(DevbanUserContainer.shared.getTeamName() ?? "Error")
                            }

                            Divider()

                            HStack(spacing: 0)
                            {
                                Label("Role", systemImage: "person.badge.shield.checkmark")
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text(DevbanUserContainer.shared.getUserTeamRole()?.rawValue.capitalized ?? "Error")
                            }

                            Divider()

                            HStack(spacing: 0)
                            {
                                Label("Number of members", systemImage: "number.circle")
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                if let numberOfMembers = DevbanUserContainer.shared.getTeamMembersCount()
                                {
                                    Text("\(numberOfMembers)")
                                }
                                else
                                {
                                    Text("Error")
                                }
                            }

                            Divider()

                            Button
                            {
                                showGenerateInviteCodeSheetView = true
                            }
                            label:
                            {
                                Label("Generate invite codes", systemImage: "person.crop.circle.fill.badge.plus")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(PlainButtonStyle())

                            Divider()

                            Button
                            {
                                showQuitTeamAlert = true
                            }
                            label:
                            {
                                Label("Exit team", systemImage: "rectangle.portrait.and.arrow.right")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .shadowedBorderRoundedRectangle()

                        // MARK: Settings

                        Text("Settings")
                            .customTitle()

                        VStack(spacing: 15)
                        {
                            DisclosureGroup(isExpanded: $settingsIsGeneralExpanded)
                            {
                                VStack(spacing: 15)
                                {
                                    Divider()

                                    /// Preferred color scheme picker
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
                                            preferredColorScheme: DevbanUserContainer.shared.getPreferredColorScheme(),
                                        )
                                    }


                                    Divider()

                                    /// Theme picker
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
                                            preferredColorScheme: DevbanUserContainer.shared.getPreferredColorScheme(),
                                        )
                                    }


                                    Divider()

                                    HStack(spacing: 0)
                                    {
                                        Label("Sound effects", systemImage: "music.note")
                                            .frame(maxWidth: .infinity, alignment: .leading)

                                        Toggle(
                                            "",
                                            isOn: Binding(
                                                get: { DevbanUserContainer.shared.getSoundEffectSetting() },
                                                set: { DevbanUserContainer.shared.setSoundEffectSetting($0) },
                                            ),
                                        )
                                        .fixedSize()
                                    }

                                    Divider()

                                    /// Chat input preview toggle
                                    HStack(spacing: 0) {
                                        Label("Show input preview", systemImage: "eye")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Toggle(
                                            "",
                                            isOn: Binding(
                                                get: { DevbanUserContainer.shared.getChatInputPreviewSetting() },
                                                set: { DevbanUserContainer.shared.setChatInputPreviewSetting($0) },
                                            ),
                                        )
                                        .fixedSize()
                                    }

                                    Divider()

                                    HStack(spacing: 0)
                                    {
                                        Label("Haptic effects", systemImage: "iphone.gen1.radiowaves.left.and.right")
                                            .frame(maxWidth: .infinity, alignment: .leading)

                                        Toggle(
                                            "",
                                            isOn: Binding(
                                                get: { DevbanUserContainer.shared.getHapticEffectSetting() },
                                                set: { DevbanUserContainer.shared.setHapticEffectSetting($0) },
                                            ),
                                        )
                                        .fixedSize()
                                    }
                                }
                                .padding(5)
                            }
                            label:
                            {
                                Label("General", systemImage: "gearshape")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .foregroundStyle(.primary)

                            Divider()

                            DisclosureGroup(isExpanded: $settingsIsAccountExpanded)
                            {
                                VStack(spacing: 15)
                                {
                                    Divider()

                                    Button
                                    {
                                        showLogoutAlert = true
                                    }
                                    label:
                                    {
                                        Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .frame(maxWidth: .infinity)

                                    Divider()

                                    Button
                                    {
                                        showAccountDeletionSheetView = true
                                    }
                                    label:
                                    {
                                        Label("Delete account", systemImage: "exclamationmark.triangle")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .padding(5)
                            }
                            label:
                            {
                                Label("Account", systemImage: "person.crop.circle")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .foregroundStyle(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .shadowedBorderRoundedRectangle()

                        // MARK: About

                        Text("About")
                            .customTitle()

                        VStack(spacing: 15)
                        {
                            HStack(spacing: 0)
                            {
                                Label("App Version", systemImage: "number.circle")
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                if let versionString: String = Bundle.main
                                    .infoDictionary?["CFBundleShortVersionString"] as? String
                                {
                                    Text(versionString)
                                }
                                else
                                {
                                    Text("Unknown")
                                }
                            }

                            Divider()

                            Link(destination: URL(string: "mailto:csci3100group17@gmail.com")!)
                            {
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
                            NeobrutalismConstants.mainContentPaddingHorizontalRegular,
                    )
                    .padding(
                        .vertical,
                        isCompact ?
                            NeobrutalismConstants.mainContentPaddingVerticalCompact :
                            NeobrutalismConstants.mainContentPaddingVerticalRegular,
                    )
                    .frame(maxWidth: .infinity, alignment: .center) // For scroll bar to be on edge
                }
                .navigationBarBackButtonHidden(true)
                .toolbar(.hidden)
                .scrollContentBackground(.hidden)
            }
        }
        .alert("Confirm Logout", isPresented: $showLogoutAlert)
        {
            Button(role: .destructive)
            {
                Task
                {
                    do
                    {
                        try await AuthenticationHelper.signOutUser()
                    }
                    catch
                    {
                        print(error.localizedDescription)
                    }
                }
            }
            label:
            {
                Text("Logout")
            }

            Button(role: .cancel)
            {
                showLogoutAlert = false
            }
            label:
            {
                Text("Cancel")
            }
        }
        message:
        {
            Text("Are you sure you want to logout?")
        }
        .alert("Quit team?", isPresented: $showQuitTeamAlert)
        {
            Button(role: .destructive)
            {
                Task
                {
                    do
                    {
                        try await DevbanUserContainer.shared.quitTeam()
                    }
                    catch
                    {
                        print(error.localizedDescription)
                    }
                }
            }
            label:
            {
                Text("Quit")
            }

            Button(role: .cancel)
            {
                showQuitTeamAlert = false
            }
            label:
            {
                Text("Cancel")
            }
        }
        message:
        {
            Text("Are you sure you want to quit the team?")
        }
        .sheet(isPresented: $showAccountDeletionSheetView)
        {
            AccountDeletionSheetView()
        }
        .sheet(isPresented: $showGenerateInviteCodeSheetView)
        {
            GenerateInviteCodeSheetView()
        }
    }
}
