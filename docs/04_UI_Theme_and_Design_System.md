# Theme & UI/UX Design System Specification

## 1. Overview & Aesthetics Goal

This document defines the design system, color palette, typography, visual hierarchy, and key UI components for the **IoT AI Voice Recorder & Device Control** Flutter app.

The design vision is a **Clean, Modern, Premium Light Theme** utilizing a curated blue color scale. It focuses on high legibility, crisp card elevations, soft shadows, and immediate visual feedback for physical device interactions and audio recording.

---

## 2. Color Palette & Light Theme System   	 

### Background & Surface Hierarchy

Built around the user-selected light blue color scheme (`#E3F2FD`, `#90CAF9`, `#2196F3`, `#0D47A1`), creating clear depth and hierarchy.

| Elevation Level                      | Hex Code                 | Name / Purpose                                    |
| ------------------------------------ | ------------------------ | ------------------------------------------------- |
| **Base Background**            | `#F8FAFC` (Slate 50)   | Overall app background                            |
| **Surface Card (Level 1)**     | `#E3F2FD` (Blue 50)    | Primary container cards, dashboard widgets        |
| **Elevated Surface (Level 2)** | `#FFFFFF` (Pure White) | Active cards, elevated dialogs, text input fields |
| **Border & Dividers**          | `#90CAF9` (Blue 200)   | Card outlines, tab dividers, subtle borders       |

### Brand, Accent & Status Color Palette

| Category                        | Role                         | Color Name      | Hex Code    | Usage                                            |
| ------------------------------- | ---------------------------- | --------------- | ----------- | ------------------------------------------------ |
| **Light Blue Accent**     | Soft Backgrounds / Cards     | Ice Blue        | `#E3F2FD` | Card fill, subtle highlight areas                |
| **Mid Blue Accent**       | Borders / Secondary Controls | Soft Blue       | `#90CAF9` | Active tab borders, switch tracks, muted icons   |
| **Primary Brand**         | Primary Actions & Controls   | Vivid Blue      | `#2196F3` | Buttons, selected state, active telemetry values |
| **Deep Blue / Dark Text** | High Contrast Headings       | Royal Dark Blue | `#0D47A1` | Titles, key metrics, primary text elements       |
| **Success State**         | Device Online / Ack          | Forest Emerald  | `#059669` | Device "Online" badge, success toasts            |
| **Warning State**         | Intermittent / Lag           | Dark Amber      | `#D97706` | Signal warning, pending command state            |
| **Error / Voice Record**  | Device Offline / Mic Hot     | Crimson / Coral | `#DC2626` | Active mic recording button, offline alert       |

### Text & Typography Colors

| Type                     | Hex Code    | Opacity | Usage                                   |
| ------------------------ | ----------- | ------- | --------------------------------------- |
| **Primary Text**   | `#0D47A1` | 100%    | Main headings, key metrics, card titles |
| **Secondary Text** | `#1E3A8A` | 80%     | Subtitles, labels, descriptions         |
| **Muted Text**     | `#64748B` | 100%    | Timestamps, placeholder text, captions  |

---

## 3. Typography Guidelines

- **Primary Font Family:** Inter / Outfit (Google Fonts)
- **Hierarchy Rules:**
  - `Display Large`: 32px | Bold | Readouts & primary values (`24.5°C`) in `#0D47A1`
  - `Headline`: 20px | SemiBold | Section headers and main cards in `#0D47A1`
  - `Body Medium`: 14px | Regular | Status messages, body text in `#1E3A8A`
  - `Caption`: 12px | Medium | Timestamps and badges in `#64748B`

---

## 4. Key UI Elements & Interactive Components

### A. Device Connectivity & Status Badges

- **Online Badge:** Soft green fill with `#059669` text & pulsing green dot.
- **Offline Banner:** Light red alert banner (`#FEE2E2` bg, `#DC2626` text) at the top of the device screen.
- **Syncing Indicator:** Smooth `#2196F3` circular progress indicator.

### B. AI Voice Recorder Controls

- **Hero Record Button:** `#2196F3` Vivid Blue button that transitions to `#DC2626` Crimson with a soft red outer ring during live recording.
- **Real-Time Audio Waveform:** Dynamic visualizer bars in `#2196F3` and `#0D47A1`.
- **Live Transcription Card:** `#FFFFFF` white card with `#90CAF9` soft border and `#0D47A1` dark text.

### C. Device Control Panel (Actuators)

- **Light Theme Toggles:** Switch track in `#90CAF9` with active thumb in `#2196F3`.
- **Command Feedback:** Optimistic UI state update with a small `#0D47A1` spinner during MQTT ack waiting.

### D. History & Event Log Cards

- **Clean Log Cards:** White background (`#FFFFFF`) with `#E3F2FD` row hover/selection highlights and `#0D47A1` text.

---

## 5. Micro-Animations & Haptic Feedback

1. **Tap Feedback:** Haptic light impact on button presses.
2. **State Transition:** Smooth `AnimatedContainer` fade/scale transitions for offline/online switches.
3. **Data Refresh:** Smooth number counter animations when sensor values update in real-time.

---

## 6. Accessibility & Responsive Constraints

- **Minimum Touch Targets:** 48x48 dp for all interactive buttons.
- **Visual Contrast Ratio:** Meets WCAG AAA compliance for text on dark surfaces.
- **Colorblind Support:** All status indicators combine color with iconic shapes (e.g., green circle for online, red triangle for offline).
