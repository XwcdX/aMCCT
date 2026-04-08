import SwiftUI

struct FrictionCard<Content: View>: View {
    var title: String
    var progress: Double
    var onCancel: () -> Void
    @ViewBuilder var content: Content
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text(title)
                    .font(.system(size: 28, weight: .black))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 80)
                    .padding(.horizontal, 24)
                
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            HStack {
                CloseButton(action: onCancel)
                
                Spacer()
                
                ProgressRing(progress: progress)
                    .frame(width: 32, height: 32)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview
#Preview {
    FrictionCard(
        title: "FOLLOW THE MOVING BUTTON!",
        progress: 0.35,
        onCancel: {
            print("User gave up. Redirect to Home Screen.")
        }
    ) {
        Circle()
            .fill(Color(UIColor.systemGray4))
            .frame(width: 90, height: 90)
    }
}
