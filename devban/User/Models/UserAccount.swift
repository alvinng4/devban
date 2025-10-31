import SwiftUI
import Foundation

struct UserAccount: Codable, Identifiable {
    var id = UUID()
    var username: String
    var password: String
}