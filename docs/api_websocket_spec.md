# WebSocket & REST API Protocol Specification

This document details the exact JSON contract and REST API endpoints used between the Flutter client, the AWS EC2 orchestrator, and ESP32 recording hardware.

---

## 1. REST API Endpoints

### 1.1 Start Recording Session
Starts a new recording session and prepares the backend orchestrator and ESP32 hardware.

- **Endpoint**: `POST /recording/start`
- **Headers**: `Content-Type: application/json`
- **Request Body**:
  ```json
  {
    "deviceId": "ESP32_Mic_01",
    "sampleRate": "16000 Hz",
    "noiseCancellation": true
  }
  ```
- **Response** (`200 OK`):
  ```json
  {
    "sessionId": "session_1739812900",
    "status": "starting",
    "webSocketUrl": "wss://ec2-instance.aws.com/ws/session/session_1739812900"
  }
  ```

---

### 1.2 Stop Recording Session
Requests immediate termination of audio streaming and begins transcript post-processing.

- **Endpoint**: `POST /recording/stop`
- **Headers**: `Content-Type: application/json`
- **Request Body**:
  ```json
  {
    "sessionId": "session_1739812900"
  }
  ```
- **Response** (`200 OK`):
  ```json
  {
    "sessionId": "session_1739812900",
    "status": "stopping"
  }
  ```

---

### 1.3 Request AI Session Summary
Triggers AI summarization over the recorded session transcript.

- **Endpoint**: `POST /sessions/{sessionId}/summarize`
- **Response** (`200 OK`):
  ```json
  {
    "status": "summarizing"
  }
  ```

---

## 2. WebSocket Protocol (`wss://<server>/ws/session/<sessionId>`)

All messages sent over the WebSocket connection use JSON formatting with a top-level `"type"` string.

### 2.1 Incoming Events (Server → Flutter)

#### Recording Started
```json
{
  "type": "recording.started",
  "sessionId": "session_1739812900"
}
```

#### Real-Time Transcript Delta
```json
{
  "type": "transcript.delta",
  "sessionId": "session_1739812900",
  "text": "Today we are discussing the architecture",
  "isFinal": false,
  "sequenceId": 12
}
```
- `isFinal: false`: Represents partial speech recognition output.
- `isFinal: true`: Appends the segment permanently to the transcript list.

#### Recording Stopped / Processing Complete
```json
{
  "type": "recording.stopped",
  "sessionId": "session_1739812900"
}
```
```json
{
  "type": "recording.completed",
  "sessionId": "session_1739812900"
}
```

#### AI Summary Streaming Deltas
```json
{
  "type": "summary.started",
  "sessionId": "session_1739812900"
}
```
```json
{
  "type": "summary.delta",
  "sessionId": "session_1739812900",
  "text": "The meeting focused on establishing the real-time voice recorder architecture."
}
```
```json
{
  "type": "summary.completed",
  "sessionId": "session_1739812900"
}
```

#### AI Chat Streaming Deltas
```json
{
  "type": "chat.started",
  "sessionId": "session_1739812900"
}
```
```json
{
  "type": "chat.delta",
  "sessionId": "session_1739812900",
  "text": "The main decision was using WebSocket streaming."
}
```
```json
{
  "type": "chat.completed",
  "sessionId": "session_1739812900"
}
```

---

### 2.2 Outgoing Messages (Flutter → Server)

#### Send Chat Question
```json
{
  "type": "chat.message",
  "sessionId": "session_1739812900",
  "message": "What were the main decisions made in this session?"
}
```
