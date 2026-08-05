# AI Voice Recorder Backend & Integration Knowledge Base

This knowledge base consolidates the specifications, API contracts, server configurations, data schemas, and architecture detailed in the latest 3 documentation files within the `docs/` folder:

1. [Backend_API_Contracts_Server_Config_TechStack_DataSchema.docx](file:///c:/Users/gurun/Documents/PROJECTS/hota-projects/ai_voice_recorder/docs/Backend_API_Contracts_Server_Config_TechStack_DataSchema.docx)
2. [AI_Voice_Recorder_Backend_Developer_Appendix.docx](file:///c:/Users/gurun/Documents/PROJECTS/hota-projects/ai_voice_recorder/docs/AI_Voice_Recorder_Backend_Developer_Appendix.docx)
3. [AI_Voice_Recorder_Backend_Documentation.docx](file:///c:/Users/gurun/Documents/PROJECTS/hota-projects/ai_voice_recorder/docs/AI_Voice_Recorder_Backend_Documentation.docx)

---

## 1. System Architecture & Audio Flow

### Hardware & Audio Capture
- **Hardware**: ESP32-S3 Sense with ICS43434 I2S Microphone
- **Pin Connections**:
  - `VCC` → `3.3V` | `GND` → `GND`
  - `WS` → `GPIO42` | `SCK` → `GPIO41` | `SD` → `GPIO2` | `L/R` → `GND`
- **Audio Specs**: Raw PCM audio (32 kHz, Mono, 16-bit, 10s segment chunking).

### Processing Pipeline
1. **ESP32 Microcontroller**: Streams raw PCM audio over WebSocket.
2. **Node.js Express Server**: Receives PCM in rolling buffer & converts to `.wav`.
3. **Speech-to-Text**: Sends audio to **ElevenLabs Scribe / STT API** for transcription.
4. **AI Processing**: Generates transcript summaries, reminder bullet points, and handles Q&A using **Google Gemini API**.
5. **Storage & Serving**: Exposes REST endpoints and serves stored WAV/Text/Summary data to the web dashboard and Flutter mobile app.

---

## 2. Server Configuration & Technology Stack

- **Runtime & Framework**: Node.js, Express.js, `ws` (WebSocket)
- **Deployment**: AWS EC2 Ubuntu, managed via PM2 process manager
- **Port**: `8080` (HTTP & WS)
- **Environment Variables Required**:
  - `PORT` (8080)
  - `ELEVENLABS_API_KEY`
  - `GEMINI_API_KEY`
  - `GEMINI_MODEL`
  - `PUBLIC_BASE_URL`
  - `FRONTEND_ORIGIN` (Optional)

---

## 3. Storage Directory Structure

```text
recordings/      --> recording_xxx.wav
transcripts/     --> transcript_xxx.txt
audio/           --> temporary PCM/WAV segment buffers
summaries/       --> summary_xxx.txt / summary_xxx.json
```

---

## 4. API Endpoints Reference

### Live Audio & Streaming
- **WebSocket**: `ws://<EC2_PUBLIC_IP>:8080/`
  - *Purpose*: Receive live PCM audio stream.
- **GET `/live`**: Live transcription stream page.
- **GET `/live.wav`**: Live WAV audio stream.

### Audio & Transcript Management
- **GET `/transcript`**: Fetch active/latest transcript text.
- **GET `/latest`**: Returns latest transcript JSON:
  ```json
  {
    "text": "Latest transcript content...",
    "updatedAt": "2026-08-02T12:20:10Z"
  }
  ```
- **GET `/recordings/:filename`**: Returns recorded WAV file.
- **GET `/transcripts/:filename`**: Returns transcript text file.
- **GET `/download/wav`**: Direct download link for recorded WAV audio.

### AI Capabilities (Gemini Integration)
- **POST `/generate-summary`** (or `/summary`):
  - *Request*: `{ "transcript": "..." }`
  - *Response*: `{ "success": true, "summary": "...", "reminders": ["..."] }`
- **POST `/ask`** (or `/chat`):
  - *Request*: `{ "question": "...", "context": "..." }`
  - *Response*: `{ "success": true, "answer": "..." }`

### Meeting Management
- **POST `/new-meeting`**: `{ "title": "Meeting Name" }`
- **GET `/meetings`**: List all saved meeting records.

---

## 5. Data Schemas

### Meeting Model
```json
{
  "id": "meeting_id_str",
  "title": "Project Sync",
  "transcript": "Full text transcript...",
  "summary": "Key points discussed...",
  "createdAt": "2026-08-04T12:00:00Z"
}
```

### Recording & Audio Metadata
```json
{
  "recordingFile": "recording_xxx.wav",
  "duration": 600,
  "sampleRate": 32000,
  "channels": 1
}
```
