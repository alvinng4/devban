import SwiftUI

extension View
{
    /// Modifies a Text View to obtain a consistent title look throughout the application.
    ///
    /// - Returns: modified View.
    ///
    /// ## Usage
    /// ```swift
    /// VStack(spacing: 10)
    /// {
    ///     Text("This is a title")
    ///         .customTitle()
    ///
    ///     // Other contents
    /// }
    /// ```
    func customTitle() -> some View
    {
        modifier(
            CustomTitleViewModifier(),
        )
    }
}

private struct CustomTitleViewModifier: ViewModifier
{
    func body(content: Content) -> some View
    {
        content
            .font(.system(size: 30, weight: .bold, design: .rounded))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, -5)
            .padding(.top, 5)
    }
}
