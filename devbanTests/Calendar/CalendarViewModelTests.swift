import Foundation
import Testing
@testable import devban

/// Unit tests for `CalendarViewModel`.
struct CalendarViewModelTests {

    /// previousMonth() moves selectedDate one month back.
    @Test
    func previousMonth_movesDateBackOneMonth() throws {
        let calendar = Calendar.current
        let initialDate = calendar.date(from: DateComponents(year: 2024, month: 5, day: 15))!

        let viewModel = CalendarViewModel(
            selectedDate: initialDate,
            tasks: []
        )

        viewModel.previousMonth()

        let expectedDate = calendar.date(from: DateComponents(year: 2024, month: 4, day: 15))!
        #expect(calendar.isDate(viewModel.selectedDate, inSameDayAs: expectedDate))
    }

    /// nextMonth() moves selectedDate one month forward.
    @Test
    func nextMonth_movesDateForwardOneMonth() throws {
        let calendar = Calendar.current
        let initialDate = calendar.date(from: DateComponents(year: 2024, month: 5, day: 15))!

        let viewModel = CalendarViewModel(
            selectedDate: initialDate,
            tasks: []
        )

        viewModel.nextMonth()

        let expectedDate = calendar.date(from: DateComponents(year: 2024, month: 6, day: 15))!
        #expect(calendar.isDate(viewModel.selectedDate, inSameDayAs: expectedDate))
    }

    /// goToToday() sets selectedDate to today.
    @Test
    func goToToday_setsSelectedDateToToday() throws {
        let calendar = Calendar.current
        let oldDate = calendar.date(from: DateComponents(year: 2000, month: 1, day: 1))!

        let viewModel = CalendarViewModel(
            selectedDate: oldDate,
            tasks: []
        )

        viewModel.goToToday()

        #expect(calendar.isDateInToday(viewModel.selectedDate))
    }
}
