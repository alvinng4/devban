import SwiftUI

struct ShadowedBorderRoundedRectangleButtonStyle: PrimitiveButtonStyle {
    init(
        cornerRadius: CGFloat = NeobrutalismConstants.roundedRectangleCornerRadius,
        borderColor: Color = NeobrutalismConstants.borderColor,
        borderWidth: CGFloat = NeobrutalismConstants.borderWidth,
        shadowColor: Color = NeobrutalismConstants.shadowColor,
        shadowOffset: CGSize = NeobrutalismConstants.shadowOffset,
        stayPressed: Bool = false
    ) {
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

    func makeBody(configuration: Configuration) -> some View {
        let visuallyPressed = stayPressed || isPressed

        let drag = DragGesture(minimumDistance: 0)
            .updating($isPressed) { _, state, _ in
                state = true
            }
            .onEnded { value in
                let dist = hypot(value.translation.width, value.translation.height)
                if dist < NeobrutalismConstants.dragTolerance {
                    configuration.trigger()
                }
            }

        return configuration.label
            .padding(.horizontal, 20) // 水平內邊距
            .padding(.vertical, 12)   // 垂直內邊距，讓文字完整包住
            .background(colorScheme == .dark ? .darkBackground : .white)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundStyle(shadowColor)
                    .offset(visuallyPressed ? CGSize(width: 0, height: 0) : shadowOffset)
            )
            .offset(visuallyPressed ? shadowOffset : CGSize(width: 0, height: 0))
            .animation(
                .easeOut(duration: NeobrutalismConstants.animationDuration),
                value: visuallyPressed
            )
            .gesture(drag)
    }
}