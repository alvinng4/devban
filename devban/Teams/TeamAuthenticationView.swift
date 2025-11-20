import SwiftUI

/// View for team authentication, allowing users to create or join a team.
struct TeamAuthenticationView: View
{
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var showReturnAlert: Bool = false

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
                    HStack(spacing: 0)
                    {
                        Button
                        {
                            showReturnAlert = true
                        }
                        label:
                        {
                            Image(systemName: "arrow.backward")
                                .toolBarButtonImage()
                        }
                        .buttonStyle(
                            ShadowedBorderRoundedRectangleButtonStyle(),
                        )

                        Spacer()
                    }

                    Text("Teams")
                        .customTitle()

                    NeobrutalismRoundedRectangleTabView(
                        options: ["Join team", "Create team"],
                        defaultSelection: "Join team",
                    )
                    { option in
                        switch (option)
                        {
                            case "Join team":
                                return AnyView(
                                    TeamJoinView(),
                                )
                            case _:
                                return AnyView(
                                    TeamCreateView(),
                                )
                        }
                    }
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
            }
        }
        .alert("Logout?", isPresented: $showReturnAlert)
        {
            Button(role: .cancel)
            {
                showReturnAlert = false
            }
            label:
            {
                Text("Cancel")
            }

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
                Text("Confirm")
            }
        }
        message:
        {
            Text("Are you sure you want to logout?")
        }
    }
}
