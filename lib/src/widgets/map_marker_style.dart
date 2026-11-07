// lib/src/widgets/map_marker_style.dart
import 'package:flutter/material.dart';

/// Estilos e constantes para os marcadores do mapa
class MapMarkerStyle {
  // ============================================
  // Marcadores de eventos
  // ============================================
  static const double markerWidth = 150.0;
  static const double markerHeight = 120.0;

  /// Cores por categoria (id do interesse)
  static const Map<int, Color> categoryColors = {
    1: Color(0xFFE91E63), // Música - rosa
    2: Color(0xFF2196F3), // Tecnologia - azul
    3: Color(0xFFFF9800), // Comida - laranja
    4: Color(0xFF4CAF50), // Natureza - verde
    5: Color(0xFF9C27B0), // Cultura - roxo
    6: Color(0xFF00BCD4), // Viagem - ciano
    7: Color(0xFF795548), // Estudar - marrom
    8: Color(0xFF607D8B), // Outros - cinza azulado
  };

  static const Color defaultCategoryColor = Color(0xFF607D8B);
  static const Color heatBadgeColor = Color(0xFFFF5722);
  static const Color cardBackground = Colors.white;
  static const Color shadowColor = Colors.black26;

  // Bordas
  static const double borderRadius = 12.0;
  static const double heatBadgeRadius = 16.0;

  // Tipografia
  static const double titleFontSize = 13.0;
  static const double descriptionFontSize = 11.0;
  static const double heatFontSize = 10.0;
  static const int titleMaxLines = 1;
  static const int descriptionMaxLines = 2;

  // Heat (intensidade)
  static const double lowHeatOpacity = 0.5;
  static const double mediumHeatOpacity = 0.75;
  static const double highHeatOpacity = 1.0;

  // ============================================
  // Marcador do usuário (posição atual)
  // ============================================
  static const double userMarkerSize = 44.0;
  static const double userMarkerDotSize = 14.0;
  static const Color userMarkerColor = Color(0xFF2196F3); // azul
  static const Color userMarkerBorderColor = Colors.white;
  static const double userMarkerBorderWidth = 3.0;
  static const double userMarkerPulseOpacity = 0.25;

  // ============================================
  // Helpers
  // ============================================
  static Color getCategoryColor(int categoryId) {
    return categoryColors[categoryId] ?? defaultCategoryColor;
  }

  static double getHeatOpacity(double intensity) {
    if (intensity >= 0.8) return highHeatOpacity;
    if (intensity >= 0.4) return mediumHeatOpacity;
    return lowHeatOpacity;
  }

  static IconData getCategoryIcon(int categoryId) {
    switch (categoryId) {
      case 1:
        return Icons.music_note;
      case 2:
        return Icons.computer;
      case 3:
        return Icons.restaurant;
      case 4:
        return Icons.park;
      case 5:
        return Icons.theater_comedy;
      case 6:
        return Icons.flight;
      case 7:
        return Icons.school;
      case 8:
        return Icons.category;
      default:
        return Icons.place;
    }
  }

  static String getCategoryName(int categoryId) {
    switch (categoryId) {
      case 1:
        return 'Música';
      case 2:
        return 'Tecnologia';
      case 3:
        return 'Comida';
      case 4:
        return 'Natureza';
      case 5:
        return 'Cultura';
      case 6:
        return 'Viagem';
      case 7:
        return 'Estudar';
      case 8:
        return 'Outros';
      default:
        return 'Outros';
    }
  }
}
