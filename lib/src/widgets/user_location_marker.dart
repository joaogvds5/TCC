import 'package:flutter/material.dart';
import 'package:nearu/src/widgets/map_marker_style.dart';

class UserLocationMarker extends StatefulWidget {
  final double? accuracyMeters;

  const UserLocationMarker({super.key, this.accuracyMeters});

  @override
  State<UserLocationMarker> createState() => _UserLocationMarkerState();
}

class _UserLocationMarkerState extends State<UserLocationMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: MapMarkerStyle.userMarkerSize,
        height: MapMarkerStyle.userMarkerSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Anel pulsante
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = _controller.value; // 0..1
                final size = MapMarkerStyle.userMarkerSize * (0.4 + 0.6 * t);
                final opacity = MapMarkerStyle.userMarkerPulseOpacity * (1 - t);
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: MapMarkerStyle.userMarkerColor.withValues(
                      alpha: opacity,
                    ),
                  ),
                );
              },
            ),
            Container(
              width:
                  MapMarkerStyle.userMarkerDotSize +
                  MapMarkerStyle.userMarkerBorderWidth * 2,
              height:
                  MapMarkerStyle.userMarkerDotSize +
                  MapMarkerStyle.userMarkerBorderWidth * 2,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: MapMarkerStyle.userMarkerBorderColor,
                boxShadow: [
                  BoxShadow(
                    color: MapMarkerStyle.shadowColor,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Container(
                width: MapMarkerStyle.userMarkerDotSize,
                height: MapMarkerStyle.userMarkerDotSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: MapMarkerStyle.userMarkerColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
