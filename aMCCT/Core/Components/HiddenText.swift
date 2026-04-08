import SwiftUI

struct HiddenText: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFocused: Bool
    
    var maxLength: Int
    var disableBackspace: Bool

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()

        textField.textColor = .clear
        textField.tintColor = .clear
        textField.backgroundColor = .clear

        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.smartQuotesType = .no
        textField.smartDashesType = .no
        textField.smartInsertDeleteType = .no
        textField.autocapitalizationType = .none
        
        textField.keyboardType = .asciiCapable

        textField.inputAssistantItem.leadingBarButtonGroups = []
        textField.inputAssistantItem.trailingBarButtonGroups = []

        textField.delegate = context.coordinator
        
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textDidChange(_:)), for: .editingChanged)

        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }

        if isFocused && !uiView.isFirstResponder {
            DispatchQueue.main.async { uiView.becomeFirstResponder() }
        } else if !isFocused && uiView.isFirstResponder {
            DispatchQueue.main.async { uiView.resignFirstResponder() }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: HiddenText

        init(_ parent: HiddenText) {
            self.parent = parent
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
            if parent.disableBackspace && string.isEmpty && range.length > 0 {
                return false
            }
            
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            
            if updatedText.count > parent.maxLength {
                return false
            }
            
            return true
        }

        @objc func textDidChange(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.parent.text = textField.text ?? ""
            }
        }
    }
}
