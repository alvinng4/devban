import SwiftUI

struct ProfileView: View
{
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var showLogoutAlert: Bool = false
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
                    Text("Profile")
                        .customTitle()

                    VStack(spacing: 10)
                    {
                        Text(DevbanUserContainer.shared.authDisplayName ?? "Error")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .shadowedBorderRoundedRectangle()

                    Text("Settings")
                        .customTitle()

                    VStack(spacing: 0)
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
                                                get: { DevbanUserContainer.shared.user?.preferredColorScheme ?? .auto },
                                                set: { DevbanUserContainer.shared.user?.preferredColorScheme = $0 },
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
                                            Text(DevbanUserContainer.shared.user?.preferredColorScheme
                                                .rawValue ?? "Error")
                                            Image(systemName: "chevron.up.chevron.down")
                                        }
                                    }
                                    .onChange(of: DevbanUserContainer.shared.user?.preferredColorScheme)
                                    {
                                        guard let user: DevbanUser = DevbanUserContainer.shared.user else { return }
                                        ThemeManager.shared.updateTheme(
                                            theme: user.theme,
                                            colorScheme: colorScheme,
                                            preferredColorScheme: user.preferredColorScheme,
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
                                                get: { DevbanUserContainer.shared.user?.theme ?? .blue },
                                                set: { DevbanUserContainer.shared.user?.theme = $0 },
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
                                            Text(DevbanUserContainer.shared.user?.theme.rawValue ?? "Error")
                                            Image(systemName: "chevron.up.chevron.down")
                                        }
                                    }
                                }
                                .onChange(of: DevbanUserContainer.shared.user?.theme)
                                {
                                    guard let user: DevbanUser = DevbanUserContainer.shared.user else { return }
                                    ThemeManager.shared.updateTheme(
                                        theme: user.theme,
                                        colorScheme: colorScheme,
                                        preferredColorScheme: user.preferredColorScheme,
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
                            .padding(.top, 20)
                            .padding(.horizontal, 5)
                        }
                        label:
                        {
                            Label("General", systemImage: "gearshape")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .foregroundStyle(.primary)
                        .padding()

                        Divider()

                        DisclosureGroup(isExpanded: $settingsIsAccountExpanded)
                        {
                            VStack(spacing: 15)
                            {
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
                            .padding(.top, 20)
                            .padding(.horizontal, 5)
                        }
                        label:
                        {
                            Label("Account", systemImage: "person.crop.circle")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .foregroundStyle(.primary)
                        .padding()
                    }
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
                do
                {
                    try AuthenticationHelper.signOutUser()
                }
                catch
                {
                    print(error.localizedDescription)
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
    }
}
