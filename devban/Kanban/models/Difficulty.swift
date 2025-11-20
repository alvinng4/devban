import SwiftUI

extension DevbanTask
{
    enum Difficulty: String, Identifiable, Codable, CaseIterable, Comparable
    {
        case veryEasy
        case easy
        case normal
        case hard
        case veryHard

        var id: String
        {
            return self.rawValue
        }

        var description: String
        {
            switch self
            {
                case .veryEasy:
                    return "Very easy"
                case .easy:
                    return "Easy"
                case .normal:
                    return "Normal"
                case .hard:
                    return "Hard"
                case .veryHard:
                    return "Very hard"
            }
        }

        static func descriptionToDifficulty(_ description: String) -> Difficulty?
        {
            switch (description)
            {
                case "Very easy":
                    return Difficulty.veryEasy
                case "Easy":
                    return Difficulty.easy
                case "Normal":
                    return Difficulty.normal
                case "Hard":
                    return Difficulty.hard
                case "Very hard":
                    return Difficulty.veryHard
                default:
                    return nil
            }
        }

        static func < (lhs: Difficulty, rhs: Difficulty) -> Bool
        {
            return getRelativeValue(lhs) < getRelativeValue(rhs)

            func getRelativeValue(_ difficulty: Difficulty) -> Int
            {
                switch (difficulty)
                {
                    case .veryEasy:
                        return 0
                    case .easy:
                        return 1
                    case .normal:
                        return 2
                    case .hard:
                        return 3
                    case .veryHard:
                        return 4
                }
            }
        }

        func getColor() -> Color
        {
            switch (self)
            {
                case .veryEasy:
                    return Color(#colorLiteral(red: 0.6783362285, green: 0.8862745166, blue: 0.3454386221, alpha: 1))
                case .easy:
                    return Color.green
                case .normal:
                    return Color.yellow
                case .hard:
                    return Color.red
                case .veryHard:
                    return Color(red: 0.7584043561, green: 0.02838634908, blue: 0)
            }
        }

        func getExp() -> Int
        {
            switch (self)
            {
                case .veryEasy:
                    return 5
                case .easy:
                    return 10
                case .normal:
                    return 20
                case .hard:
                    return 40
                case .veryHard:
                    return 80
            }
        }

        /// For slider
        func getDifficultyValue() -> Double
        {
            switch (self)
            {
                case .veryEasy:
                    return 0.0
                case .easy:
                    return 1.0
                case .normal:
                    return 2.0
                case .hard:
                    return 3.0
                case .veryHard:
                    return 4.0
            }
        }
    }
}
