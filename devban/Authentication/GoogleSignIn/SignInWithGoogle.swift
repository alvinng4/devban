//
//  SignInWithGoogle.swift
//
//
//  Created by Nick Sarno on 10/25/23.
//
import Foundation
import GoogleSignIn
import GoogleSignInSwift
import SwiftUI
import UIKit

/// Represents the result of a Google Sign-In attempt.
struct GoogleSignInResult
{
    let idToken: String
    let accessToken: String
    let email: String?
    let firstName: String?
    let lastName: String?
    let fullName: String?

    /// Returns the display name, preferring full name over first or last name.
    var displayName: String?
    {
        fullName ?? firstName ?? lastName
    }

    /// Initializes from a Google Sign-In SDK result.
    ///
    /// - Parameter result: The result from Google Sign-In
    /// - Returns: nil if the ID token is missing
    init?(result: GIDSignInResult)
    {
        guard let idToken = result.user.idToken?.tokenString
        else
        {
            return nil
        }

        self.idToken = idToken
        self.accessToken = result.user.accessToken.tokenString
        self.email = result.user.profile?.email
        self.firstName = result.user.profile?.givenName
        self.lastName = result.user.profile?.familyName
        self.fullName = result.user.profile?.name
    }
}

/// Helper class for managing Google Sign-In operations.
final class SignInWithGoogleHelper
{
    /// Initializes the Google Sign-In helper with a client ID.
    ///
    /// - Parameter GIDClientID: The Google Sign-In client ID from Firebase configuration
    init(GIDClientID: String)
    {
        let config = GIDConfiguration(clientID: GIDClientID)
        GIDSignIn.sharedInstance.configuration = config
    }

    /// Initiates the Google Sign-In flow.
    ///
    /// - Parameter viewController: Optional view controller to present the sign-in UI from
    /// - Returns: The Google Sign-In result containing user information and tokens
    @MainActor
    func signIn(viewController: UIViewController? = nil) async throws -> GoogleSignInResult
    {
        guard let topViewController = viewController ?? UIApplication.topViewController()
        else
        {
            throw GoogleSignInError.noViewController
        }

        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topViewController)

        guard let result = GoogleSignInResult(result: gidSignInResult)
        else
        {
            throw GoogleSignInError.badResponse
        }

        return result
    }

    /// Errors that can occur during Google Sign-In.
    private enum GoogleSignInError: LocalizedError
    {
        case noViewController
        case badResponse

        var errorDescription: String?
        {
            switch self
            {
                case .noViewController:
                    return "Could not find top view controller."
                case .badResponse:
                    return "Google Sign In had a bad response."
            }
        }
    }
}
