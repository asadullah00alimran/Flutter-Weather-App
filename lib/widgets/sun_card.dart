import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SunCardWidget extends StatelessWidget {
  final DateTime? sunrise;
  final DateTime? sunset;

  const SunCardWidget({
    super.key,
    required this.sunrise,
    required this.sunset,
  });

  @override
  Widget build(BuildContext context) {
    if (sunrise == null || sunset == null) return const SizedBox.shrink();

    final sunriseStr = DateFormat('h:mm a').format(sunrise!);
    final sunsetStr = DateFormat('h:mm a').format(sunset!);

    final duration = sunset!.difference(sunrise!);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final dayLengthStr = '${hours}h ${minutes}m daylight';

    // Calculate current sun progress if daytime
    final now = DateTime.now();
    double sunProgress = 0.0;
    if (now.isAfter(sunrise!) && now.isBefore(sunset!)) {
      final total = sunset!.difference(sunrise!).inSeconds;
      final current = now.difference(sunrise!).inSeconds;
      sunProgress = (current / total).clamp(0.0, 1.0);
    } else if (now.isAfter(sunset!)) {
      sunProgress = 1.0;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.wb_twilight_rounded, size: 18, color: Colors.white70),
                  SizedBox(width: 8),
                  Text(
                    'SUNRISE & SUNSET',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Text(
                dayLengthStr,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Sun progress arc visualization
          SizedBox(
            height: 50,
            child: CustomPaint(
              painter: _SunArcPainter(progress: sunProgress),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sunrise',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  Text(
                    sunriseStr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Sunset',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                  Text(
                    sunsetStr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SunArcPainter extends CustomPainter {
  final double progress;

  _SunArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final arcPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final baseLinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw horizon baseline
    canvas.drawLine(
      Offset(10, size.height - 2),
      Offset(size.width - 10, size.height - 2),
      baseLinePaint,
    );

    // Draw arc
    final path = Path();
    path.moveTo(20, size.height - 2);
    path.quadraticBezierTo(
      size.width / 2,
      -10,
      size.width - 20,
      size.height - 2,
    );
    canvas.drawPath(path, arcPaint);

    // Draw active sun position
    if (progress > 0) {
      final t = progress;
      final p0 = Offset(20, size.height - 2);
      final p1 = Offset(size.width / 2, -10);
      final p2 = Offset(size.width - 20, size.height - 2);

      final sunX = (1 - t) * (1 - t) * p0.dx + 2 * (1 - t) * t * p1.dx + t * t * p2.dx;
      final sunY = (1 - t) * (1 - t) * p0.dy + 2 * (1 - t) * t * p1.dy + t * t * p2.dy;

      final sunPaint = Paint()
        ..color = const Color(0xFFFFD54F)
        ..style = PaintingStyle.fill;

      final sunGlowPaint = Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: 0.35)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(sunX, sunY), 10, sunGlowPaint);
      canvas.drawCircle(Offset(sunX, sunY), 5, sunPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SunArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
