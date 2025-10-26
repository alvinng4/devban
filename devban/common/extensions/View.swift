import Foundation

extension String
{
    func isEmptyOrWhitespace() -> Bool
    {
        return trimmingCharacters(in: .whitespaces).isEmpty
    }
}
