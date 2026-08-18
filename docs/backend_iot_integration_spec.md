# Integration & System Specification for Backend & IoT Engineers

**Project:** Real-Time AI Voice Recorder (EchoClip)  
**Target Roles:** Backend/Cloud Engineer (AWS EC2), IoT Embedded Hardware Specialist (ESP32)

---

## 1. Executive Summary & Topology

The EchoClip client application is built with Flutter and communicates with an AWS EC2 orchestrator. The EC2 instance manages speech-to-text (STT) inference, AI summarization, contextual chat sessions, and hardware control instructions for ESP32 recording devices.

```text
┌─────────────────────────┐        Audio Stream (PCM/I2S)        ┌─────────────────────────┐
│ ESP32 Hardware Recorder │ ───────────────────────────────────> │  AWS EC2 Orchestrator   │
│ (Microphone & Wi-Fi)    │ <─────────────────────────────────── │  Backend Server         │
└─────────────────────────┘         Control Commands             └─────────────────────────┘
                                                                              │
                                                                   WebSocket  │  REST APIs
                                                                   Event Stream (STT, AI)
                                                                              ▼
                                                                 ┌─────────────────────────┐
                                                                 │   Flutter App Client    │
                                                                 └─────────────────────────┘
```

---

## 2. Guide for IoT Hardware Specialist (ESP32)

### 2.1 Audio Capture & Streaming Requirements
- **Audio Interface**: I2S MEMS microphone (e.g., INMP441 or MSM261S4030H0).
- **Sampling Rate**: `16,000 Hz` (16 kHz), 16-bit Mono, PCM format (Optimized for Speech Recognition).
- **Transmission Protocol**: UDP or direct WebSocket binary stream to EC2 server endpoint.
- **Buffering**: Packetize audio into ~50ms to 100ms chunks to minimize latency during live transcription.

### 2.2 Device Control Commands (EC2 → ESP32)
The ESP32 must listen for control payloads over MQTT, WebSocket, or TCP socket:

- `START_RECORDING`: Initialize I2S peripheral and start streaming audio frames to EC2.
- `STOP_RECORDING`: Flush buffered audio frames, stop I2S DMA transfer, and return device to ready state.
- `CONFIG_UPDATE`: Update noise suppression filter parameters or sample rate dynamically.

### 2.3 Status Reporting (ESP32 → EC2)
Heartbeat payload sent every 5 seconds:
```json
{
  "deviceId": "ESP32_Mic_01",
  "status": "recording",
  "battery": 92,
  "wifiSignalDbm": -62,
  "sampleRate": 16000
}
```

---

## 3. Guide for Backend & Cloud Engineer (AWS EC2)

### 3.1 REST API Specification (EC2 → Flutter Client)

#### Endpoint 1: Start Recording Session
- **URL**: `POST /recording/start`
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
    "sessionId": "session_987654321",
    "status": "starting",
    "webSocketUrl": "wss://<ec2-domain-or-ip>/ws/session/session_987654321"
  }
  ```
- **Action**: EC2 issues `START_RECORDING` to the corresponding ESP32 device and opens session context.

#### Endpoint 2: Stop Recording Session
- **URL**: `POST /recording/stop`
- **Request Body**:
  ```json
  {
    "sessionId": "session_987654321"
  }
  ```
- **Response** (`200 OK`):
  ```json
  {
    "sessionId": "session_987654321",
    "status": "stopping"
  }
  ```
- **Action**: EC2 issues `STOP_RECORDING` command to ESP32, finalizes STT transcript stream, and persists session history.

#### Endpoint 3: Request Session Summary
- **URL**: `POST /sessions/{sessionId}/summarize`
- **Response** (`200 OK`):
  ```json
  {
    "status": "summarizing"
  }
  ```
- **Action**: Triggers LLM summary generation task and streams result over WebSocket (`summary.delta`).

---

### 3.2 WebSocket Streaming Specification (`wss://<server>/ws/session/<sessionId>`)

All messages sent over the WebSocket connection use JSON formatting with a mandatory `"type"` string.

#### Event: Real-Time Live Transcript (EC2 → Flutter)
```json
{
  "type": "transcript.delta",
  "sessionId": "session_987654321",
  "text": "Today we are discussing the architecture",
  "isFinal": false,
  "sequenceId": 12
}
```
- Set `isFinal: true` when a speech phrase/sentence is completed to commit segment in Flutter UI.

#### Event: Recording Stopped Notice (EC2 → Flutter)
```json
{
  "type": "recording.stopped",
  "sessionId": "session_987654321"
}
```

#### Event: AI Summary Stream (EC2 → Flutter)
```json
{
  "type": "summary.started",
  "sessionId": "session_987654321"
}
```
```json
{
  "type": "summary.delta",
  "sessionId": "session_987654321",
  "text": "The session covered real-time audio streaming from ESP32 to EC2."
}
```
```json
{
  "type": "summary.completed",
  "sessionId": "session_987654321"
}
```

#### Event: AI Contextual Chat Stream
- **Client Request (Flutter → EC2)**:
  ```json
  {
    "type": "chat.message",
    "sessionId": "session_987654321",
    "message": "What key architectural decisions were made?"
  }
  ```
- **Server Stream Response (EC2 → Flutter)**:
  ```json
  {
    "type": "chat.delta",
    "sessionId": "session_987654321",
    "text": "The key decision was using WebSockets for low-latency streaming."
  }
  ```
  ```json
  {
    "type": "chat.completed",
    "sessionId": "session_987654321"
  }
  ```

---

## 4. Checklist for System Integration Testing

1. [ ] **ESP32 Audio Stream Verification**: Verify ESP32 captures PCM audio at 16 kHz and streams to EC2 without dropping packets.
2. [ ] **WebSocket Latency**: Ensure `transcript.delta` messages arrive at Flutter client within <500ms of speech.
3. [ ] **Session Reconnection**: Ensure Flutter app can re-establish WebSocket connection if network momentarily drops without losing session context.
4. [ ] **HTTPS/WSS Compliance**: Ensure production EC2 endpoints are secured with TLS/SSL certificates (`wss://` and `https://`).
