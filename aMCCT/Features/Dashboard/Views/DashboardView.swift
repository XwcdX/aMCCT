import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(DashboardViewModel.self) private var viewModel
    @Environment(AppCoordinator.self) private var appCoordinator
    @State private var isHintsPresented: Bool = false

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
                    
//                    #if DEBUG
//                    ActionButton(
//                        "Debug +1",
//                        icon: "plus.circle.fill",
//                        color: .orange,
//                        shape: .capsule,
//                        size: .compact,
//                        isFullWidth: false
//                    ) {
//                        viewModel.debugIncrementLevel()
//                    }
//                    .padding(.top, 4)
//
//                    ActionButton(
//                        "Reset SwiftData",
//                        icon: "trash.fill",
//                        color: .red,
//                        shape: .capsule,
//                        size: .compact,
//                        isFullWidth: false
//                    ) {
//                        viewModel.resetSwiftData()
//                    }
//
//                    debugLevelStatus
//                    #endif
                    
                    
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
            .sheet(isPresented: $isHintsPresented) {
                HintsView()
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
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Hardwayyy")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.baseBlacktoWhite)
                    
                    Text("Your aMCC Brain")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.baseBlacktoWhite)
                }
                
                Button {
                    isHintsPresented = true
                } label: {
                    Image(systemName: "questionmark.circle")
                        .foregroundStyle(.baseBlacktoWhite)
                        .font(.system(size: 18))
                }
                .buttonStyle(.plain)
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

    #if DEBUG
    private var debugLevelStatus: some View {
        let state = viewModel.brainState

        return VStack(alignment: .leading, spacing: 6) {
            Text("Debug level state")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
                .textCase(.uppercase)
                .tracking(0.8)

            Text("actual: \(state?.actualLevel ?? 1)  current: \(state?.currentLevel ?? 1)" )
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundStyle(.white)

            Text(viewModel.dailyCapsDescription)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 2)
    }
    #endif
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
