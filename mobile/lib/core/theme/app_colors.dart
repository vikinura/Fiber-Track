import 'package:flutter/material.dart';

class AppColors {
  // Brand & Seed
  static const Color primarySeed = Color(0xFF0D47A1); // Deep Indigo/Blue
  static const Color primary = Color(0xFF1565C0);
  static const Color secondary = Color(0xFF00897B);

  // Neutral Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF252525);

  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);

  // Semantic Status Colors
  static const Color statusNew = Color(0xFF0288D1); // Biru (Baru)
  static const Color statusForwarded = Color(0xFF7B1FA2); // Ungu (Diteruskan)
  static const Color statusAssigned = Color(0xFFF57C00); // Oranye (Ditugaskan)
  static const Color statusInProgress = Color(
    0xFFE65100,
  ); // Oranye Tua (Sedang Dikerjakan)
  static const Color statusResolved = Color(0xFF2E7D32); // Hijau (Selesai)

  // SLA Colors
  static const Color slaSafe = Color(0xFF2E7D32);
  static const Color slaAtRisk = Color(0xFFF57C00);
  static const Color slaOverdue = Color(0xFFD32F2F);
  static const Color slaBreached = Color(0xFFC2185B);
}
