import SwiftUI

struct ProfileView: View
{
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var showAccountDeletionSheetView: Bool = false
    @State private var settingsIsGeneralExpanded: Bool = true
    @State private var settingsIsAccountExpanded: Bool = true

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
                        Text("User Profile")
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
                                                get: { DevbanUser.shared.preferredColorScheme },
                                                set: { DevbanUser.shared.preferredColorScheme = $0 },
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
                                            Text(DevbanUser.shared.preferredColorScheme.rawValue)
                                            Image(systemName: "chevron.up.chevron.down")
                                        }
                                    }
                                    .onChange(of: DevbanUser.shared.preferredColorScheme)
                                    {
                                        ThemeManager.shared.updateTheme(
                                            theme: DevbanUser.shared.theme,
                                            colorScheme: colorScheme,
                                            preferredColorScheme: DevbanUser.shared.preferredColorScheme,
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
                                                get: { DevbanUser.shared.theme },
                                                set: { DevbanUser.shared.theme = $0 },
                                            ),
                                        )
                                        {
                                            Text("Blue")
                                                .tag(ThemeManager.DefaultTheme.blue)

                                            Text("Green")
                                                .tag(ThemeManager.DefaultTheme.green)

                                            Text("Orange")
                                                .tag(ThemeManager.DefaultTheme.orange)
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
                                            Text(DevbanUser.shared.theme.rawValue)
                                            Image(systemName: "chevron.up.chevron.down")
                                        }
                                    }
                                }
                                .onChange(of: DevbanUser.shared.theme)
                                {
                                    ThemeManager.shared.updateTheme(
                                        theme: DevbanUser.shared.theme,
                                        colorScheme: colorScheme,
                                        preferredColorScheme: DevbanUser.shared.preferredColorScheme,
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
                .frame(maxWidth: NeobrutalismConstants.maxWidthSmall)
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
        .sheet(isPresented: $showAccountDeletionSheetView)
        {
            AccountDeletionSheetView()
        }
    }
}
