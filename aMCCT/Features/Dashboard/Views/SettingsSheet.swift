import SwiftUI
import SharedKit
import FamilyControls

struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppEnvironment.self) private var appEnvironment
    
    @State private var selection = FamilyActivitySelection()
    @State private var preventDeletion = false
    
    private let tokenStore = SharedTokenStore()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text("Select the apps or categories you want to shield. You'll need to complete a task to open them.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Prevent App Deletion")
                                .font(.body)
                            Text("Stop yourself from deleting apps to bypass shields")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $preventDeletion)
                            .labelsHidden()
                            .tint(.blue)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
                FamilyActivityPicker(selection: $selection)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Protection Rules")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { handleSave() }
                    .fontWeight(.bold)
                }
            }
            .onAppear {
                selection = tokenStore.load()
                preventDeletion = tokenStore.loadDeletionContext()
            }
        }
    }

    private func handleSave() {
        do {
            try tokenStore.save(selection)
            tokenStore.saveDeletionContext(prevent: preventDeletion)
            Task {
                try? await appEnvironment.shieldService.applyShields(to: selection)
            }
            dismiss()
        } catch {
            print("Save failed: \(error)")
        }
    }
}
