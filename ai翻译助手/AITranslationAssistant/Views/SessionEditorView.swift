import SwiftUI

struct SessionEditorView: View {
    @EnvironmentObject private var store: SessionStore
    @State private var session: ConversationSession

    init(session: ConversationSession) {
        _session = State(initialValue: session)
    }

    var body: some View {
        Form {
            Section("基础信息") {
                TextField("会话名称", text: $session.title)
                TextField("我的身份", text: $session.userRole, axis: .vertical)
                TextField("会议背景", text: $session.background, axis: .vertical)
                    .lineLimit(3...6)
            }

            Section("AI回答设置") {
                Picker("回答长度", selection: $session.answerLength) {
                    ForEach(AnswerLength.allCases) { item in
                        Text(item.rawValue).tag(item)
                    }
                }

                Picker("回答语气", selection: $session.answerTone) {
                    ForEach(AnswerTone.allCases) { item in
                        Text(item.rawValue).tag(item)
                    }
                }

                TextField("AI回答要点", text: $session.keyPoints, axis: .vertical)
                    .lineLimit(5...10)
            }

            Section {
                NavigationLink {
                    LiveConversationView(session: session)
                } label: {
                    Label("开始会话", systemImage: "mic.circle.fill")
                }

                NavigationLink {
                    SummaryView(session: session)
                } label: {
                    Label("查看会后总结", systemImage: "doc.text.magnifyingglass")
                }
            }
        }
        .navigationTitle(session.title)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            store.update(session)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("保存") {
                    store.update(session)
                }
            }
        }
    }
}
