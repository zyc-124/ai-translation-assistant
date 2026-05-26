# AI翻译助手

这是一个面向 iPhone 的 SwiftUI 原型应用，用来验证“日语会议实时理解 + AI 回答辅助 + 会后总结”的产品想法。

## 当前已实现

- 会话列表：创建不同场景，例如公司会议、课堂、面谈。
- 会话设置：编辑用户身份、会议背景、回答长度、回答语气、AI 回答要点。
- 实时会议页：通过 iPhone 麦克风进行日语语音识别，并显示日语原文。
- AI 回答：预留后端接口，默认提供本地示例回答，避免把 OpenAI API Key 写进 App。
- 会后总结：根据当前转写内容生成摘要、问题、待办和复盘内容。

## 在 Mac 上运行

1. 用 Xcode 打开 `AITranslationAssistant.xcodeproj`。
2. 选择 iPhone 模拟器或真机。
3. 如果要测试麦克风和语音识别，建议使用真机。
4. 第一次启动时允许麦克风和语音识别权限。

## API 设计建议

手机 App 不应该直接保存 OpenAI API Key。建议 App 请求你自己的服务器：

```text
iPhone App
  -> HTTPS
你的后端服务
  -> OpenAI / ChatGPT API
```

后端接口可以先设计为：

- `POST /api/answer`：根据会话设置和当前问题生成日语回答。
- `POST /api/summary`：根据会议转写生成会后总结。
- `POST /api/translate`：把日语转成中文。

当前项目里的 `AIBackendClient.swift` 已经按这个结构预留好了。

## 后续开发重点

- 接入真实翻译服务。
- 接入后端 ChatGPT API。
- 优化实时语音识别的分段和延迟。
- 增加历史记录搜索和删除。
- 增加隐私提示、录音授权提示和数据清理功能。
