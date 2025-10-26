import Foundation

extension String
{
    /// Check whether a string is empty or consists of only white spaces
    ///
    /// - Returns:
    ///     - Whether the string is empty or consists of only white spaces
    func isEmptyOrWhitespace() -> Bool
    {
        return trimmingCharacters(in: .whitespaces).isEmpty
    }
}
