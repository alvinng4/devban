import SwiftUI
import Foundation
import Combine
import Security


class UserAuthViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String? = nil

    init() {}

    func login() {
        guard !username.isEmpty && !password.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }

        if let credentials = readFromKeychain(username: username),
           let savedUser = decodeUserAccount(from: credentials) {
            if savedUser.password == password {
                isLoggedIn = true
                errorMessage = nil
            } else {
                errorMessage = "Invalid username or password."
            }
        } else {
            errorMessage = "No account found. Please register."
        }
    }

func registerToKeychain(confirmPassword: String) -> Bool {
    guard !username.isEmpty && !password.isEmpty else {
        errorMessage = "Please fill in all fields."
        return false
    }

    guard password == confirmPassword else {
        errorMessage = "Passwords do not match."
        return false
    }

    let newUser = UserAccount(username: username, password: password)
    guard let encoded = try? JSONEncoder().encode(newUser),
          let encodedString = String(data: encoded, encoding: .utf8),
          let data = encodedString.data(using: .utf8) else {
        errorMessage = "Failed to encode user data."
        return false
    }

    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: username,
        kSecValueData as String: data
    ]

    SecItemDelete(query as CFDictionary)

    let status = SecItemAdd(query as CFDictionary, nil)
    if status == errSecSuccess {
        errorMessage = nil
        return true
    } else {
        errorMessage = "Failed to save to Keychain: \(status)"
        return false
    }
}

    func logout() {
        isLoggedIn = false
    }

    private func saveToKeychain(username: String, passwordData: String) {
        let data = passwordData.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func readFromKeychain(username: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject? = nil
        if SecItemCopyMatching(query as CFDictionary, &dataTypeRef) == noErr {
            if let data = dataTypeRef as? Data,
               let credentials = String(data: data, encoding: .utf8) {
                return credentials
            }
        }
        return nil
    }

    private func decodeUserAccount(from string: String) -> UserAccount? {
        guard let data = string.data(using: .utf8),
              let user = try? JSONDecoder().decode(UserAccount.self, from: data) else {
            return nil
        }
        return user
    }
}