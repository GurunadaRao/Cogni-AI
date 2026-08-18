import 'package:flutter/material.dart';

/// Professional Design Tokens & Color System — EchoClip Workspace (Light & Dark)
class AppColors {
  AppColors._();

  // ── Light Theme Colors ─────────────────────────────────────────
  static const Color lightBackground       = Color(0xFFF8FAFC); // Slate 50
  static const Color lightSurface          = Color(0xFFFFFFFF); // White Card
  static const Color lightElevatedSurface  = Color(0xFFF1F5F9); // Slate 100
  static const Color lightBorderSubtle     = Color(0xFFE2E8F0); // Slate 200 Border

  static const Color lightTextPrimary      = Color(0xFF0F172A); // Slate 900
  static const Color lightTextSecondary    = Color(0xFF475569); // Slate 600
  static const Color lightTextMuted        = Color(0xFF64748B); // Slate 500

  // ── Dark Theme Colors ──────────────────────────────────────────
  static const Color darkBackground        = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface           = Color(0xFF1E293B); // Slate 800
  static const Color darkElevatedSurface   = Color(0xFF334155); // Slate 700
  static const Color darkBorderSubtle      = Color(0xFF334155); // Slate 700 Border

  static const Color darkTextPrimary       = Color(0xFFF8FAFC); // Slate 50
  static const Color darkTextSecondary     = Color(0xFF94A3B8); // Slate 400
  static const Color darkTextMuted         = Color(0xFF64748B); // Slate 500

  // ── Brand Accent (Cobalt / Sky Blue) ───────────────────────────
  static const Color accent                = Color(0xFF0284C7); // Sky Blue 600
  static const Color accentLight            = Color(0xFF38BDF8); // Sky Blue 400

  // ── Recording State Colors ─────────────────────────────────────
  static const Color recordingRed          = Color(0xFFEF4444); // Crimson Red
  static const Color recordingBg           = Color(0xFFFEF2F2); // Red 50

  // ── Status Indicators ──────────────────────────────────────────
  static const Color statusConnected       = Color(0xFF10B981); // Emerald 500
  static const Color statusConnecting      = Color(0xFBF59E0B); // Amber 500
  static const Color statusError           = Color(0xFFEF4444); // Red 500

  // Legacy Compatibility Defaults (Light Mode Defaults)
  static const Color background       = lightBackground;
  static const Color surface          = lightSurface;
  static const Color elevatedSurface  = lightElevatedSurface;
  static const Color borderSubtle     = lightBorderSubtle;
  static const Color textPrimary      = lightTextPrimary;
  static const Color textSecondary    = lightTextSecondary;
  static const Color textMuted        = lightTextMuted;

  static const Color navyDark      = darkBackground;
  static const Color navyMedium    = darkSurface;
  static const Color navyCard      = darkElevatedSurface;
  static const Color primary       = accent;
  static const Color primaryDark   = accent;
  static const Color primaryDeep   = accent;
  static const Color iceBlue       = lightElevatedSurface;
  static const Color softBlue      = lightBorderSubtle;
  static const Color surfaceCard   = lightSurface;
  static const Color borderDivider = lightBorderSubtle;
  static const Color success       = statusConnected;
  static const Color successBackground = Color(0xFFD1FAE5);
  static const Color error         = statusError;
  static const Color errorBackground   = Color(0xFFFEE2E2);
  static const Color recording     = recordingRed;
}
