import SwiftUI

/// View modifier that conditionally makes a view draggable.
private struct CustomDraggableViewModifier: ViewModifier
{
    let isDraggable: Bool
    let transferString: String
    func body(content: Content) -> some View
    {
        if (isDraggable)
        {
            content
                .draggable(transferString)
        }
        else
        {
            content
        }
    }
}

extension View
{
    /// Conditionally makes a view draggable with a string payload.
    ///
    /// - Parameters:
    ///   - isDraggable: Whether the view should be draggable
    ///   - transferString: The string to transfer when dragging
    func customDraggable(isDraggable: Bool, transferString: String) -> some View
    {
        modifier(
            CustomDraggableViewModifier(isDraggable: isDraggable, transferString: transferString),
        )
    }
}
