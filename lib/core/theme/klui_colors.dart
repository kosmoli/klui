import 'package:flutter/material.dart';

/// Klui Design System Colors
/// CRT Retro Terminal Theme - Fluorescent Green on Dark Background
class KluiColors {
  // Private constructor to prevent instantiation
  KluiColors._();

  // Backgrounds - Darker for CRT effect
  static const background = Color(0xFF0A0E0A); // Very dark green-tinted black
  static const surface = Color(0xFF0F140F); // Slightly lighter panel
  static const surfaceVariant = Color(0xFF1A251A); // Input/bg variant

  // Primary - CRT Fluorescent Green (#33FF33 style)
  static const userBubble = Color(0xFF00FF41); // Classic terminal green
  static const userText = Color(0xFF001A05); // Near black for contrast on green

  // Assistant Message - Dimmed green variant
  static const assistantBubble = Color(0xFF0F140F); // Panel
  static const assistantText = Color(0xFF98C998); // Muted green text

  // Status Indicators - Green-themed palette
  static const statusStreaming = Color(0xFF4A7A4A); // Dim green
  static const statusReady = Color(0xFFCCFF33); // Yellow-green - blinking
  static const statusRunning = Color(0xFF99FF33); // Bright green-yellow - blinking
  static const statusSuccess = Color(0xFF00FF41); // Fluorescent green - solid
  static const statusError = Color(0xFFFF3344); // CRT red - solid

  // Tool Accents - Green monochrome with value variations
  static const toolBash = Color(0xFFFF6B6B); // Red accent for danger
  static const toolFile = Color(0xFF66FF99); // Bright green
  static const toolSearch = Color(0xFF99FFAA); // Light cyan-green
  static const toolMemory = Color(0xFFCCFFDD); // Pale mint

  // Semantic
  static const reasoning = Color(0xFF5A8A5A); // Muted green-gray
  static const error = Color(0xFFFF3344); // CRT red
  static const success = Color(0xFF00FF41); // Fluorescent green
  static const warning = Color(0xFFCCFF33); // Yellow-green

  // Borders - Subtle green tint
  static const border = Color(0xFF2A3A2A); // Dark green-gray
  static const borderFocus = Color(0xFF00FF41); // Fluorescent green

  // Text - Green-tinted grays
  static const textPrimary = Color(0xFFB8E8C8); // Light green-gray
  static const textSecondary = Color(0xFF6A8A6A); // Dim green-gray
}
