import SwiftUI

/// A button style with a rounded rectangle shadowed border effect, and an interactive visual effect when pressed. A
/// background is applied depending on the environment colorScheme.
///
/// - Parameters:
///     - cornerRadius: Corner radius for the rounded rectangle border.
///     - borderColor: Color of the border.
///     - borderWidth: Width of the border.
///     - shadowColor: Color of the shadow.
///     - shadowOffset; x and y offset of the applied shadow effect.
///     - stayPressed: Whether the button stay pressed visually.
///
/// ## Usage
/// ```swift
/// Button
/// {
///     print("Added!")
/// }
/// label:
/// {
///     Image(systemName: "plus")
///         .resizable()
///         .scaledToFit()
///         .padding(15)
///         .frame(width: 50, height: 50)
/// }
/// .buttonStyle(ShadowedBorderRoundedRectangleButtonStyle())
/// ```
struct ShadowedBorderRoundedRectangleButtonStyle: PrimitiveButtonStyle
{
    init(
        cornerRadius: CGFloat = NeobrutalismConstants.roundedRectangleCornerRadius,
        borderColor: Color = NeobrutalismConstants.borderColor,
        borderWidth: CGFloat = NeobrutalismConstants.borderWidth,
        shadowColor: Color = NeobrutalismConstants.shadowColor,
        shadowOffset: CGSize = NeobrutalismConstants.shadowOffset,
        stayPressed: Bool = false,
    )
    {
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.shadowColor = shadowColor
        self.shadowOffset = shadowOffset
        self.stayPressed = stayPressed
    }

    @Environment(\.colorScheme) private var colorScheme

    private let cornerRadius: CGFloat
    private let borderColor: Color
    private let borderWidth: CGFloat
    private let shadowColor: Color
    private let shadowOffset: CGSize
    private let stayPressed: Bool

    @GestureState private var isPressed = false

    func makeBody(configuration: Configuration) -> some View
    {
        /// Whether the button appears pressed visually
        let visuallyPressed = stayPressed || isPressed

        /// Determine whether the button action gets triggered by the drag distance
        let drag = DragGesture(minimumDistance: 0)
            .updating($isPressed)
            { _, state, _ in
                state = true
            }
            .onEnded
            { value in
                let dist = hypot(value.translation.width, value.translation.height)
                if (dist < NeobrutalismConstants.dragTolerance)
                {
                    configuration.trigger()
                }
            }

        /// The actual button view
        return configuration.label
            .background(colorScheme == .dark ? .darkBackground : .white)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth),
            )
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundStyle(shadowColor)
                    .offset(visuallyPressed ? CGSize(width: 0, height: 0) : shadowOffset),
            )
            .offset(visuallyPressed ? shadowOffset : CGSize(width: 0, height: 0))
            .animation(
                .easeOut(duration: NeobrutalismConstants.animationDuration),
                value: visuallyPressed,
            )
            .gesture(drag)
    }
}
