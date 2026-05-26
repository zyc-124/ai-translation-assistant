import Foundation

@MainActor
final class SessionStore: ObservableObject {
    @Published private(set) var sessions: [ConversationSession] = []

    private let storageKey = "ai_translation_assistant_sessions"

    init() {
        load()
        if sessions.isEmpty {
            sessions = [.sample]
            save()
        }
    }

    func createSession() -> ConversationSession {
        let session = ConversationSession(
            title: "新的会话",
            userRole: "日语不够流利的会议参加者",
            background: "",
            keyPoints: "回答要简单、自然、礼貌。不确定时说需要确认。",
            answerLength: .short,
            answerTone: .polite,
            transcript: []
        )
        sessions.insert(session, at: 0)
        save()
        return session
    }

    func update(_ session: ConversationSession) {
        guard let index = sessions.firstIndex(where: { $0.id == session.id }) else { return }
        var updated = session
        updated.updatedAt = Date()
        sessions[index] = updated
        save()
    }

    func appendTranscript(_ item: TranscriptItem, to session: ConversationSession) {
        guard let index = sessions.firstIndex(where: { $0.id == session.id }) else { return }
        sessions[index].transcript.append(item)
        sessions[index].updatedAt = Date()
        save()
    }

    func delete(_ session: ConversationSession) {
        sessions.removeAll { $0.id == session.id }
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        sessions = (try? JSONDecoder().decode([ConversationSession].self, from: data)) ?? []
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(sessions) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
