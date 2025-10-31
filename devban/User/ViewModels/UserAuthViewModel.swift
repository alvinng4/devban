import SwiftUI
import Foundation
import Combine

class UserAuthViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String? = nil

    private let userKey = "storedUser"

    init() {
        if let data = UserDefaults.standard.data(forKey: userKey),
           let savedUser = try? JSONDecoder().decode(UserAccount.self, from: data) {
            self.username = savedUser.username
            self.isLoggedIn = true
        }
    }

    func login() {
        guard !username.isEmpty && !password.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }

        if let data = UserDefaults.standard.data(forKey: userKey),
           let savedUser = try? JSONDecoder().decode(UserAccount.self, from: data) {
            if savedUser.username == username && savedUser.password == password {
                isLoggedIn = true
                errorMessage = nil
            } else {
                errorMessage = "Invalid username or password."
            }
        } else {
            errorMessage = "No account found. Please register."
        }
    }

    func register() {
        guard !username.isEmpty && !password.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }

        let newUser = UserAccount(username: username, password: password)
        if let encoded = try? JSONEncoder().encode(newUser) {
            UserDefaults.standard.set(encoded, forKey: userKey)
            isLoggedIn = true
            errorMessage = nil
        }
    }


    func logout() {
        isLoggedIn = false
    }
}