import SwiftUI

struct DevbanUser: Codable
{
    var uid: String
    var preferredColorScheme: ThemeManager.PreferredColorScheme
    var theme: ThemeManager.DefaultTheme
}
