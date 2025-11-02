import SwiftUI

/// View for adding or editing calendar events.
struct AddEventView: View
{
    @Environment(\.dismiss) private var dismiss

    let viewModel: CalendarViewModel
    let eventToEdit: CalendarEvent?

    @State private var title: String = ""
    @State private var selectedDate: Date = Date()
    @State private var hasTime: Bool = false
    @State private var startTime: Date = Date()
    @State private var hasEndTime: Bool = false
    @State private var endTime: Date = Date().addingTimeInterval(3600) // 1 hour later

    @FocusState private var isTitleFocused: Bool

    init(viewModel: CalendarViewModel, eventToEdit: CalendarEvent?)
    {
        self.viewModel = viewModel
        self.eventToEdit = eventToEdit
    }

    private var isEditing: Bool
    {
        eventToEdit != nil
    }

    private var canSave: Bool
    {
        !title.isEmptyOrWhitespace()
    }

    var body: some View
    {
        NavigationStack
        {
            ZStack
            {
                ThemeManager.shared.backgroundColor
                    .ignoresSafeArea()

                VStack(spacing: 20)
                {
                    VStack(alignment: .leading, spacing: 4)
                    {
                        Text("Title")
                            .fontDesign(.rounded)
                            .frame(maxWidth: .infinity, alignment: .topLeading)

                        TextField("Event title", text: $title)
                            .autocorrectionDisabled(true)
                            .font(.headline)
                            .focused($isTitleFocused)
                            .padding(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(.tertiary, lineWidth: 1),
                            )
                    }

                    VStack(alignment: .leading, spacing: 4)
                    {
                        Text("Date")
                            .fontDesign(.rounded)
                            .frame(maxWidth: .infinity, alignment: .topLeading)

                        DatePicker(
                            "Date",
                            selection: $selectedDate,
                            displayedComponents: [.date],
                        )
                        .datePickerStyle(.compact)
                    }

                    Toggle("Include time", isOn: $hasTime)
                        .fontDesign(.rounded)

                    if hasTime
                    {
                        VStack(alignment: .leading, spacing: 4)
                        {
                            Text("Start Time")
                                .fontDesign(.rounded)
                                .frame(maxWidth: .infinity, alignment: .topLeading)

                            DatePicker(
                                "Start Time",
                                selection: $startTime,
                                displayedComponents: [.hourAndMinute],
                            )
                            .datePickerStyle(.compact)

                            Toggle("Include end time", isOn: $hasEndTime)
                                .fontDesign(.rounded)
                                .padding(.top, 8)

                            if hasEndTime
                            {
                                VStack(alignment: .leading, spacing: 4)
                                {
                                    Text("End Time")
                                        .fontDesign(.rounded)
                                        .frame(maxWidth: .infinity, alignment: .topLeading)

                                    DatePicker(
                                        "End Time",
                                        selection: $endTime,
                                        displayedComponents: [.hourAndMinute],
                                    )
                                    .datePickerStyle(.compact)
                                }
                                .padding(.top, 8)
                            }
                        }
                    }

                    Spacer()

                    Button
                    {
                        saveEvent()
                    }
                    label:
                    {
                        Text(isEditing ? "Update Event" : "Add Event")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(
                                canSave ?
                                    ThemeManager.shared.buttonColor :
                                    Color.gray,
                            )
                            .cornerRadius(10)
                    }
                    .disabled(!canSave)
                }
                .padding(25)
                .shadowedBorderRoundedRectangle()
                .frame(maxWidth: NeobrutalismConstants.maxWidthSmall)
                .padding()
                .navigationTitle(isEditing ? "Edit Event" : "New Event")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar
                {
                    ToolbarItem(placement: .navigationBarLeading)
                    {
                        Button("Cancel")
                        {
                            dismiss()
                        }
                    }
                }
                .onAppear
                {
                    if let event = eventToEdit
                    {
                        title = event.title
                        selectedDate = event.date
                        if let start = event.startTime
                        {
                            hasTime = true
                            startTime = start
                            if let end = event.endTime
                            {
                                hasEndTime = true
                                endTime = end
                            }
                        }
                    }
                    isTitleFocused = true
                }
            }
        }
    }

    private func saveEvent()
    {
        var finalDate = selectedDate

        // Combine date and time if time is specified
        if hasTime
        {
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
            let timeComponents = calendar.dateComponents([.hour, .minute], from: startTime)

            var finalComponents = DateComponents()
            finalComponents.year = dateComponents.year
            finalComponents.month = dateComponents.month
            finalComponents.day = dateComponents.day
            finalComponents.hour = timeComponents.hour
            finalComponents.minute = timeComponents.minute

            if let combinedDate = calendar.date(from: finalComponents)
            {
                finalDate = combinedDate
            }
        }

        let newEvent = CalendarEvent(
            id: eventToEdit?.id ?? UUID(),
            title: title,
            date: finalDate,
            startTime: hasTime ? startTime : nil,
            endTime: (hasTime && hasEndTime) ? endTime : nil,
            isCompleted: eventToEdit?.isCompleted ?? false,
        )

        if isEditing
        {
            viewModel.updateEvent(newEvent)
        }
        else
        {
            viewModel.addEvent(newEvent)
        }

        dismiss()
    }
}
