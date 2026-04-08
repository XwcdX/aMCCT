import SwiftUI

struct ProgressRing: View {
    var progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 5)
                .opacity(0.3)
                .foregroundColor(Color(UIColor.systemGray4))
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                .foregroundColor(.black)
                .rotationEffect(Angle(degrees: 270.0))
        }
    }
}

// MARK: - ProgressRing Preview
#Preview() {
    HStack(spacing: 40) {
        VStack {
            ProgressRing(progress: 0.1)
                .frame(width: 50, height: 50)
            Text("10%")
                .font(.caption)
                .foregroundColor(.gray)
        }
        
        VStack {
            ProgressRing(progress: 0.5)
                .frame(width: 50, height: 50)
            Text("50%")
                .font(.caption)
                .foregroundColor(.gray)
        }
        
        VStack {
            ProgressRing(progress: 1.0)
                .frame(width: 50, height: 50)
            Text("100%")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
    .padding()
}
