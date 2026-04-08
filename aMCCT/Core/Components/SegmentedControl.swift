import SwiftUI

struct SegmentedControl<Option: Hashable>: View {
    @Binding var selection: Option

    let options: [Option]
    let title: (Option) -> String
    var accessibilityLabel: String = "Category"

    init(
        selection: Binding<Option>,
        options: [Option],
        accessibilityLabel: String = "Category",
        title: @escaping (Option) -> String
    ) {
        self._selection = selection
        self.options = options
        self.accessibilityLabel = accessibilityLabel
        self.title = title
    }

    init(
        selection: Binding<Option>,
        accessibilityLabel: String = "Category",
        title: @escaping (Option) -> String,
        _ options: Option...
    ) {
        self.init(
            selection: selection,
            options: options,
            accessibilityLabel: accessibilityLabel,
            title: title
        )
    }

    var body: some View {
        Picker("", selection: $selection) {
            ForEach(options, id: \.self) { option in
                Text(title(option)).tag(option)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityLabel(accessibilityLabel)
    }
}

extension SegmentedControl where Option: RawRepresentable, Option.RawValue == String {
    init(
        selection: Binding<Option>,
        accessibilityLabel: String = "Category",
        _ options: Option...
    ) {
        self.init(
            selection: selection,
            options: options,
            accessibilityLabel: accessibilityLabel,
            title: { $0.rawValue.capitalized }
        )
    }
}

extension SegmentedControl where Option == String {
    init(
        selection: Binding<String>,
        accessibilityLabel: String = "Category",
        _ options: String...
    ) {
        self.init(
            selection: selection,
            options: options,
            accessibilityLabel: accessibilityLabel,
            title: { $0.capitalized }
        )
    }
}
