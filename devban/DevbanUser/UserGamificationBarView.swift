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

            // Gold
            Button
            {}
            label:
            {
                GoldIndicatorView(0)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
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

    private struct GoldIndicatorView: View
    {
        init(_ gold: Int)
        {
            self.gold = gold
        }

        let gold: Int

        var body: some View
        {
            HStack(spacing: 4)
            {
                Image("goldCoin")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 18)

                if (gold >= 0)
                {
                    Text(gold, format: .number)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                else
                {
                    Text(gold, format: .number)
                        .foregroundStyle(Color.red)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
            }
        }
    }
}
