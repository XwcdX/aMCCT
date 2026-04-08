import SwiftUI

struct PermissionRequestView: View {
    var onAuthorized: () -> Void
    @State private var viewModel: OnboardingViewModel
    
    init(service: any ScreenTimeServicing, onAuthorized: @escaping () -> Void) {
        self.onAuthorized = onAuthorized
        self._viewModel = State(initialValue: OnboardingViewModel(screenTimeService: service))
    }

    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "shield.checkered")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            
            VStack(spacing: 12) {
                Text("Enable Protection")
                    .font(.title.bold())
                    .foregroundStyle(.white)
                
                Text("aMCCT needs permission to shield distracting apps. This data never leaves your device.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            if let errorMessage = viewModel.error {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            ActionButton(
                viewModel.isAuthorizing ? "Authorizing..." : "Grant Access",
                icon: "lock.fill",
                color: .blue,
                shape: .capsule,
                isFullWidth: true,
                isEnabled: !viewModel.isAuthorizing
            ) {
                Task {
                    let success = await viewModel.authorize()
                    if success {
                        onAuthorized()
                    }
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
        }
        .background(Color.black.ignoresSafeArea())
    }
}
