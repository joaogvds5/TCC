import 'package:flutter/material.dart';

/// Estilos e constantes para os marcadores do mapa
class MapMarkerStyle {
  // Dimensões
  static const double markerWidth = 150.0;
  static const double markerHeight = 120.0;

  // Cores por categoria
  static const Map<int, Color> categoryColors = {
    1: Color(0xFF4CAF50), // Evento - verde
    2: Color(0xFFE91E63), // Música - rosa
    3: Color(0xFF2196F3), // Esporte - azul
    4: Color(0xFFFF9800), // Feira - laranja
    5: Color(0xFF9C27B0), // Tecnologia - roxo
  };

  static const Color defaultCategoryColor = Color(0xFF607D8B); // Cinza azulado
  static const Color heatBadgeColor = Color(0xFFFF5722); // Laranja forte
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

  /// Retorna a cor correspondente à categoria
  static Color getCategoryColor(int categoryId) {
    return categoryColors[categoryId] ?? defaultCategoryColor;
  }

  /// Retorna a opacidade baseada na intensidade (heat)
  static double getHeatOpacity(double intensity) {
    if (intensity >= 0.8) return highHeatOpacity;
    if (intensity >= 0.4) return mediumHeatOpacity;
    return lowHeatOpacity;
  }

  /// Retorna o ícone correspondente à categoria
  static IconData getCategoryIcon(int categoryId) {
    switch (categoryId) {
      case 1:
        return Icons.event;
      case 2:
        return Icons.music_note;
      case 3:
        return Icons.sports_soccer;
      case 4:
        return Icons.store;
      case 5:
        return Icons.computer;
      default:
        return Icons.place;
    }
  }

  /// Retorna o nome da categoria
  static String getCategoryName(int categoryId) {
    switch (categoryId) {
      case 1:
        return 'Evento';
      case 2:
        return 'Música';
      case 3:
        return 'Esporte';
      case 4:
        return 'Feira';
      case 5:
        return 'Tecnologia';
      default:
        return 'Outro';
    }
  }
}
