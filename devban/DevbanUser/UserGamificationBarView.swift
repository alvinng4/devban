import SwiftUI

/// Displays the user's gamification progress bar with level and experience points.
struct UserGamificationBarView: View
{
    let exp: Int = DevbanUserContainer.shared.getExp()
    var body: some View
    {
        HStack
        {
            // Level
            Button
            {}
            label:
            {
                ProgressIndicator(
                    currentLevel: currentLevel,
                    currentLevelExp: exp % 100,
                    currentLevelTotalExp: 100,
                )
            }
            .buttonStyle(
                ShadowedBorderRoundedRectangleButtonStyle(),
            )
        }
        .frame(maxWidth: .infinity)
    }

    var currentLevel: Int
    {
        return (exp / 100) + 1
    }

    private struct ProgressIndicator: View
    {
        let currentLevel: Int
        let currentLevelExp: Int
        let currentLevelTotalExp: Int

        var body: some View
        {
            HStack(spacing: 4)
            {
                Text("Lvl \(currentLevel)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                ProgressView(
                    value: max(0.0, Double(currentLevelExp)),
                    total: Double(currentLevelTotalExp),
                )
                .tint(Color("expColor"))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
    }
}
