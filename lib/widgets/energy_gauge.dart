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
    with TickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 1800);
  static const _curve = Curves.easeOutCubic;
  static const _minGlowDuration = Duration(milliseconds: 2500);
  static const _maxGlowDuration = Duration(milliseconds: 8000);
  static const _basePercentage = 0.4;
  static const _glowPauseDuration = Duration(seconds: 5);

  late AnimationController _controller;
  late Animation<double> _fillAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  double _targetPercentage = 0.0;
  int _glowGeneration = 0;
  bool _glowPaused = false;

  Duration _glowDurationFor(double pct) {
    final clamped = pct.clamp(0.05, 1.0);
    final ms = (_minGlowDuration.inMilliseconds * _basePercentage / clamped)
        .round()
        .clamp(
            _minGlowDuration.inMilliseconds, _maxGlowDuration.inMilliseconds);
    return Duration(milliseconds: ms);
  }

  void _startGlowLoop() {
    setState(() => _glowPaused = false);
    _glowController.forward(from: 0);
  }

  void _setupGlowController(double pct) {
    _glowGeneration++;
    _glowController.removeStatusListener(_onGlowStatusChanged);
    _glowController.dispose();
    _glowController = AnimationController(
      vsync: this,
      duration: _glowDurationFor(pct),
    );
    _glowController.addStatusListener(_onGlowStatusChanged);
    _glowAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _glowController, curve: Curves.linear));
    _startGlowLoop();
  }

  void _onGlowStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      setState(() => _glowPaused = true);
      final gen = _glowGeneration;
      Future.delayed(_glowPauseDuration, () {
        if (mounted && _glowGeneration == gen) _startGlowLoop();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
    _glowController = AnimationController(
      vsync: this,
      duration: _glowDurationFor(widget.percentage),
    );
    _glowController.addStatusListener(_onGlowStatusChanged);
    _glowAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _glowController, curve: Curves.linear));
    _targetPercentage = widget.percentage;
    _startGlowLoop();
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
      _setupGlowController(widget.percentage);
    }
  }

  @override
  void dispose() {
    _glowController.removeStatusListener(_onGlowStatusChanged);
    EnergyState().lastDisplayedPercentageForGauge = _fillAnimation.value;
    _controller.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final height = size * 0.4;

    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _glowController]),
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
                painter: _FlatGaugePainter(
                  percentage: displayValue,
                  glowProgress: _glowAnimation.value,
                  glowVisible: !_glowPaused,
                ),
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
  final double glowProgress;
  final bool glowVisible;

  _FlatGaugePainter({
    required this.percentage,
    this.glowProgress = 0.0,
    this.glowVisible = true,
  });

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

      if (glowVisible) {
        // StrokeCap.round strekt zich uit met ~strokeWidth/2 aan begin én einde
        final capExtensionAngle = (strokeWidth / 2) / radius;
        final progressSweepWithCaps = progressSweep + 2 * capExtensionAngle;
        final startAngleWithCap = startAngle - capExtensionAngle;

        const glowWidth = 0.2;
        final glowSweep = glowWidth * totalSweepAngle;
        final travelLength = (progressSweepWithCaps + glowSweep)
            .clamp(0.2, totalSweepAngle * 1.3);
        final glowPos =
            (glowProgress * travelLength) % travelLength - glowSweep * 0.5;
        final glowStartAngle = startAngleWithCap + glowPos;

        final innerR = radius - strokeWidth * 0.5;
        final outerR = radius + strokeWidth * 0.5;
        final clipPath = Path()
          ..arcTo(
            Rect.fromCircle(center: center, radius: outerR),
            startAngleWithCap,
            progressSweepWithCaps,
            false,
          )
          ..arcTo(
            Rect.fromCircle(center: center, radius: innerR),
            startAngleWithCap + progressSweepWithCaps,
            -progressSweepWithCaps,
            false,
          )
          ..close();

        canvas.save();
        canvas.clipPath(clipPath);

        // Fade-in: gloed komt zacht binnen in de eerste ~15% van de reis
        const fadeInFraction = 0.15;
        final posInTravel =
            ((glowProgress * travelLength) % travelLength) / travelLength;
        final opacity = posInTravel < fadeInFraction
            ? (posInTravel / fadeInFraction) * 0.45
            : 0.45;

        final glowPaint = Paint()
          ..color = Colors.white.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth * 1.15
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          glowStartAngle,
          glowSweep,
          false,
          glowPaint,
        );

        canvas.restore();
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
  bool shouldRepaint(covariant _FlatGaugePainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.glowProgress != glowProgress ||
        oldDelegate.glowVisible != glowVisible;
  }
}
