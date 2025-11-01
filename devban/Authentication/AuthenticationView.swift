import SwiftUI

struct AuthenticationView: View
{
    var body: some View
    {
        NavigationStack
        {
            ZStack
            {
                ThemeManager.shared.backgroundColor
                    .ignoresSafeArea()

                SignInView()
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden)
            .scrollContentBackground(.hidden)
        }
    }
}
