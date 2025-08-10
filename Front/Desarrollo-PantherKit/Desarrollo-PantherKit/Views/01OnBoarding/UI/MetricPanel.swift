import SwiftUI

struct MetricPanel: View {
    let label: String
    let value: String
    let unit: String?

    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(AppTheme.Space.spaceCaption(10))
                .foregroundColor(AppTheme.Colors.spaceGray)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(AppTheme.Space.spaceMetric(32))
                    .foregroundColor(AppTheme.Colors.spacePureWhite)
                if let unit = unit { Text(unit).font(AppTheme.Space.spaceCaption(10)).foregroundColor(AppTheme.Colors.spaceGray) }
            }
        }
    }
}


