import SwiftUI

struct GraphSheetView: View {
	@Environment(\.dismiss) private var dismiss
	@State private var selectedRange = "day"

	var body: some View {
		NavigationStack {
            VStack(spacing: 20) {
                SegmentedControl(
                    selection: $selectedRange,
                    accessibilityLabel: "Graph range",
                    "day",
                    "month",
                    "year"
                )
                
                // TODO: isi graph sheet
                Text("ini nanti diisi ya")
                
                Spacer()
            }
			.padding(20)
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button("Done") {
						dismiss()
					}
				}
			}
		}
	}

}
#Preview {
	GraphSheetView()
}
