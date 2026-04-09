import SwiftUI

struct GraphSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = GraphSheetViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // MARK: brain level graph
                    GraphSummaryView(
                        average: viewModel.currentBrainLevelAverage,
                        periodLabel: viewModel.periodLabel
                    )

                    GraphRangeSelectorView(
                        selection: Binding(
                            get: { viewModel.selectedRange },
                            set: { viewModel.selectedRange = $0 }
                        )
                    )

                    GraphChartSectionView(
                        points: viewModel.currentBrainLevelPoints,
                        selectedRange: viewModel.selectedRange,
                        currentAverage: viewModel.currentBrainLevelAverage,
                        title: viewModel.brainChartTitle,
                        subtitle: viewModel.brainChartSubtitle,
                        yAxisLabel: "Brain Level",
                        yValueLabel: "Brain Level",
                        yDomain: 0...100,
                        lineColors: [.cyan, .mint],
                        chartStyle: .bar,
                        showWeeklyAverageLine: true,
                        weeklyAverageLabel: "Weekly brain average",
                        onPointSelected: { point in
                            viewModel.selectBrainPoint(point)
                        }
                    )

                    if viewModel.selectedRange == .week {
                        GraphWeeklyAverageLegendView(average: viewModel.currentBrainLevelAverage)
                    }

                    GraphSelectedPointView(selectedPoint: viewModel.selectedBrainPoint)

                    // MARK: shield graph
                    GraphChartSectionView(
                        points: viewModel.currentShieldOpenPoints,
                        selectedRange: viewModel.selectedRange,
                        currentAverage: viewModel.currentShieldOpenAverage,
                        title: viewModel.shieldChartTitle,
                        subtitle: viewModel.shieldChartSubtitle,
                        yAxisLabel: "Open Count",
                        yValueLabel: "Open Count",
                        yDomain: 0...viewModel.shieldChartMaxY,
                        lineColors: [.orange, .pink],
                        chartStyle: .area,
                        showWeeklyAverageLine: false,
                        weeklyAverageLabel: "",
                        onPointSelected: { point in
                            viewModel.selectShieldPoint(point)
                        }
                    )

                    GraphSelectedPointView(selectedPoint: viewModel.selectedShieldPoint)
                    
                    // MARK: culprit apps
                    GraphCulpritAppsView(apps: viewModel.culpritApps)
                    
                    // MARK: about amcc
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
