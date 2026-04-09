import SwiftUI

struct FrictionCard<Content: View>: View {
    var title: String
    var progress: Double
    var currentLevel: Int
    var backgroundImageName: String?
    var onCancel: () -> Void
    @ViewBuilder var content: Content
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                Text(title)
                    .font(.system(size: 28, weight: .black))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundStyle(.baseBlacktoWhite)
                    .padding(.top, 80)
                    .padding(.horizontal, 24)
                
                Text("Difficulty Level: \(currentLevel)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
                
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
        .background(
            Group {
                if let bgImage = backgroundImageName {
                    Image(bgImage)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea(.all)
                        .overlay(
                            (colorScheme == .dark ? Color.black : Color.white)
                                .opacity(0.65)
                                .ignoresSafeArea(.all)
                        )
                } else {
                    Color.clear
                        .background(.baseWhitetoblack)
                        .ignoresSafeArea(.all)
                }
            }
            .ignoresSafeArea(.all)
        )
    }
}

#Preview {
    FrictionCard(
        title: "FOLLOW THE MOVING BUTTON!",
        progress: 0.35,
        currentLevel: 1,
        backgroundImageName: "Wallpaper-1",
        onCancel: {
            print("User gave up. Redirect to Home Screen.")
        }
    ) {
        Circle()
            .fill(Color.secondary.opacity(0.2))
            .frame(width: 90, height: 90)
    }
}
