import Foundation

enum ISBNValidator {
    static func isValidOptional(_ value: String) -> Bool {
        let normalized = normalize(value)
        return normalized.isEmpty || isValid(normalized)
    }

    static func isValid(_ value: String) -> Bool {
        let isbn = normalize(value)

        switch isbn.count {
        case 10:
            return isValidISBN10(isbn)
        case 13:
            return isValidISBN13(isbn)
        default:
            return false
        }
    }

    static func normalize(_ value: String) -> String {
        value.uppercased().filter { $0.isNumber || $0 == "X" }
    }

    private static func isValidISBN10(_ isbn: String) -> Bool {
        let characters = Array(isbn)
        guard characters.dropLast().allSatisfy(\.isNumber) else { return false }

        let sum = characters.enumerated().reduce(0) { partial, element in
            let digit: Int
            if element.offset == 9, element.element == "X" {
                digit = 10
            } else {
                digit = Int(String(element.element)) ?? -100
            }
            return partial + digit * (10 - element.offset)
        }
        return sum % 11 == 0
    }

    private static func isValidISBN13(_ isbn: String) -> Bool {
        guard isbn.allSatisfy(\.isNumber) else { return false }
        let sum = isbn.enumerated().reduce(0) { partial, element in
            partial + (Int(String(element.element)) ?? 0) * (element.offset.isMultiple(of: 2) ? 1 : 3)
        }
        return sum % 10 == 0
    }
}
