import SwiftUI

struct ProfileView: View
{
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var showAccountDeletionSheetView: Bool = false

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
                        Button(role: .destructive)
                        {
                            showAccountDeletionSheetView = true
                        }
                        label:
                        {
                            Text("Delete account")
                        }

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
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
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
        .sheet(isPresented: $showAccountDeletionSheetView)
        {
            AccountDeletionSheetView()
        }
    }
}
