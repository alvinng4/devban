import SwiftUI

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
    func customDraggable(isDraggable: Bool, transferString: String) -> some View
    {
        modifier(
            CustomDraggableViewModifier(isDraggable: isDraggable, transferString: transferString),
        )
    }
}
