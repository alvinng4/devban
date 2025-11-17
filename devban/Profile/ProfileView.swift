import SwiftUI

struct ProfileView: View
{
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

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

                VStack(spacing: 10)
                {
                    // MARK: Profile

                    Text("Profile")
                        .customTitle()

                    VStack(spacing: 10)
                    {
                        HStack(spacing: 0)
                        {
                            Label("Display Name", systemImage: "person.text.rectangle")
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text(DevbanUserContainer.shared.authDisplayName ?? "Error")
                        }
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

                        Button
                        {
                            showGenerateInviteCodeSheetView = true
                        }
                        label:
                        {
                            Label("Generate invite codes", systemImage: "person.badge.shield.checkmark")
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

                                HStack(spacing: 0)
                                {
                                    Label("Dark mode", systemImage: "moon")
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    Menu
                                    {
                                        Picker(
                                            selection: Binding(
                                                get: {
                                                    DevbanUserContainer.shared.getPreferredColorScheme()
                                                },
                                                set: { DevbanUserContainer.shared.setPreferredColorScheme($0) },
                                            ),
                                        )
                                        {
                                            Text("Auto")
                                                .tag(ThemeManager.PreferredColorScheme.auto)

                                            Text("Dark")
                                                .tag(ThemeManager.PreferredColorScheme.dark)

                                            Text("Light")
                                                .tag(ThemeManager.PreferredColorScheme.light)
                                        }
                                        label:
                                        {
                                            Label("Dark mode", systemImage: "moon")
                                        }
                                    }
                                    label:
                                    {
                                        HStack(spacing: 5)
                                        {
                                            Text(DevbanUserContainer.shared.getPreferredColorScheme().rawValue)
                                            Image(systemName: "chevron.up.chevron.down")
                                        }
                                    }
                                    .onChange(of: DevbanUserContainer.shared.getPreferredColorScheme())
                                    {
                                        ThemeManager.shared.updateTheme(
                                            theme: DevbanUserContainer.shared.getTheme(),
                                            colorScheme: colorScheme,
                                            preferredColorScheme: DevbanUserContainer.shared.getPreferredColorScheme(),
                                        )
                                    }
                                }

                                Divider()

                                HStack(spacing: 0)
                                {
                                    Label("Theme", systemImage: "paintpalette")
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    Menu
                                    {
                                        Picker(
                                            selection: Binding(
                                                get: { DevbanUserContainer.shared.getTheme() },
                                                set: { DevbanUserContainer.shared.setTheme($0) },
                                            ),
                                        )
                                        {
                                            ForEach(ThemeManager.DefaultTheme.allCases)
                                            { themeCase in
                                                Text(themeCase.rawValue)
                                                    .tag(themeCase)
                                            }
                                        }
                                        label:
                                        {
                                            Label("Theme", systemImage: "paintpalette")
                                        }
                                    }
                                    label:
                                    {
                                        HStack(spacing: 5)
                                        {
                                            Text(DevbanUserContainer.shared.getTheme().rawValue)
                                            Image(systemName: "chevron.up.chevron.down")
                                        }
                                    }
                                }
                                .onChange(of: DevbanUserContainer.shared.getTheme())
                                {
                                    ThemeManager.shared.updateTheme(
                                        theme: DevbanUserContainer.shared.getTheme(),
                                        colorScheme: colorScheme,
                                        preferredColorScheme: DevbanUserContainer.shared.getPreferredColorScheme(),
                                    )
                                }

//                                Divider()
//
//                                HStack(spacing: 0)
//                                {
//                                    Label("Sound effects", systemImage: "music.note")
//                                        .frame(maxWidth: .infinity, alignment: .leading)
//
//                                    Toggle("", isOn: $settingsSoundEffect)
//                                        .fixedSize()
//                                }
//
//                                Divider()
//
//                                HStack(spacing: 0)
//                                {
//                                    Label("Haptic effects", systemImage: "iphone.gen1.radiowaves.left.and.right")
//                                        .frame(maxWidth: .infinity, alignment: .leading)
//
//                                    Toggle("", isOn: $settingsHapticEffect)
//                                        .fixedSize()
//                                }
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
