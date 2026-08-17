import Foundation

enum ISBNBarcodeValidator {
    static func isbn(from barcode: String) -> String? {
        guard barcode.count == 13,
              barcode.allSatisfy(\.isNumber),
              barcode.hasPrefix("978") || barcode.hasPrefix("979")
        else {
            return nil
        }

        return barcode
    }
}
