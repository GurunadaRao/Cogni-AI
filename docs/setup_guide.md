# Development & Setup Guide

This guide covers running, configuring, testing, and developing the **EchoClip AI Voice Recorder** Flutter application.

---

## 1. Prerequisites

- **Flutter SDK**: `>=3.7.0` (Dart `>=3.7.0`)
- **IDE**: VS Code or Android Studio with Flutter/Dart extensions installed.
- **Dependencies**: Restored automatically via `flutter pub get`.

---

## 2. Configuration & Environments

The application supports three environments: `development`, `staging`, and `production`. Environment parameters can be passed at build or launch time using `--dart-define`.

### 2.1 Launching with Development / Mock Mode (Default)
In mock mode, the application generates real-time transcript streaming, session state transitions, summaries, and chat responses without requiring an ESP32 hardware device or AWS EC2 server.

```bash
flutter run --dart-define=USE_MOCK=true
```

### 2.2 Launching against Staging / Production Backend
To connect directly to an EC2 instance or backend server:

```bash
flutter run \
  --dart-define=ENVIRONMENT=production \
  --dart-define=API_BASE_URL=http://your-ec2-instance:8080 \
  --dart-define=WEBSOCKET_BASE_URL=ws://your-ec2-instance:8080 \
  --dart-define=USE_MOCK=false
```

---

## 3. Running Static Analysis & Tests

### 3.1 Static Code Analysis
Run static analysis to ensure code conforms to rules:

```bash
flutter analyze
```

### 3.2 Running Unit and Widget Tests
Execute test suites covering state machine transitions, WebSocket event parsing, and controllers:

```bash
flutter test
```

---

## 4. Key Directories & Feature Locations

- **`lib/core/config/app_config.dart`**: Environment variables and mock mode configuration.
- **`lib/core/network/websocket_client.dart`**: Centralized WebSocket connection manager with auto-reconnect backoff logic.
- **`lib/features/recording/presentation/recording_screen.dart`**: Real-time voice recorder UI with auto-scrolling live transcript view.
- **`lib/features/summary/presentation/summary_screen.dart`**: Progressive streaming AI summary display.
- **`lib/features/chat/presentation/chat_screen.dart`**: Contextual AI assistant chat UI connected to session context.
