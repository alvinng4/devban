import SwiftUI

struct UserGamificationBarView: View
{
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
                    currentLevel: 0,
                    currentLevelExp: 0,
                    currentLevelTotalExp: 100,
                )
            }
            .buttonStyle(
                ShadowedBorderRoundedRectangleButtonStyle(),
            )
        }
        .frame(maxWidth: .infinity)
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
