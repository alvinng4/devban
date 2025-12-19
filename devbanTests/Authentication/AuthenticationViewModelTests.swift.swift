@testable import devban
import Foundation
import Testing

/// Unit tests for the `AuthenticationView.AuthenticationViewModel`.
struct AuthenticationViewModelTests
{
    // MARK: - Helpers

    /// Creates a fresh `AuthenticationViewModel` with default state.
    private func makeSUT() -> AuthenticationView.AuthenticationViewModel
    {
        AuthenticationView.AuthenticationViewModel()
    }

    // MARK: - Input validation

    /// Returns true when both email and password are non-empty and non-whitespace.
    @Test
    func isInputValid_isTrueForNonEmptyEmailAndPassword() throws
    {
        let sut = makeSUT()
        sut.email = "user@example.com"
        sut.password = "password123"

        #expect(sut.isInputValid() == true)
    }

    /// Returns false when email or password is empty or whitespace only.
    @Test
    func isInputValid_isFalseWhenEmailOrPasswordIsEmpty() throws
    {
        let sut = makeSUT()

        sut.email = ""
        sut.password = "password123"
        #expect(sut.isInputValid() == false)

        sut.email = "user@example.com"
        sut.password = ""
        #expect(sut.isInputValid() == false)

        sut.email = "   "
        sut.password = "   "
        #expect(sut.isInputValid() == false)
    }

    // MARK: - Disable submit

    /// Disables submit when input is invalid.
    @Test
    func disableSubmit_isTrueWhenInputInvalid() throws
    {
        let sut = makeSUT()
        sut.email = ""
        sut.password = ""

        #expect(sut.disableSubmit() == true)
    }

    /// Keeps submit enabled when input is valid and not waiting for server response.
    @Test
    func disableSubmit_isFalseWhenInputValidAndNotWaiting() throws
    {
        let sut = makeSUT()
        sut.email = "user@example.com"
        sut.password = "password123"

        #expect(sut.disableSubmit() == false)
    }

    // MARK: - Forget password

    /// Sets the forget-password alert flag to true.
    @Test
    func forgetPassword_setsAlertFlag() throws
    {
        let sut = makeSUT()
        #expect(sut.isPresentForgetPasswordAlert == false)

        sut.forgetPassword()

        #expect(sut.isPresentForgetPasswordAlert == true)
    }

    /// Shows an error message when confirmForgetPassword is called with an empty email.
    @Test
    func confirmForgetPassword_withEmptyEmail_showsErrorMessage() throws
    {
        let sut = makeSUT()
        sut.email = ""

        sut.confirmForgetPassword()

        #expect(sut.isShowMessage == true)
        #expect(sut.messageType == .error)
        #expect(sut.message.contains("invalid email address"))
    }

    /// Shows a success message when confirmForgetPassword is called with a valid email.
    @Test
    func confirmForgetPassword_withValidEmail_showsSuccessMessage() throws
    {
        let sut = makeSUT()
        sut.email = "user@example.com"

        sut.confirmForgetPassword()

        #expect(sut.isShowMessage == true)
        #expect(sut.messageType == .special)
        #expect(sut.message.contains("user@example.com"))
    }
}
