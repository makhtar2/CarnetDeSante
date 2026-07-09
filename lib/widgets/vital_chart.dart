import 'package:flutter/material.dart';

class VitalChart extends StatelessWidget {
  const VitalChart({
    super.key,
    required this.values,
    required this.labels,
    this.color = const Color(0xFF0F766E),
  });

  final List<double> values;
  final List<String> labels;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return Container(
        height: 140,
        alignment: Alignment.center,
        child: const Text(
          'Pas de données pour afficher la courbe d\'évolution',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
      );
    }

    return Container(
      height: 160,
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
      ),
      child: CustomPaint(
        size: Size.infinite,
        painter: _ChartPainter(values: values, labels: labels, color: color),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.values,
    required this.labels,
    required this.color,
  });

  final List<double> values;
  final List<String> labels;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Calculer min/max pour l'échelle
    double maxVal = values.reduce((curr, next) => curr > next ? curr : next);
    double minVal = values.reduce((curr, next) => curr < next ? curr : next);

    if (maxVal == minVal) {
      maxVal += 10.0;
      minVal -= 10.0;
    } else {
      final diff = maxVal - minVal;
      maxVal += diff * 0.15;
      minVal -= diff * 0.15;
    }

    final double range = maxVal - minVal;

    // 2. Peindre la grille de fond
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1.0;

    const int gridLines = 3;
    for (int i = 0; i <= gridLines; i++) {
      final double y = size.height * (i / gridLines);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 3. Calculer les points à dessiner
    final double stepX =
        size.width / (values.length - 1 == 0 ? 1 : values.length - 1);
    final List<Offset> points = [];

    for (int i = 0; i < values.length; i++) {
      final double x = i * stepX;
      final double normalizedY = (values[i] - minVal) / range;
      final double y = size.height - (normalizedY * size.height);
      points.add(Offset(x, y));
    }

    // 4. Dessiner l'ombrage sous la courbe
    final fillPath = Path();
    fillPath.moveTo(0, size.height);
    for (final point in points) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // 5. Dessiner la ligne de la courbe
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);

    // 6. Dessiner les points (cercles avec halo)
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (final point in points) {
      // Glow
      canvas.drawCircle(
        point,
        6.0,
        Paint()..color = color.withValues(alpha: 0.15),
      );
      // Point blanc
      canvas.drawCircle(point, 3.5, dotPaint);
      // Bordure colorée
      canvas.drawCircle(point, 3.5, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
