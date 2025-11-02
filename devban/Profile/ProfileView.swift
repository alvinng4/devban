import SwiftUI

struct ProfileView: View
{
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

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

                    VStack(spacing: 0)
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
                            Text("Logout")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                    }
                    .shadowedBorderRoundedRectangle()
                }
                .frame(maxWidth: NeobrutalismConstants.maxWidthLarge)
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
    }
}
