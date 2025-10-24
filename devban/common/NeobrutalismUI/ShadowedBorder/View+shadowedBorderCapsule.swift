import SwiftUI

extension View
{
    /// Modifies the view with a shadowed border effect with capsule shape, and a background depending on the
    /// environment colorScheme
    ///
    /// - Parameters:
    ///     - borderColor: Color of the border.
    ///     - borderWidth: Width of the border.
    ///     - shadowColor: Color of the shadow.
    ///     - shadowOffset; x and y offset of the applied shadow effect.
    ///
    /// - Returns: modified View
    ///
    /// ## Usage
    /// ```swift
    /// Text("Hello, world!")
    ///     .padding()
    ///     .frame(maxWidth: .infinity)
    ///     .shadowedBorderCapsule()
    /// ```
    func shadowedBorderCapsule(
        borderColor: Color = NeobrutalismConstants.borderColor,
        borderWidth: CGFloat = NeobrutalismConstants.borderWidth,
        shadowColor: Color = NeobrutalismConstants.shadowColor,
        shadowOffset: CGSize = NeobrutalismConstants.shadowOffset
    ) -> some View
    {
        modifier(
            ShadowedBorderCapsuleModifier(
                borderColor: borderColor,
                borderWidth: borderWidth,
                shadowColor: shadowColor,
                shadowOffset: shadowOffset
            )
        )
    }
}

private struct ShadowedBorderCapsuleModifier: ViewModifier
{
    @Environment(\.colorScheme) private var colorScheme

    let borderColor: Color
    let borderWidth: CGFloat
    let shadowColor: Color
    let shadowOffset: CGSize

    func body(content: Content) -> some View
    {
        content
            .background(colorScheme == .dark ? .darkBackground : .white)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .background(
                Capsule()
                    .foregroundStyle(shadowColor)
                    .offset(shadowOffset)
            )
    }
}
