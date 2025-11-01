import SwiftUI

extension Image
{
    /// Modifies a image to look like a tool bar button.
    ///
    /// - Parameters:
    ///     - width: Width of the image.
    ///     - height: Height of the image.
    ///     - padding: Padding of the image.
    func toolBarButtonImage(width: CGFloat = 24, height: CGFloat = 24, padding: CGFloat = 6.0) -> some View
    {
        return self
            .resizable()
            .scaledToFit()
            .frame(
                width: width,
                height: height,
                alignment: .center,
            )
            .padding(padding)
            .tint(.black)
    }

    /// Modifies a image to look like a tool bar button for text editor.
    ///
    /// - Parameters:
    ///     - width: Width of the image.
    ///     - height: Height of the image.
    func textEditorToolBarButtonImage(width: CGFloat = 18.0, height: CGFloat = 18.0) -> some View
    {
        return self
            .resizable()
            .scaledToFit()
            .frame(
                width: width,
                height: height,
                alignment: .center,
            )
            .tint(.black)
    }
}
