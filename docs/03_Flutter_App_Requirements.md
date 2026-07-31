# Flutter App Requirements

## 1. App Architecture

**Recommended: Clean Architecture (light version) + feature-first folder structure**, scaled to project size — don't over-engineer a student MVP with full DDD layering, but keep clear separation so Loop Engineering iterations don't cause regressions.

```
lib/
  core/
    network/         # dio/http client, interceptors, websocket client
    auth/             # token storage, auth state
    error/            # failure types, exception mapping
    theme/
  features/
    auth/
      data/           # auth_repository_impl, remote datasource
      domain/         # entities, repository interface, use cases
      presentation/   # screens, providers/controllers
    devices/
      data/
      domain/
      presentation/
    device_control/
      data/
      domain/
      presentation/
    history/
      data/
      domain/
      presentation/
  main.dart
  app.dart            # routing + app shell
```

- **Layering per feature:** `presentation → domain → data`. Domain layer has no Flutter/AWS imports — keeps business logic testable and swappable if backend contract changes mid-project (likely, given teammates are still building it).
- **Why this matters for Loop Engineering:** each loop typically touches one feature folder end-to-end (data → domain → presentation), so loops don't collide with each other's code.

## 2. Screens & Navigation

**Navigation:** `go_router` (declarative, handles auth redirects and deep-linking cleanly).

```
/splash            → checks auth state → redirects
/login             → /signup
/signup            → back to /login on success
/home (dashboard)  → shows device list or single device live view
  /home/device/:id → device detail (live telemetry + control)
  /home/device/:id/history → basic log/history list
/settings          → account, logout, (future: manage devices)
```

**Flow summary:**
1. **Splash** → check stored token → valid: go to Home; invalid/none: go to Login.
2. **Login/Signup** → on success, fetch device list → Home.
3. **Home/Dashboard** → shows claimed device(s), live status indicator (online/offline), latest sensor reading.
4. **Device Detail** → live telemetry (auto-updating), control action(s), explicit loading/error/offline states.
5. **History** → simple reverse-chronological list of past readings/events, paginated.
6. **Settings** → logout, app version, (future: device management, notifications toggle).

## 3. State Management Recommendation

**Riverpod** (already consistent with your Flutter/Firebase skill context) — specifically:
- `StateNotifierProvider` or `AsyncNotifierProvider` per feature for screen state.
- A dedicated `StreamProvider` (or Riverpod `Notifier` wrapping a WebSocket stream) for live telemetry — this is the piece most worth getting right early, since real-time state is the trickiest part of this app.
- Keep auth state in a top-level provider that `go_router`'s `redirect` logic reads, so route guards stay reactive.

**Why Riverpod over Bloc/Provider here:** less boilerplate for a small team/timeline, testable without BuildContext, and handles the async-stream-plus-request-response mix (REST + WebSocket) this app needs without two different mental models.

## 4. Required APIs and Models

Matches the backend contract in `02_System_Architecture.md` §3. Confirm exact field names with backend team before Loop 1 — this is the highest-risk integration point.

### Models (domain entities)
```dart
class AppUser {
  final String id;
  final String email;
}

class Device {
  final String id;
  final String name;
  final DeviceStatus status; // online / offline / unknown
  final DateTime lastSeen;
}

class TelemetryReading {
  final String deviceId;
  final Map<String, dynamic> values; // e.g. {"temperature": 24.5, "humidity": 61}
  final DateTime timestamp;
}

class DeviceCommand {
  final String id;
  final String deviceId;
  final String action;          // e.g. "toggle_relay"
  final Map<String, dynamic>? params;
  final CommandStatus status;   // pending / confirmed / failed / timed_out
}
```

### API calls needed (Flutter → backend)
| Method | Endpoint | Purpose |
|---|---|---|
| POST | `/auth/login`, `/auth/signup` | Auth |
| POST | `/devices/claim` | Pair a device to the user |
| GET | `/devices` | List user's devices |
| GET | `/devices/{id}` | Current snapshot |
| GET | `/devices/{id}/history` | Past readings (paginated) |
| POST | `/devices/{id}/commands` | Send a control command |
| WS | `/live` (or MQTT-over-WSS) | Subscribe to real-time telemetry + command acks |

## 5. MVP Features and Future Enhancements

### MVP (Loop 1–3 target)
- [ ] **Loop 1:** Auth (login/signup) + token persistence + route guarding.
- [ ] **Loop 2:** Device claim/list + dashboard showing live status (even if "live" = polling every few seconds initially, upgrade to WebSocket after).
- [ ] **Loop 3:** Single control action end-to-end (app → backend → device → confirmed state back in app) + explicit offline/error/timeout UI states.
- [ ] **Loop 4:** Basic history list screen.

### Future Enhancements (post-MVP)
- Multi-device management (add/remove/rename devices).
- Push notifications (FCM) for alert conditions from backend.
- Historical data charts (fl_chart or similar) instead of raw list.
- Offline command queueing with retry when connectivity returns.
- Role-based device sharing (invite family/team members to a device).
- Biometric app lock, dark mode, localization.

## 6. Loop Engineering Notes
- Each loop above should end with something **runnable and demoable**, even against mocked backend responses if the real backend isn't ready yet — don't let hardware/backend timelines block app progress. Build a simple mock REST + fake WebSocket stream behind the same repository interface so you can swap the real implementation in without touching UI code.
- Keep the domain layer's interfaces stable early (`DeviceRepository`, `AuthRepository`) — that's the seam that lets you develop against mocks now and plug in real AWS-backed endpoints later without a rewrite.
