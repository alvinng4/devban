import SwiftUI

extension View
{
    /// Perform action when back swipe gesture is detected (i.e. swiping right)
    ///
    /// - Parameter action: The action to be performed.
    func onBackSwipe(perform action: @escaping () -> Void) -> some View
    {
        gesture(
            DragGesture()
                .onEnded(
                    { value in
                        if value.startLocation.x < 50, value.translation.width > 80
                        {
                            action()
                        }
                    },
                ),
        )
    }
}
