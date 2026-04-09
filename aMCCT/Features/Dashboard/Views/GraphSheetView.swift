import SwiftUI

struct GraphSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = GraphSheetViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    GraphSheetHeaderView()
                    GraphSummaryView(
                        average: viewModel.currentAverage,
                        periodLabel: viewModel.periodLabel
                    )

                    GraphRangeSelectorView(
                        selection: Binding(
                            get: { viewModel.selectedRange },
                            set: { viewModel.selectedRange = $0 }
                        )
                    )

                    GraphChartSectionView(
                        points: viewModel.currentPoints,
                        selectedRange: viewModel.selectedRange,
                        currentAverage: viewModel.currentAverage,
                        title: viewModel.chartTitle,
                        subtitle: viewModel.chartSubtitle,
                        onPointSelected: { point in
                            viewModel.select(point: point)
                        }
                    )

                    if viewModel.selectedRange == .week {
                        GraphWeeklyAverageLegendView(average: viewModel.currentAverage)
                    }

                    GraphSelectedPointView(selectedPoint: viewModel.selectedPoint)
                    GraphAboutView()
                }
                .padding(20)
            }
            .background(Color.baseWhitetoblack.ignoresSafeArea())
            .navigationTitle("History")
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
