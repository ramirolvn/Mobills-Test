import UIKit
import Foundation

class CurrencyField: UITextField {
    var string: String { return text ?? "" }
    var decimal: Decimal {
        return string.decimal /
            pow(10, Formatter.currency.maximumFractionDigits)
    }
    var decimalNumber: NSDecimalNumber { return decimal.number }
    var doubleValue: Double { return decimalNumber.doubleValue }
    var integerValue: Int { return decimalNumber.intValue   }
    let maximum: Decimal = 999_999_999.99
    private var lastValue: String?
    override func willMove(toSuperview newSuperview: UIView?) {
        // you can make it a fixed locale currency if needed
         Formatter.currency.locale = Locale(identifier: "pt_BR")
        addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        keyboardType = .numberPad
        textAlignment = .center
        editingChanged(self)
    }
    override func deleteBackward() {
        text = String(string.digits.dropLast())
        editingChanged(self)
    }
    @objc func editingChanged(_ textField: UITextField) {
        guard decimal <= maximum else {
            text = lastValue
            return
        }
        text = Formatter.currency.string(for: decimal)
        lastValue = text
    }
}
