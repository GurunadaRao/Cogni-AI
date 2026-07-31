# Product Requirements Document (PRD)

> **Assumption flag:** I couldn't pull content from the linked YouTube video directly (YouTube blocks scraping), so this PRD is written against the **general pattern your description implies** — an ESP32 device publishing sensor data / accepting actuator commands via **AWS IoT Core (MQTT)**, a backend layer (API Gateway + Lambda + DynamoDB or similar) that persists and exposes that data, and a **Flutter mobile app** for monitoring + control. If the real reference project differs (e.g. it's GPS tracking, camera streaming, or a specific vertical like agriculture/health), tell me what's different and I'll revise Sections 3, 6, and 7 only — the rest of the structure holds.

---

## 1. Summary
A Flutter mobile app that lets a user monitor real-time sensor data from an ESP32 device and send control commands back to it, via an AWS-based cloud backend (IoT Core + API layer). This doc scopes the **mobile app's MVP** since hardware, backend, and AWS infra are owned by teammates.

## 2. Contacts
| Name | Role | Notes |
|---|---|---|
| Gurunada | Flutter Developer | Owns mobile app (this PRD) |
| Teammate(s) | Hardware (ESP32) | Owns firmware, sensors/actuators, device provisioning |
| Teammate(s) | Backend / AWS | Owns IoT Core, API layer, database, auth infra |

## 3. Background
- The team is building an IoT product: ESP32 hardware talks to AWS IoT Core over MQTT; a backend service exposes that data/control surface to clients.
- The mobile app is the primary interface end-users will actually touch — it needs to be usable standalone (device pairing, live status, control, history) without requiring the user to know anything about MQTT/AWS underneath.
- This is being built as a resume-worthy, demo-ready MVP under a hackathon/project timeline, so scope discipline matters more than feature completeness.

## 4. Objective
- Ship a working, demoable Flutter MVP that authenticates a user, shows live device state, and lets them send at least one control action — end to end, real device to real screen.
- **Key Results (first loop):**
  - KR1: User can log in and see their device's live status within 3 taps of app open.
  - KR2: Sensor data updates on-screen within ~2s of device publishing (via WebSocket/MQTT-over-WSS or polling, per backend contract).
  - KR3: At least 1 control command (e.g. toggle) round-trips from app → cloud → device → confirmed state change, visible in-app.

## 5. Market Segment(s)
- **Primary:** the team itself / demo judges — needs a clean, credible working product for evaluation.
- **Secondary (real usage):** end-users who own the ESP32 device and want simple remote monitoring/control without a desktop dashboard.
- **Constraint:** must work on a normal phone over regular WiFi/cellular, tolerate intermittent device connectivity, and not assume the user understands IoT internals.

## 6. Value Proposition(s)
- **Job to be done:** "Let me see what my device is doing right now, and control it, without needing a laptop or the AWS console."
- **Gain:** real-time visibility + control from anywhere, simple onboarding (pair device once).
- **Pain avoided:** no need to SSH/console into AWS, no confusing raw MQTT topics exposed to the user.
- **Differentiator vs. generic dashboards:** purpose-built screens for this exact device/use case, not a generic IoT dashboard template.

## 7. Solution

### 7.1 UX / Prototypes
No visuals per current constraint — screen flows are specified in `03_Flutter_App_Requirements.md`, Section "Screens & Navigation."

### 7.2 Key Features (MVP)
1. **Auth** — sign up / log in (email+password or AWS Cognito, per backend team's choice).
2. **Device pairing/selection** — associate a device ID with the user's account (assume backend provides a "claim device" endpoint).
3. **Live dashboard** — real-time sensor values + device online/offline status.
4. **Control screen** — send commands to the device (e.g. toggle, set value), with optimistic UI + confirmed-state reconciliation.
5. **History/logs (basic)** — list of recent readings/events, even if just a simple table/list (no charts required for MVP).
6. **Connectivity states** — explicit UI for "device offline," "no internet," "command failed/timed out" — these are common in IoT apps and often skipped until too late.

### 7.3 Technology
See `02_System_Architecture.md` and `03_Flutter_App_Requirements.md`.

### 7.4 Assumptions (flag to validate with backend/hardware team ASAP — these are the biggest risk to your Loop 1)
- Backend exposes REST endpoints for auth, device claim, and command dispatch, **plus** a real-time channel (WebSocket, MQTT-over-WSS via AWS IoT Device SDK, or AWS AppSync subscriptions) for live data — confirm which, since it changes the state management and networking layer significantly.
- Device→cloud latency is low enough (~1-2s) for a "live" feel; if not, UI needs to communicate "last updated Xs ago" instead of implying true real-time.
- One user maps to one or few devices for MVP (multi-device fleet management is a future enhancement, not MVP).
- Command delivery is not guaranteed instant — app must handle timeout/retry, not assume synchronous success.

## 8. Release Plan (Loop Engineering framing)
Not a waterfall timeline — scoped as iterative loops, each independently demoable. See `03_Flutter_App_Requirements.md` → "MVP Features and Future Enhancements" for the loop breakdown.

- **V1 (MVP):** Auth → Pairing → Live dashboard → Single control action → basic offline/error states.
- **V2+ (future):** multi-device support, push notifications on alerts, historical charts/analytics, offline command queueing, role-based sharing (family/team access to one device).
