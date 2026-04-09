import SwiftUI

struct ActionButton: View {
    enum ButtonShape {
        case roundedSquare
        case capsule
    }
    
    let title: String?
    let icon: String?
    let color: Color
    let isEnabled: Bool
    let isFullWidth: Bool
    let shape: ButtonShape
    let action: () -> Void

    init(
        _ title: String? = nil,
        icon: String? = nil,
        color: Color = .blue,
        shape: ButtonShape = .roundedSquare,
        isFullWidth: Bool = true,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.shape = shape
        self.isFullWidth = isFullWidth
        self.isEnabled = isEnabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                if let title = title {
                    Text(title)
                        .fontWeight(.semibold)
                }
            }
            .font(.body)
            .padding(.vertical, 14)
            .padding(.horizontal, 24)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(minWidth: (title == nil) ? 50 : nil)
            .background(color)
            .foregroundColor(.white)
            .clipShape(currentShape)
            .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ActionButtonStyle())
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.5)
    }

    private var currentShape: AnyShape {
        switch shape {
        case .roundedSquare:
            return AnyShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        case .capsule:
            if title == nil {
                return AnyShape(Circle())
            } else {
                return AnyShape(Capsule())
            }
        }
    }
}
struct ActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 30) {
            VStack(alignment: .center, spacing: 10) {
                Text("1. FULL WIDTH PILL").font(.caption).foregroundColor(.gray)
                ActionButton("Continue Task", icon: "arrow.right", color: .blue, shape: .capsule, isFullWidth: true) {
                    print("Full width pill")
                }
            }
            
            VStack(alignment: .center, spacing: 10) {
                Text("2. COMPACT PILL (Word Length)").font(.caption).foregroundColor(.gray)
                ActionButton("Unlock", icon: "lock.open.fill", color: .green, shape: .capsule, isFullWidth: false) {
                    print("Hugs word length")
                }
            }
            
            VStack(alignment: .center, spacing: 10) {
                Text("3. SQUARE FULL WIDTH").font(.caption).foregroundColor(.gray)
                ActionButton("Save Settings", color: .purple, shape: .roundedSquare, isFullWidth: true) {
                    print("Square corner")
                }
            }
            
            HStack(spacing: 20) {
                VStack(alignment: .center, spacing: 10) {
                    Text("4. CIRCLE ICON").font(.caption).foregroundColor(.gray)
                    ActionButton(icon: "xmark", color: .red, shape: .capsule, isFullWidth: false) {
                        print("Perfect circle")
                    }
                }
                
                VStack(alignment: .center, spacing: 10) {
                    Text("5. COMPACT SQUARE").font(.caption).foregroundColor(.gray)
                    ActionButton("Edit", icon: "pencil", color: .orange, shape: .roundedSquare, isFullWidth: false) {
                        print("Small square")
                    }
                }
            }
            
            VStack(alignment: .center, spacing: 10) {
                Text("6. DISABLED STATE").font(.caption).foregroundColor(.gray)
                ActionButton("I'm blocked", color: .blue, isEnabled: false) {}
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
    .background(Color(white: 0.05).ignoresSafeArea())
}
