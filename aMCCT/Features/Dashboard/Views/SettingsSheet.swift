import SwiftUI
import SharedKit
import FamilyControls

struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selection = FamilyActivitySelection()
    private let tokenStore = SharedTokenStore()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text("Select the apps or categories you want to shield. You'll need to complete a task to open them.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                    .multilineTextAlignment(.center)
                FamilyActivityPicker(selection: $selection)
            }
            .navigationTitle("Shielded Apps")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        handleSave()
                    }
                    .fontWeight(.bold)
                }
            }
            .onAppear {
                selection = tokenStore.load()
            }
        }
    }

    private func handleSave() {
        do {
            try tokenStore.save(selection)
            print("Successfully saved \(selection.applications.count) apps and \(selection.categories.count) categories.")
            
            dismiss()
        } catch {
            print("Failed to save selection: \(error)")
        }
    }
}
