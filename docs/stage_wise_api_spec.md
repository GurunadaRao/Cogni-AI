# Comprehensive End-to-End Stage Specification & API Protocol

**Project:** Real-Time AI Voice Recorder (EchoClip)
**Target Roles:** Backend Orchestration Team (AWS EC2 / Cloud Engineer) & Mobile Engineering Team

---

## 1. Complete Stage-by-Stage Lifecycle Overview

The EchoClip application operates across **5 distinct runtime stages**. Below is the sequence flow of endpoints, payloads, and WebSocket events triggered during each stage:

```text
 Stage 1: Initialization & Session Provisioning
   └── POST /recording/start ──> Returns sessionId & webSocketUrl

 Stage 2: Real-Time Audio Capture & Speech-to-Text Streaming
   ├── Client connects WSS: ws://<server>:8080/ws/session/<sessionId>
   ├── Server emits "recording.started"
   └── Server streams "transcript.delta" (isFinal: false/true)

 Stage 3: Session Termination & Storage
   ├── POST /recording/stop (or WSS "recording.stop")
   ├── Server emits "recording.stopped"
   └── Server emits "recording.completed"

 Stage 4: AI Summarization & Key Action Item Extraction
   ├── POST /sessions/<sessionId>/summarize
   ├── Server emits "summary.started"
   ├── Server streams "summary.delta"
   └── Server emits "summary.completed"

 Stage 5: Contextual AI Q&A Assistant Chat
   ├── Client sends WSS "chat.message"
   ├── Server emits "chat.started"
   ├── Server streams "chat.delta"
   └── Server emits "chat.completed"
```

---

## 2. Detailed Stage-Wise Endpoint & Data Specifications

### STAGE 1: Session Provisioning & Start

#### Endpoint: `POST /recording/start`

- **Purpose**: Initializes a new recording session, triggers the ESP32 hardware capture interface, and returns session parameters.
- **Request Headers**: `Content-Type: application/json`
- **Request Payload**:
  ```json
  {
    "deviceId": "ESP32_Mic_01",
    "sampleRate": "16000 Hz",
    "noiseCancellation": true,
    "userMetadata": {
      "userId": "user_456",
      "clientVersion": "1.0.0"
    }
  }
  ```
- **Response Payload (`200 OK`)**:
  ```json
  {
    "sessionId": "session_1739812900",
    "status": "starting",
    "webSocketUrl": "ws://54.237.76.182:8080/ws/session/session_1739812900",
    "createdAt": "2026-08-18T08:30:00Z"
  }
  ```
- **Backend Responsibilities**:
  1. Generate unique `sessionId`.
  2. Send `START_RECORDING` payload over MQTT/Socket to ESP32 device `ESP32_Mic_01`.
  3. Open WebSocket listener channel at `/ws/session/<sessionId>`.

---

### STAGE 2: Real-Time Audio Capture & Live STT Streaming

#### WebSocket Handshake: `ws://<host>:8080/ws/session/<sessionId>`

#### Event 2.1: Server Ready Notice

- **Direction**: Server ➔ Flutter Client
- **Payload**:
  ```json
  {
    "type": "recording.started",
    "sessionId": "session_1739812900",
    "timestamp": "2026-08-18T08:30:01Z"
  }
  ```

#### Event 2.2: Speech-to-Text Live Transcript Stream

- **Direction**: Server ➔ Flutter Client
- **Partial Recognition Frame Payload**:
  ```json
  {
    "type": "transcript.delta",
    "sessionId": "session_1739812900",
    "text": "Today we are discussing the real-time AI voice recorder",
    "isFinal": false,
    "sequenceId": 1
  }
  ```
- **Committed Final Sentence Payload**:
  ```json
  {
    "type": "transcript.delta",
    "sessionId": "session_1739812900",
    "text": "Today we are discussing the real-time AI voice recorder architecture.",
    "isFinal": true,
    "sequenceId": 2
  }
  ```

---

### STAGE 3: Session Termination & Data Persistence

#### Endpoint: `POST /recording/stop`

- **Purpose**: Signals session completion, flushes remaining STT audio buffers, and persists transcript history.
- **Request Payload**:
  ```json
  {
    "sessionId": "session_1739812900"
  }
  ```
- **Response Payload (`200 OK`)**:
  ```json
  {
    "sessionId": "session_1739812900",
    "status": "stopping"
  }
  ```

#### Event 3.1: WebSocket Completion Event

- **Direction**: Server ➔ Flutter Client
- **Payload**:
  ```json
  {
    "type": "recording.completed",
    "sessionId": "session_1739812900",
    "durationSeconds": 145,
    "totalWords": 320
  }
  ```

---

### STAGE 4: AI Meeting Summarization & Insight Generation

#### Endpoint: `POST /sessions/{sessionId}/summarize`

- **Purpose**: Feeds the complete session transcript into Gemini AI to generate raw summaries and bullet points.
- **Request Payload**: `{}` (Empty JSON or metadata)
- **Response Payload (`200 OK`)**:
  ```json
  {
    "sessionId": "session_1739812900",
    "status": "summarizing"
  }
  ```

#### Event 4.1: Summary Stream Start

- **Direction**: Server ➔ Flutter Client
- **Payload**:
  ```json
  {
    "type": "summary.started",
    "sessionId": "session_1739812900"
  }
  ```

#### Event 4.2: Summary Streaming Tokens

- **Direction**: Server ➔ Flutter Client
- **Payload**:
  ```json
  {
    "type": "summary.delta",
    "sessionId": "session_1739812900",
    "text": "The meeting established the real-time WebSocket protocol between ESP32, EC2, and Flutter.",
    "bulletPoints": [
      "ESP32 captures PCM audio at 16 kHz Mono.",
      "EC2 processes live speech recognition and streams JSON deltas."
    ]
  }
  ```

#### Event 4.3: Summary Stream Completed

- **Direction**: Server ➔ Flutter Client
- **Payload**:
  ```json
  {
    "type": "summary.completed",
    "sessionId": "session_1739812900"
  }
  ```

---

### STAGE 5: Contextual AI Q&A Assistant Chat

#### Event 5.1: Client Sends Question

- **Direction**: Flutter Client ➔ Server
- **Payload**:
  ```json
  {
    "type": "chat.message",
    "sessionId": "session_1739812900",
    "message": "What sample rate did we decide for ESP32 audio capture?"
  }
  ```

#### Event 5.2: Server Answers via Streaming

- **Direction**: Server ➔ Flutter Client
- **Start Payload**:
  ```json
  {
    "type": "chat.started",
    "sessionId": "session_1739812900"
  }
  ```
- **Delta Payload**:
  ```json
  {
    "type": "chat.delta",
    "sessionId": "session_1739812900",
    "text": "Based on your meeting transcript, the team decided to use 16,000 Hz (16 kHz) 16-bit Mono PCM audio."
  }
  ```
- **Completion Payload**:
  ```json
  {
    "type": "chat.completed",
    "sessionId": "session_1739812900"
  }
  ```

---

### STAGE 6: History Retrieval & Management

#### Endpoint 6.1: Get Saved Sessions (`GET /meetings`)

- **Response Payload (`200 OK`)**:
  ```json
  [
    {
      "id": "session_1739812900",
      "title": "IoT Audio Streaming Sync",
      "transcript": "Full text transcript...",
      "summary": "AI generated summary text...",
      "reminders": ["Check DynamoDB index"],
      "createdAt": "2026-08-18T08:30:00Z",
      "durationSeconds": 145
    }
  ]
  ```

#### Endpoint 6.2: Save Session (`POST /new-meeting`)

- **Request Payload**:
  ```json
  {
    "title": "IoT Audio Streaming Sync",
    "transcript": "Full text transcript...",
    "summary": "AI generated summary text...",
    "reminders": ["Check DynamoDB index"]
  }
  ```
