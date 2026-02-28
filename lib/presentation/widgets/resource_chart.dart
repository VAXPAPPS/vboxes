import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A simple real-time line chart for CPU/Memory resources.
/// Draws using CustomPainter — no external charting library needed.
class ResourceChart extends StatelessWidget {
  final List<double> values; // 0.0 to 100.0
  final Color color;
  final String label;
  final double currentValue;

  const ResourceChart({
    super.key,
    required this.values,
    required this.color,
    required this.label,
    required this.currentValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.white60),
            ),
            const Spacer(),
            Text(
              '${currentValue.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: CustomPaint(
            painter: _ChartPainter(values: values, color: color),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> values;
  final Color color;

  const _ChartPainter({required this.values, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / math.max(values.length - 1, 1);

    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height - (values[i].clamp(0.0, 100.0) / 100.0) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevY = size.height - (values[i - 1].clamp(0.0, 100.0) / 100.0) * size.height;
        final cpX = (prevX + x) / 2;
        path.cubicTo(cpX, prevY, cpX, y, x, y);
        fillPath.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.values != values || old.color != color;
}
