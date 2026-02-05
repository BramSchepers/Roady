import 'dart:math';
import 'package:flutter/material.dart';
import '../models/energy_state.dart';

class EnergyGauge extends StatefulWidget {
  final double percentage; // 0.0 to 1.0
  final double size;

  const EnergyGauge({
    super.key,
    required this.percentage,
    this.size = 300, // Standaard wat breder
  });

  @override
  State<EnergyGauge> createState() => _EnergyGaugeState();
}

class _EnergyGaugeState extends State<EnergyGauge>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 1800);
  static const _curve = Curves.easeOutCubic;

  late AnimationController _controller;
  late Animation<double> _fillAnimation;
  double _targetPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
    _targetPercentage = widget.percentage;
    // Animeer van laatst getoonde waarde (op home) naar actuele progress
    final startValue = EnergyState().lastDisplayedPercentageForGauge;
    _fillAnimation = Tween<double>(begin: startValue, end: widget.percentage)
        .animate(CurvedAnimation(parent: _controller, curve: _curve));
    _controller.forward(from: 0.0); // Vul-animatie zodra je op home bent
  }

  @override
  void didUpdateWidget(EnergyGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.percentage != _targetPercentage) {
      _targetPercentage = widget.percentage;
      _fillAnimation = Tween<double>(
        begin: _fillAnimation.value,
        end: widget.percentage,
      ).animate(CurvedAnimation(parent: _controller, curve: _curve));
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    EnergyState().lastDisplayedPercentageForGauge = _fillAnimation.value;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final height = size * 0.4;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final displayValue = _fillAnimation.value;
        Color statusColor;
        if (displayValue > 0.6) {
          statusColor = Colors.green;
        } else if (displayValue > 0.3) {
          statusColor = Colors.orange;
        } else {
          statusColor = Colors.red;
        }

        return SizedBox(
          width: size,
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              CustomPaint(
                size: Size(size, height),
                painter: _FlatGaugePainter(percentage: displayValue),
              ),
              Positioned(
                bottom: -28,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.local_gas_station, color: statusColor, size: 28),
                    const SizedBox(height: 4),
                    Text(
                      '${(displayValue * 100).round().clamp(0, 100)}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.0,
                      ),
                    ),
                    const Text(
                      'Brandstof',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FlatGaugePainter extends CustomPainter {
  final double percentage;

  _FlatGaugePainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width * 0.85;
    final center = Offset(size.width / 2, radius + (size.height * 0.1));

    const totalSweepAngle = 2.0;
    const startAngle = -pi / 2 - (totalSweepAngle / 2);

    const strokeWidth = 20.0;

    // Achtergrond (Grijs)
    final bgPaint = Paint()
      ..color = Colors.grey[100]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweepAngle,
      false,
      bgPaint,
    );

    // Gradient: kort rood, vloeiende overgang naar oranje en groen
    const gradientColors = [
      Color(0xFFFF5252), // Rood
      Color(0xFFFF5252), // Rood
      Color(0xFFFFB74D), // Oranje
      Color(0xFF69F0AE), // Groen
    ];

    final sweepFraction = totalSweepAngle / (2 * pi);
    final gradient = SweepGradient(
      colors: gradientColors,
      stops: [
        0.0,
        0.06, // Kort rood stukje aan het begin
        sweepFraction * 0.4, // Oranje in het midden
        sweepFraction,
      ],
      transform: GradientRotation(startAngle),
      tileMode: TileMode.clamp,
    );

    final fgPaint = Paint()
      ..shader =
          gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressSweep = totalSweepAngle * percentage;

    if (percentage > 0) {
      // Rood stuk aan het begin (zonder gradient) om groen/gradient-bleed aan de start te voorkomen
      const redCapLength = 0.07;
      final redPaint = Paint()
        ..color = const Color(0xFFFF5252)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      if (progressSweep > redCapLength) {
        // Eerst gradient tekenen, daarna rode cap erover zodat er geen groen piept
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle + redCapLength,
          progressSweep - redCapLength,
          false,
          fgPaint,
        );
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          redCapLength,
          false,
          redPaint,
        );
      } else {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          progressSweep,
          false,
          redPaint,
        );
      }
    }

    // Streepjes (Ticks)
    final tickPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 2;

    const tickCount = 8;
    for (int i = 0; i <= tickCount; i++) {
      final angle = startAngle + (totalSweepAngle * (i / tickCount));

      final innerRadius = radius - 30;
      final outerRadius = radius - 22;

      final p1 = Offset(
        center.dx + innerRadius * cos(angle),
        center.dy + innerRadius * sin(angle),
      );
      final p2 = Offset(
        center.dx + outerRadius * cos(angle),
        center.dy + outerRadius * sin(angle),
      );

      canvas.drawLine(p1, p2, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
