import Foundation

struct AIBackendClient {
    var baseURL: URL?

    func translate(japanese: String) async -> String {
        guard !japanese.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return ""
        }

        // MVP fallback. Replace this with POST /api/translate on your server.
        if japanese.contains("どう思いますか") {
            return "关于这件事，你怎么看？"
        }
        if japanese.contains("できますか") || japanese.contains("可能ですか") {
            return "可以做到吗？"
        }
        return "这里显示中文翻译。接入后端后会返回真实翻译结果。"
    }

    func generateAnswers(for session: ConversationSession, question: String) async -> [AnswerSuggestion] {
        // MVP fallback. Replace this with POST /api/answer on your server.
        let cautious = AnswerSuggestion(
            title: "谨慎回答",
            japanese: "はい、良いと思います。ただ、詳しい内容についてはもう少し確認したいです。確認しながら進めていきたいと思います。",
            chinese: "是的，我觉得不错。不过详细内容我还想再确认一下。我想一边确认一边推进。"
        )
        let short = AnswerSuggestion(
            title: "简短回答",
            japanese: "はい、良いと思います。もう少し確認しながら進めたいです。",
            chinese: "是的，我觉得可以。我想再稍微确认一下后推进。"
        )
        let askBack = AnswerSuggestion(
            title: "反问确认",
            japanese: "すみません、確認ですが、今回の対象範囲はこの部分だけでよろしいでしょうか。",
            chinese: "不好意思，我确认一下，这次的对象范围只包括这一部分吗？"
        )

        switch session.answerLength {
        case .short:
            return [short, cautious, askBack]
        case .normal, .detailed:
            return [cautious, short, askBack]
        }
    }

    func summarize(session: ConversationSession) async -> MeetingSummary {
        let questions = session.transcript
            .filter(\.isQuestion)
            .map(\.chinese)

        return MeetingSummary(
            overview: "本次对话主要围绕当前会话主题进行。系统已经记录日语转写内容，接入后端后可以生成更准确的会议摘要。",
            questions: questions.isEmpty ? ["本次记录中暂未标记问题。"] : questions,
            actions: ["确认不确定的内容", "整理需要回复的事项", "必要时用日语发送后续说明"],
            review: "建议优先使用简短、礼貌、可确认的表达，例如「確認してから改めて共有します」。"
        )
    }
}

func detectQuestion(in japanese: String) -> Bool {
    let markers = ["?", "？", "か", "どう思います", "できますか", "可能ですか", "でしょうか", "いかがですか"]
    return markers.contains { japanese.contains($0) }
}
