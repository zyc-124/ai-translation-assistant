import Foundation

enum AnswerLength: String, CaseIterable, Codable, Identifiable {
    case short = "短"
    case normal = "普通"
    case detailed = "详细"

    var id: String { rawValue }
}

enum AnswerTone: String, CaseIterable, Codable, Identifiable {
    case natural = "自然"
    case polite = "礼貌"
    case business = "商务"

    var id: String { rawValue }
}

struct ConversationSession: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var userRole: String
    var background: String
    var keyPoints: String
    var answerLength: AnswerLength
    var answerTone: AnswerTone
    var transcript: [TranscriptItem]
    var createdAt = Date()
    var updatedAt = Date()

    static let sample = ConversationSession(
        title: "公司会议",
        userRole: "外国人新员工，负责开发相关工作",
        background: "使用电脑参加日语会议，手机放在电脑旁边接收声音。",
        keyPoints: "回答要简单、礼貌。不要使用太难的日语。不确定时表达会确认后再回复。",
        answerLength: .short,
        answerTone: .polite,
        transcript: []
    )
}

struct TranscriptItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var japanese: String
    var chinese: String
    var isQuestion: Bool
    var createdAt = Date()
}

struct AnswerSuggestion: Identifiable, Equatable {
    var id = UUID()
    var title: String
    var japanese: String
    var chinese: String
}

struct MeetingSummary: Equatable {
    var overview: String
    var questions: [String]
    var actions: [String]
    var review: String
}
