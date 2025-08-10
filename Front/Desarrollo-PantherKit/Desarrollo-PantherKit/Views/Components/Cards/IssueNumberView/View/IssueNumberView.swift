import SwiftUI

#if DEBUG
struct IssueNumberView: View {
    @State private var issueNumber: Int = Int.random(in: 1...99)
    var body: some View {
        Text("ISSUE #\(issueNumber)")
            .onAppear {
                if issueNumber <= 0 { issueNumber = Int.random(in: 1...99) }
            }
    }
}
#else
struct IssueNumberView: View {
    private let issueNumber: Int = Int.random(in: 1...99)
    var body: some View { Text("ISSUE #\(issueNumber)") }
}
#endif


