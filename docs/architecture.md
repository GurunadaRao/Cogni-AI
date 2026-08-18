# Architecture Overview: Real-Time AI Voice Recorder (EchoClip)

## 1. System Overview

EchoClip is a real-time AI voice recording and transcription platform designed to process audio captured via ESP32 hardware or local recording interfaces, streamed through AWS EC2 orchestration services to Flutter clients over WebSocket connections.

```text
┌────────────────┐      ┌────────────────┐      ┌─────────────────────────┐      ┌─────────────────────────┐
│ ESP32 Hardware │─────>│  AWS EC2 Host  │─────>│ Speech-to-Text & AI     │─────>│ Flutter Application     │
│ Audio Capture  │      │ Orchestrator   │      │ Transcription Engine    │      │ Live Stream UI / Chat   │
└────────────────┘      └────────────────┘      └─────────────────────────┘      └─────────────────────────┘
                                 │                                                            │
                                 └───────────── WebSocket Event Streaming ────────────────────┘
```

## 2. Layered Application Architecture

The Flutter codebase follows a clean, feature-based architecture separating domain models, data repositories, state controllers, and presentation UI:

```text
lib/
├── core/
│   ├── config/              # AppConfig environment management (Dev, Staging, Production)
│   ├── constants/           # ApiConstants & AppColors
│   ├── errors/              # Custom ApiException and error structures
│   ├── network/             # ApiClient (REST) & AppWebSocketClient (WebSocket + Reconnect)
│   ├── providers/           # Global Riverpod Dependency Injection Providers
│   └── theme/               # Material 3 AppTheme definitions
│
├── features/
│   ├── recording/           # Core Recording Feature
│   │   ├── data/            # MockRecordingService & API contracts
│   │   ├── models/          # RecordingSession, TranscriptChunk, TranscriptSegment, RecordingState
│   │   ├── presentation/    # RecordingScreen, ConfigureScreen
│   │   └── providers/       # RecordingController & RecordingStateNotifier
│   │
│   ├── summary/             # AI Summarization Feature
│   │   ├── presentation/    # SummaryScreen
│   │   └── providers/       # SummaryController
│   │
│   └── chat/                # Contextual AI Chat Feature
│       ├── presentation/    # ChatScreen
│       └── providers/       # ChatController
```

## 3. Recording State Machine

State management relies on an explicit finite state machine (`RecordingState`) maintained by `RecordingController` to prevent inconsistent state combinations:

```text
               ┌──────────┐
               │   idle   │
               └────┬─────┘
                    │ startRecording()
                    ▼
               ┌──────────┐
               │ starting │
               └────┬─────┘
                    │ session created
                    ▼
               ┌──────────┐
               │connecting│
               └────┬─────┘
                    │ ws connected & recording.started
                    ▼
               ┌──────────┐
               │recording │ ◄─── transcript.delta (streams chunks)
               └────┬─────┘
                    │ stopRecording()
                    ▼
               ┌──────────┐
               │ stopping │
               └────┬─────┘
                    │ recording.stopped
                    ▼
               ┌──────────┐
               │processing│
               └────┬─────┘
                    │ processing.completed
                    ▼
               ┌──────────┐
               │completed │ ───► Summarise / Chat
               └──────────┘
```

---

## 4. Key Components & Responsibilities

1. **`AppConfig` (`lib/core/config/app_config.dart`)**:
   - Manages base URLs for REST (`API_BASE_URL`) and WebSockets (`WEBSOCKET_BASE_URL`).
   - Supports `--dart-define=USE_MOCK=true` or `--dart-define=ENVIRONMENT=production`.

2. **`AppWebSocketClient` (`lib/core/network/websocket_client.dart`)**:
   - Handles real-time communication with exponential backoff reconnect logic (`1s`, `2s`, `4s`, `8s`, `16s`).
   - Parses incoming JSON messages into typed events.

3. **`MockRecordingService` (`lib/features/recording/data/mock_recording_service.dart`)**:
   - Simulates ESP32 hardware audio recording, transcription delta streams, summary generation, and AI chat responses for offline development and unit testing.
