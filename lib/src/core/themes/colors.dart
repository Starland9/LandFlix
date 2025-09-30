import 'dart:ui';
import 'package:flutter/material.dart';

class AppColors {
  // Mode sombre (principal)
  static const darkBackground = Color(0xFF0A0A0F);
  static const darkSurface = Color(0xFF1A1A24);
  static const darkSurfaceVariant = Color(0xFF2A2A38);
  static const darkCard = Color(0xFF16161F);

  // Couleurs d'accent
  static const primaryPurple = Color(0xFF8B5DFF);
  static const primaryBlue = Color(0xFF3B82F6);
  static const accentTeal = Color(0xFF14B8A6);
  static const accentOrange = Color(0xFFFF8A00);

  // Gradients
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryPurple, primaryBlue],
  );

  static const cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A24), Color(0xFF2A2A38)],
  );

  static const shimmerGradient = LinearGradient(
    colors: [Color(0xFF2A2A38), Color(0xFF3A3A48), Color(0xFF2A2A38)],
  );

  // Couleurs de texte
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB0B0C0);
  static const textTertiary = Color(0xFF808090);

  // Couleurs système
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);

  // Mode clair (pour future implémentation)
  static const lightBackground = Color(0xFFF8FAFC);
  static const lightSurface = Color(0xFFFFFFFF);

  // Couleurs héritées pour compatibilité
  static const background = darkBackground;
}
