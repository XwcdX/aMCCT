import SwiftUI

struct SettingsSheet: View {
    @Environment(DashboardViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("App Selection") {
                    Button("Change blocked apps") {
                        // TODO: present FamilyActivityPicker
                    }
                }

                Section("Account") {
                    // TODO: profile border picker
                    Text("Profile border")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
