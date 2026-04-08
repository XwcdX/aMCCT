import SwiftUI

struct CloseButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark.circle.fill")
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundColor(Color(UIColor.systemGray4))
        }
    }
}

// MARK: - Preview
#Preview {
    CloseButton(action: {
        print("Close button tapped")
    })
}
