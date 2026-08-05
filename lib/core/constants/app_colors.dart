import 'package:flutter/material.dart';

/// App-wide Color Palette — EchoClip
class AppColors {
  AppColors._();

  // ── Backgrounds ────────────────────────────────────────────────
  static const Color background    = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceCard   = Color(0xFFE3F2FD); // Ice Blue
  static const Color elevatedSurface = Color(0xFFFFFFFF);
  static const Color borderDivider = Color(0xFF90CAF9); // Blue 200

  // ── Dark Navy (recording / splash) ─────────────────────────────
  static const Color navyDark      = Color(0xFF0A1628);
  static const Color navyMedium   = Color(0xFF0D2137);
  static const Color navyCard     = Color(0xFF142940);

  // ── Brand & Accent ─────────────────────────────────────────────
  static const Color primary       = Color(0xFF2196F3);
  static const Color primaryDark   = Color(0xFF0D47A1);
  static const Color primaryDeep   = Color(0xFF1565C0);
  static const Color iceBlue       = Color(0xFFE3F2FD);
  static const Color softBlue      = Color(0xFF90CAF9);

  // ── Status ─────────────────────────────────────────────────────
  static const Color success           = Color(0xFF10B981);
  static const Color successBackground = Color(0xFFD1FAE5);
  static const Color warning           = Color(0xFFD97706);
  static const Color warningBackground = Color(0xFFFEF3C7);
  static const Color error             = Color(0xFFEF4444);
  static const Color errorBackground   = Color(0xFFFEE2E2);

  // ── Text ───────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF0D47A1);
  static const Color textSecondary = Color(0xFF1E3A8A);
  static const Color textMuted     = Color(0xFF64748B);

  // ── Semantic aliases ───────────────────────────────────────────
  static const Color online  = success;
  static const Color offline = error;
  static const Color recording = Color(0xFFEF4444);
}
