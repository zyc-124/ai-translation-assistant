import SwiftUI

struct SessionListView: View {
    @EnvironmentObject private var store: SessionStore

    var body: some View {
        List {
            Section {
                ForEach(store.sessions) { session in
                    NavigationLink(value: session.id) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(session.title)
                                .font(.headline)
                            Text(session.userRole)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                            Text("记录 \(session.transcript.count) 条")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 6)
                    }
                }
                .onDelete { indexes in
                    indexes.map { store.sessions[$0] }.forEach(store.delete)
                }
            } header: {
                Text("最近会话")
            }
        }
        .navigationTitle("AI翻译助手")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    _ = store.createSession()
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("新建会话")
            }
        }
        .navigationDestination(for: UUID.self) { id in
            if let session = store.sessions.first(where: { $0.id == id }) {
                SessionEditorView(session: session)
            } else {
                ContentUnavailableView("会话不存在", systemImage: "tray")
            }
        }
    }
}
