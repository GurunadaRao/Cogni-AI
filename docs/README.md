# Documentation Index

Welcome to the **EchoClip AI Voice Recorder** documentation directory.

## Available Documentation

1. [**Architecture Overview**](file:///c:/Users/gurun/Documents/PROJECTS/hota-projects/ai_voice_recorder/docs/architecture.md)
   - High-level system topology (ESP32, AWS EC2, Flutter).
   - Layered directory structure.
   - Recording finite state machine specification (`RecordingState`).

2. [**API & WebSocket Specification**](file:///c:/Users/gurun/Documents/PROJECTS/hota-projects/ai_voice_recorder/docs/api_websocket_spec.md)
   - REST API contracts for `/recording/start`, `/recording/stop`, and `/sessions/{id}/summarize`.
   - Strongly-typed WebSocket JSON event schemas (`transcript.delta`, `summary.delta`, `chat.delta`, etc.).

3. [**Setup & Development Guide**](file:///c:/Users/gurun/Documents/PROJECTS/hota-projects/ai_voice_recorder/docs/setup_guide.md)
   - Environmental configuration and `--dart-define` parameters.
   - Mock/Development mode for offline testing without ESP32 hardware.
   - Running static analysis and automated unit tests.
