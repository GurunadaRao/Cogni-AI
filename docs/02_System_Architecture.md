# System Architecture Document

> Scope note: hardware and AWS/backend are owned by teammates. This document defines the **contract** the Flutter app needs from them, plus the overall system shape, so your app work isn't blocked on their implementation details. Sections marked **[CONFIRM WITH TEAM]** are assumptions you should verify in your next sync — they're the ones most likely to change your app's networking layer.

## 1. High-Level Component Diagram (described, not rendered)

```
[ESP32 Device] --MQTT(TLS)--> [AWS IoT Core] --Rule--> [Lambda / IoT Rules Engine]
                                                              |
                                                              v
                                                     [DynamoDB / RDS] <--- state store
                                                              |
                                                              v
                                              [API Gateway (REST + WebSocket)]
                                                              |
                                                              v
                                                       [Flutter Mobile App]
                                                              |
                                                       [Cognito / Auth] (parallel path)
```

## 2. Data Flow

**Telemetry (device → app):**
1. ESP32 publishes sensor reading to an MQTT topic (e.g. `device/{deviceId}/telemetry`).
2. AWS IoT Core rule triggers a Lambda → writes to DynamoDB (latest state + time-series log) and/or pushes to a WebSocket API Gateway connection.
3. Flutter app receives update via WebSocket subscription (or polls REST endpoint on an interval as fallback).

**Command (app → device):**
1. User taps a control in the app → Flutter calls a REST endpoint (e.g. `POST /devices/{id}/commands`).
2. API Gateway → Lambda → publishes to MQTT topic (e.g. `device/{deviceId}/commands`) via IoT Core.
3. ESP32 subscribes to that topic, executes, and publishes a state-confirmation back on the telemetry topic.
4. Flutter app reconciles optimistic UI state with the confirmed state once it arrives (with a timeout fallback → "command failed" if no confirmation in N seconds).

## 3. Required Backend Contract (for Flutter team to request)

| Need | Endpoint/Channel type | Notes |
|---|---|---|
| Auth | REST (or AWS Cognito SDK direct) | Sign up, log in, refresh token |
| Claim/pair device | `POST /devices/claim` | Associates device ID with user |
| List user's devices | `GET /devices` | For MVP, likely returns 1 device |
| Get device current state | `GET /devices/{id}` | Snapshot on app open/reconnect |
| Real-time telemetry | WebSocket subscription or MQTT-over-WSS | **[CONFIRM WITH TEAM]** which mechanism |
| Send command | `POST /devices/{id}/commands` | Should return a command ID for tracking |
| Command status/ack | Via same real-time channel, or `GET /commands/{id}` | **[CONFIRM WITH TEAM]** |
| Device event/telemetry history | `GET /devices/{id}/history?limit=&since=` | For basic logs screen |

## 4. Non-Functional Requirements
- **Latency:** telemetry visible in-app within ~2s of device publish (soft target, not hard SLA for MVP).
- **Offline handling:** app must clearly distinguish "device offline" (device hasn't published recently) vs. "app offline" (no internet) vs. "backend error" — these require different UI and different retry logic.
- **Security:** all traffic over TLS; auth tokens stored securely (flutter_secure_storage, not shared_preferences); no AWS credentials ever embedded in the app — app talks to your team's API layer only, never directly to AWS services with long-lived credentials.
- **Scalability:** MVP assumes low device count per user; data model and API design should not hard-code "1 device" assumptions that block multi-device later.

## 5. Trade-offs & Open Decisions
| Decision | Option A | Option B | Recommendation for MVP |
|---|---|---|---|
| Real-time channel | WebSocket via API Gateway | MQTT-over-WSS direct from app to IoT Core | **A** — simpler auth story, backend controls the contract, easier to mock/test app independently |
| State sync on reconnect | Poll REST snapshot on app resume | Rely purely on WS replay | **A + fallback polling** — more resilient for a v1 |
| Command delivery confirmation | Wait for device ack via telemetry | Assume success after API 200 | **Wait for ack with timeout** — avoids showing false "success" state |

## 6. What to Revisit as It Grows
- Move from single-device to fleet/multi-device data model.
- Add push notifications (FCM) triggered by backend on alert conditions.
- Add offline command queueing if network reliability becomes an issue in real deployments.
- Consider AWS AppSync (GraphQL subscriptions) if the WebSocket API Gateway approach becomes hard to maintain.
