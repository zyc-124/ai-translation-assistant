import SwiftUI

struct SummaryView: View {
    let session: ConversationSession
    @State private var client = AIBackendClient()
    @State private var summary: MeetingSummary?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Button {
                    Task {
                        summary = await client.summarize(session: session)
                    }
                } label: {
                    Label("生成本次总结", systemImage: "doc.text")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                if let summary {
                    SummaryBlock(title: "对话概要", text: summary.overview)
                    SummaryBlock(title: "关键问题", items: summary.questions)
                    SummaryBlock(title: "待办事项", items: summary.actions)
                    SummaryBlock(title: "日语复盘", text: summary.review)
                } else {
                    ContentUnavailableView("还没有总结", systemImage: "doc.text.magnifyingglass", description: Text("点击上方按钮后会生成摘要、问题和待办。"))
                        .padding(.top, 40)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("会后总结")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct SummaryBlock: View {
    let title: String
    var text: String?
    var items: [String]?

    init(title: String, text: String) {
        self.title = title
        self.text = text
    }

    init(title: String, items: [String]) {
        self.title = title
        self.items = items
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            if let text {
                Text(text)
            }
            if let items {
                ForEach(items, id: \.self) { item in
                    Label(item, systemImage: "checkmark.circle")
                        .font(.body)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
