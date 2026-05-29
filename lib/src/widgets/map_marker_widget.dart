import 'package:flutter/material.dart';
import 'package:nearu/src/widgets/map_marker_style.dart';

/// Widget que renderiza um marcador no mapa
class MapMarkerWidget extends StatelessWidget {
  final String title;
  final String description;
  final int categoryId;
  final double heat;
  final VoidCallback? onTap;

  const MapMarkerWidget({
    super.key,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.heat,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = MapMarkerStyle.getCategoryColor(categoryId);
    final heatOpacity = MapMarkerStyle.getHeatOpacity(heat);
    final categoryName = MapMarkerStyle.getCategoryName(categoryId);
    final categoryIcon = MapMarkerStyle.getCategoryIcon(categoryId);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Card principal
          Container(
            width: MapMarkerStyle.markerWidth,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: MapMarkerStyle.cardBackground,
              borderRadius: BorderRadius.circular(MapMarkerStyle.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: MapMarkerStyle.shadowColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: categoryColor.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cabeçalho: ícone + categoria + badge de calor
                Row(
                  children: [
                    // Ícone da categoria
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(categoryIcon, size: 16, color: categoryColor),
                    ),
                    const SizedBox(width: 6),

                    // Nome da categoria
                    Expanded(
                      child: Text(
                        categoryName,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: categoryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Badge de calor (se houver mais de 1 evento)
                    if (heat > 0.1)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: MapMarkerStyle.heatBadgeColor.withValues(
                            alpha: heatOpacity,
                          ),
                          borderRadius: BorderRadius.circular(
                            MapMarkerStyle.heatBadgeRadius,
                          ),
                        ),
                        child: Text(
                          '🔥 ${(heat * 10).round()}',
                          style: const TextStyle(
                            fontSize: MapMarkerStyle.heatFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 6),

                // Título
                Text(
                  title,
                  maxLines: MapMarkerStyle.titleMaxLines,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: MapMarkerStyle.titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                // Descrição (se existir)
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    description,
                    maxLines: MapMarkerStyle.descriptionMaxLines,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: MapMarkerStyle.descriptionFontSize,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Seta/pino apontando para baixo
          CustomPaint(
            size: const Size(20, 10),
            painter: _MarkerTrianglePainter(color: categoryColor),
          ),
        ],
      ),
    );
  }
}

/// Pinta o triângulo inferior do marcador
class _MarkerTrianglePainter extends CustomPainter {
  final Color color;

  _MarkerTrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height) // ponta inferior
      ..lineTo(0, 0) // canto superior esquerdo
      ..lineTo(size.width, 0) // canto superior direito
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
