import SwiftUI

/// Header view for the calendar showing month/year and navigation controls.
struct CalendarHeaderView: View
{
    let selectedDate: Date
    let onPreviousMonth: () -> Void
    let onNextMonth: () -> Void
    let onToday: () -> Void

    private var monthYearText: String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }

    var body: some View
    {
        HStack
        {
            Button
            {
                onPreviousMonth()
            }
            label:
            {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .foregroundStyle(.black)
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Circle())
            }

            Spacer()

            VStack(spacing: 2)
            {
                Text(monthYearText)
                    .font(.system(size: 18, weight: .bold, design: .rounded))

                Button
                {
                    onToday()
                }
                label:
                {
                    Text("Today")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(ThemeManager.shared.buttonColor)
                        .clipShape(Capsule())
                }
            }

            Spacer()

            Button
            {
                onNextMonth()
            }
            label:
            {
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundStyle(.black)
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Circle())
            }
        }
        .padding()
    }
}
