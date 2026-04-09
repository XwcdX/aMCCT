import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(DashboardViewModel.self) private var viewModel
    @Environment(AppCoordinator.self) private var appCoordinator

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                VStack(spacing: 15) {
                    topBar
                    
                    BrainSceneView(brainLevel: viewModel.brainLevel)
                        .frame(maxWidth: .infinity)
                        .frame(height: geo.size.height * 0.25)
                    
                    statsStrip
                        .padding(.horizontal,20)
                        .onTapGesture {
                            appCoordinator.showGraph()
                        }
                    
                    StoreView()
                        .environment(viewModel)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .onAppear { viewModel.load() }
            }
            .sheet(isPresented: Binding(
                get: { viewModel.isSettingsPresented },
                set: { viewModel.isSettingsPresented = $0 }
            )) {
                SettingsSheet()
                    .environment(viewModel)
            }
            .alert("Decrease level?", isPresented: Binding(
                get: { viewModel.isDecreaseConfirmPresented },
                set: { viewModel.isDecreaseConfirmPresented = $0 }
            )) {
                Button("Decrease", role: .destructive) {
                    viewModel.decreaseLevel()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will lower your actual level by 1. Max 2 decreases per day.")
            }
        }
    }
    
    private var topBar: some View {
        HStack {
            VStack{
                Text("Hardwayyy")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.baseBlacktoWhite)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Your aMCC Brain")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.baseBlacktoWhite)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Spacer()
            
            Button {
                appCoordinator.showSettings()
            } label: {
                Circle()
                    .fill(Color.baseBlacktoWhite)
                    .frame(width: 36, height: 36)
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.baseWhitetoblack)
                    }
                // TODO: swap Circle for equipped profile border asset
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
    
    private var statsStrip: some View {
        HStack(spacing: 0) {
            statCell(
                value: "\(viewModel.brainState?.actualLevel ?? 1)",
                label: "Level",
                accent: .cyan
            )
            
            divider
            
            statCell(
                value: "\(viewModel.totalFrictionsCount)",
                label: "Opened",
                accent: .white.opacity(0.8)
            )
            
            divider
            
            culpritCell(
                tokenData: viewModel.culpritToken,
                label: "Culprit",
                accent: .red.opacity(0.7)
            )
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.baseBlacktoWhite.opacity(0.5))
        )
    }
    
    private func statCell(value: String, label: String, accent: Color) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(accent)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white)
                .textCase(.uppercase)
                .tracking(0.8)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func culpritCell(tokenData: Data?, label: String, accent: Color) -> some View {
        VStack(spacing: 3) {
            if let _ = tokenData {
                // TODO: Decode tokenData into ApplicationToken and use FamilyControls Label()
                // Example: Label(token).labelStyle(.iconOnly)
                Image(systemName: "app.fill")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(accent)
            } else {
                Image(systemName: "app.dashed")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(accent.opacity(0.5))
            }
            
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.45))
                .textCase(.uppercase)
                .tracking(0.8)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var divider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.1))
            .frame(width: 1, height: 32)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: BrainState.self, StoreItem.self, FrictionEvent.self,
        configurations: config
    )

    let viewModel = DashboardViewModel(modelContext: container.mainContext)
    viewModel.load()
    
    let coordinator = AppCoordinator()

    return DashboardView()
        .environment(viewModel)
        .environment(coordinator)
        .modelContainer(container)
}
