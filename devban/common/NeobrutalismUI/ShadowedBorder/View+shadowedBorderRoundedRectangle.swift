import SwiftUI

extension View
{
    /// Modifies the view with a shadowed border effect with rounded rectangle shape, and a background depending on the
    /// environment colorScheme.
    ///
    /// - Parameters:
    ///     - cornerRadius: Corner radius for the rounded rectangle border.
    ///     - borderColor: Color of the border.
    ///     - borderWidth: Width of the border.
    ///     - shadowColor: Color of the shadow.
    ///     - shadowOffset; x and y offset of the applied shadow effect.
    ///
    /// - Returns: modified View.
    ///
    /// ## Usage
    /// ```swift
    /// Text("Hello, world!")
    ///     .padding()
    ///     .frame(maxWidth: .infinity)
    ///     .shadowedBorderRoundedRectangle()
    /// ```
    func shadowedBorderRoundedRectangle(
        cornerRadius: CGFloat = NeobrutalismConstants.roundedRectangleCornerRadius,
        borderColor: Color = NeobrutalismConstants.borderColor,
        borderWidth: CGFloat = NeobrutalismConstants.borderWidth,
        shadowColor: Color = NeobrutalismConstants.shadowColor,
        shadowOffset: CGSize = NeobrutalismConstants.shadowOffset,
    ) -> some View
    {
        modifier(
            ShadowedBorderRoundedRectangleModifier(
                cornerRadius: cornerRadius,
                borderColor: borderColor,
                borderWidth: borderWidth,
                shadowColor: shadowColor,
                shadowOffset: shadowOffset,
            ),
        )
    }
}

private struct ShadowedBorderRoundedRectangleModifier: ViewModifier
{
    @Environment(\.colorScheme) private var colorScheme

    let cornerRadius: CGFloat
    let borderColor: Color
    let borderWidth: CGFloat
    let shadowColor: Color
    let shadowOffset: CGSize

    func body(content: Content) -> some View
    {
        content
            .background(colorScheme == .dark ? .darkBackground : .white)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth),
            )
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundStyle(shadowColor)
                    .offset(shadowOffset),
            )
    }
}
