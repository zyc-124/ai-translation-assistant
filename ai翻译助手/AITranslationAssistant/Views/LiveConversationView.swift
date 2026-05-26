import SwiftUI

struct LiveConversationView: View {
    @EnvironmentObject private var store: SessionStore
    @StateObject private var speech = SpeechRecognizer()

    let session: ConversationSession

    @State private var currentChinese = ""
    @State private var suggestions: [AnswerSuggestion] = []
    @State private var isLoadingAnswer = false
    @State private var client = AIBackendClient()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                statusCard
                transcriptCard
                actionButtons
                answerSection
                historySection
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("实时会话")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await speech.requestAuthorization()
        }
        .onChange(of: speech.transcript) { _, newValue in
            Task {
                currentChinese = await client.translate(japanese: newValue)
            }
        }
        .onDisappear {
            speech.stop()
        }
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(speech.isRecording ? "正在监听" : "未开始", systemImage: speech.isRecording ? "waveform" : "mic")
                    .font(.headline)
                Spacer()
                Circle()
                    .fill(speech.isRecording ? .green : .gray)
                    .frame(width: 10, height: 10)
            }
            Text(speech.authorizationMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var transcriptCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("日语原文")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(speech.transcript.isEmpty ? "开始监听后，这里会显示日语转写。" : speech.transcript)
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            Text("中文理解")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(currentChinese.isEmpty ? "这里会显示中文翻译。" : currentChinese)
                .font(.body)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if detectQuestion(in: speech.transcript) {
                Label("可能是一个问题", systemImage: "questionmark.circle.fill")
                    .font(.subheadline)
                    .foregroundStyle(.orange)
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button {
                toggleRecording()
            } label: {
                Label(speech.isRecording ? "停止监听" : "开始监听", systemImage: speech.isRecording ? "stop.fill" : "mic.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            HStack {
                Button {
                    saveCurrentTranscript()
                } label: {
                    Label("保存重点", systemImage: "bookmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    Task { await generateAnswer() }
                } label: {
                    Label("帮我回答", systemImage: "sparkles")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(speech.transcript.isEmpty || isLoadingAnswer)
            }
        }
    }

    private var answerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("AI推荐回答")
                    .font(.headline)
                Spacer()
                if isLoadingAnswer {
                    ProgressView()
                }
            }

            if suggestions.isEmpty {
                Text("点击“帮我回答”后，这里会生成适合当前会话的日语回答。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(suggestions) { suggestion in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(suggestion.title)
                            .font(.subheadline.bold())
                        Text(suggestion.japanese)
                            .font(.body)
                        Text(suggestion.chinese)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("已保存记录")
                .font(.headline)
            if session.transcript.isEmpty {
                Text("暂无记录。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(session.transcript.suffix(5)) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.japanese)
                        Text(item.chinese)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Divider()
                }
            }
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func toggleRecording() {
        if speech.isRecording {
            speech.stop()
        } else {
            do {
                try speech.start()
            } catch {
                speech.authorizationMessage = "启动语音识别失败：\(error.localizedDescription)"
            }
        }
    }

    private func saveCurrentTranscript() {
        let item = TranscriptItem(
            japanese: speech.transcript,
            chinese: currentChinese,
            isQuestion: detectQuestion(in: speech.transcript)
        )
        store.appendTranscript(item, to: session)
    }

    private func generateAnswer() async {
        isLoadingAnswer = true
        suggestions = await client.generateAnswers(for: session, question: speech.transcript)
        isLoadingAnswer = false
    }
}
