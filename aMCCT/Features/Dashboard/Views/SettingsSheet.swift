import SwiftUI

struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Mock State for UI
    // Your teammate will eventually replace these with the real ScreenTime data model
    @State private var entTiktok = true
    @State private var entInstagram = true
    @State private var entX = true
    @State private var entThreads = true
    @State private var entYoutube1 = false
    @State private var entMobileLegends = false
    @State private var entSpotify = false
    @State private var entYoutube2 = false
    
    @State private var socTiktok = true
    @State private var socInstagram = true
    @State private var socX = true
    @State private var socThreads = true

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Tiktok", isOn: $entTiktok)
                    Toggle("Instagram", isOn: $entInstagram)
                    Toggle("X", isOn: $entX)
                    Toggle("Threads", isOn: $entThreads)
                    Toggle("Youtube", isOn: $entYoutube1)
                    Toggle("Mobile Legends", isOn: $entMobileLegends)
                    Toggle("Spotify", isOn: $entSpotify)
                    Toggle("Youtube", isOn: $entYoutube2)
                } header: {
                    Text("Entertainment")
                        .textCase(nil)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section {
                    Toggle("Tiktok", isOn: $socTiktok)
                    Toggle("Instagram", isOn: $socInstagram)
                    Toggle("X", isOn: $socX)
                    Toggle("Threads", isOn: $socThreads)
                } header: {
                    Text("Social")
                        .textCase(nil)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .listStyle(.grouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .buttonBorderShape(.capsule)
                    .controlSize(.regular)
                }
            }
        }
    }
}

#Preview {
    SettingsSheet()
}
