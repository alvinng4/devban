import SwiftUI

struct DevbanUser: Codable
{
    var uid: String?
    var email: String?
    var displayName: String?
    var preferredColorScheme: ThemeManager.PreferredColorScheme
    var theme: ThemeManager.DefaultTheme
}
