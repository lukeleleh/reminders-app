import SwiftUI

struct IconToggleRow: View {
    let icon: String
    let label: String
    let toggleBinding: Binding<Bool>

    public var body: some View {
        HStack {
            Label {
                Text(label)
            } icon: {
                Text(icon)
            }
            Spacer()
            Toggle("", isOn: toggleBinding)
        }
        .padding(4)
    }
}

struct IconToggleRow_Previews: PreviewProvider {
    static var previews: some View {
        IconToggleRow(icon: "🗓", label: "Date", toggleBinding: .constant(true))
            .previewLayout(.sizeThatFits)
    }
}
