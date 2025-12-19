@testable import devban
import Foundation
import Testing

/// Unit tests for the `SignUpView.SignUpViewModel`.
struct SignUpViewModelTests
{
    // MARK: - Helpers

    /// Creates a fresh `SignUpViewModel` with default state.
    private func makeSUT() -> SignUpView.SignUpViewModel
    {
        SignUpView.SignUpViewModel()
    }

    // MARK: - Auth input validation

    /// Returns true when email and password are non-empty and non-whitespace.
    @Test
    func isAuthInputValid_isTrueForNonEmptyEmailAndPassword() throws
    {
        let sut = makeSUT()
        sut.email = "user@example.com"
        sut.password = "password123"

        #expect(sut.isAuthInputValid() == true)
    }

    /// Returns false when email or password is empty or whitespace only.
    @Test
    func isAuthInputValid_isFalseWhenEmailOrPasswordIsEmpty() throws
    {
        let sut = makeSUT()

        sut.email = ""
        sut.password = "password123"
        #expect(sut.isAuthInputValid() == false)

        sut.email = "user@example.com"
        sut.password = ""
        #expect(sut.isAuthInputValid() == false)

        sut.email = "   "
        sut.password = "   "
        #expect(sut.isAuthInputValid() == false)
    }

    // MARK: - Display name validation

    /// Returns true when display name is non-empty and shorter than 64 characters.
    @Test
    func isDisplayNameInputValid_isTrueForNonEmptyShortName() throws
    {
        let sut = makeSUT()
        sut.displayName = "Valid name"

        #expect(sut.isDiaplayNameInputValid() == true)
    }

    /// Returns false when display name is empty or whitespace only.
    @Test
    func isDisplayNameInputValid_isFalseWhenEmptyOrWhitespace() throws
    {
        let sut = makeSUT()

        sut.displayName = ""
        #expect(sut.isDiaplayNameInputValid() == false)

        sut.displayName = "   "
        #expect(sut.isDiaplayNameInputValid() == false)
    }

    /// Returns false when display name has 64 or more characters.
    @Test
    func isDisplayNameInputValid_isFalseWhenTooLong() throws
    {
        let sut = makeSUT()
        sut.displayName = String(repeating: "a", count: 64)

        #expect(sut.isDiaplayNameInputValid() == false)
    }

    // MARK: - Disable submit

    /// Disables submit when any input is invalid or waiting for server response.
    @Test
    func disableSubmit_isTrueWhenInputInvalidOrWaiting() throws
    {
        let sut = makeSUT()
        sut.email = ""
        sut.password = ""
        sut.displayName = ""

        #expect(sut.disableSubmit() == true)

        sut.email = "user@example.com"
        sut.password = "password123"
        sut.displayName = "Valid"
        sut.waitingServerResponse = true

        #expect(sut.disableSubmit() == true)
    }

    /// Keeps submit enabled when all inputs are valid and not waiting for server response.
    @Test
    func disableSubmit_isFalseWhenAllValidAndNotWaiting() throws
    {
        let sut = makeSUT()
        sut.email = "user@example.com"
        sut.password = "password123"
        sut.displayName = "Valid name"
        sut.waitingServerResponse = false

        #expect(sut.disableSubmit() == false)
    }

    // MARK: - Dismiss or alert

    /// Dismisses directly when email and password are empty or whitespace.
    @Test
    func dismissOrShowAlert_dismissesWhenNoAuthInput() throws
    {
        let sut = makeSUT()
        sut.email = ""
        sut.password = ""

        sut.dismissOrShowAlert()

        #expect(sut.dismiss == true)
        #expect(sut.isPresentReturnAlert == false)
    }

    /// Shows return alert when there is any auth input.
    @Test
    func dismissOrShowAlert_showsAlertWhenAuthInputPresent() throws
    {
        let sut = makeSUT()
        sut.email = "user@example.com"
        sut.password = ""

        sut.dismissOrShowAlert()

        #expect(sut.dismiss == false)
        #expect(sut.isPresentReturnAlert == true)
    }
}
