// dashboard view

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(DashboardViewModel.self) private var viewModel

    var body: some View {
        GeometryReader { geo in
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                
                BrainSceneView(strength: viewModel.brainStrength)
                    .frame(maxWidth: .infinity)
                    .frame(height: geo.size.height * 0.42)

                statsStrip
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                
//                levelControls
//                    .padding(.horizontal, 20)
//                    .padding(.top, 16)
                
//                StoreView()
//                    .environment(viewModel)
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .onAppear { viewModel.load() }
        }
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

    private var topBar: some View {
        HStack {
            VStack{
                Text("Hardway")
                    .font(.system(size: 25, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            
                Text("Your aMCC Brain")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            }

            Spacer()
            
            Button {
                viewModel.isSettingsPresented = true
            } label: {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 36, height: 36)
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.white.opacity(0.8))
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
                value: "\(viewModel.brainState?.actualLevel ?? 0)",
                label: "Level",
                accent: .cyan
            )

            divider

            statCell(
                value: "\(viewModel.brainState?.currentLevel ?? 0)",
                label: "Current",
                accent: .white.opacity(0.6)
            )

            divider

            statCell(
                value: "\(viewModel.brainState?.currentStreak ?? 0)",
                label: "Streak",
                accent: .orange
            )

            divider

            statCell(
                value: "\(viewModel.brainState?.spendablePoints ?? 0)",
                label: "Points",
                accent: .yellow
            )
        }
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.07))
        )
    }

    private func statCell(value: String, label: String, accent: Color) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(accent)
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

    private var levelControls: some View {
        VStack(spacing: 10) {
            levelProgressBar

            HStack(spacing: 12) {
                Button {
                    viewModel.isDecreaseConfirmPresented = true
                } label: {
                    Label("Decrease level", systemImage: "minus.circle")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.red.opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.red.opacity(0.1))
                        )
                }
                .disabled(!(viewModel.canDecreaseToday))

                Button {
                    viewModel.debugIncrementLevel()
                } label: {
                    Label("Add level (dev)", systemImage: "plus.circle")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.green.opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.green.opacity(0.1))
                        )
                }
            }

            HStack(spacing: 4) {
                Image(systemName: "info.circle")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.3))
                Text(viewModel.dailyCapsDescription)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
    }

    private var levelProgressBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Current → Actual")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
                    .textCase(.uppercase)
                    .tracking(0.6)
                Spacer()
                Text("\(viewModel.brainState?.currentLevel ?? 0) / \(viewModel.brainState?.actualLevel ?? 0)")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.cyan.opacity(0.35))
                        .frame(
                            width: geo.size.width * viewModel.actualLevelFraction,
                            height: 6
                        )

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.cyan, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geo.size.width * viewModel.currentLevelFraction,
                            height: 6
                        )
                }
            }
            .frame(height: 6)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: BrainState.self, configurations: config)

    let viewModel = DashboardViewModel(modelContext: container.mainContext)
    viewModel.load()

    return DashboardView()
        .environment(viewModel)
        .modelContainer(container)
}
