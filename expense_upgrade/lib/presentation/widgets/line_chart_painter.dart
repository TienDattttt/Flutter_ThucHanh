import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../domain/entities/chart_data.dart';

class LineChartPainter extends CustomPainter {
  final List<ChartData> data;
  final Animation<double> animation;
  final Color lineColor;
  final Color fillColor;
  final double strokeWidth;
  final bool showDots;
  final bool showGrid;

  LineChartPainter({
    required this.data,
    required this.animation,
    this.lineColor = Colors.blue,
    Color? fillColor,
    this.strokeWidth = 3.0,
    this.showDots = true,
    this.showGrid = true,
  }) : fillColor = fillColor ?? lineColor.withOpacity(0.1),
       super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final animationValue = animation.value;
    final padding = 40.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;

    // Find min and max values
    final values = data.map((e) => e.value).toList();
    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final valueRange = maxValue - minValue;

    if (valueRange == 0) return;

    // Draw grid if enabled
    if (showGrid) {
      _drawGrid(canvas, size, padding, chartWidth, chartHeight, minValue, maxValue);
    }

    // Calculate points
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = padding + (i / (data.length - 1)) * chartWidth;
      final normalizedValue = (data[i].value - minValue) / valueRange;
      final y = padding + chartHeight - (normalizedValue * chartHeight);
      points.add(Offset(x, y));
    }

    // Animate points
    final animatedPoints = <Offset>[];
    final pointCount = (points.length * animationValue).round();
    
    for (int i = 0; i < pointCount; i++) {
      if (i < points.length - 1) {
        animatedPoints.add(points[i]);
      } else if (i == pointCount - 1 && animationValue < 1.0) {
        // Interpolate the last point
        final progress = (animationValue * points.length) - i;
        final currentPoint = points[i];
        final nextPoint = i + 1 < points.length ? points[i + 1] : currentPoint;
        animatedPoints.add(Offset(
          currentPoint.dx + (nextPoint.dx - currentPoint.dx) * progress,
          currentPoint.dy + (nextPoint.dy - currentPoint.dy) * progress,
        ));
      }
    }

    if (animatedPoints.length < 2) return;

    // Draw filled area
    _drawFilledArea(canvas, animatedPoints, padding, chartHeight, fillColor);

    // Draw line
    _drawLine(canvas, animatedPoints, lineColor, strokeWidth);

    // Draw dots
    if (showDots && animationValue > 0.7) {
      _drawDots(canvas, animatedPoints, lineColor);
    }

    // Draw labels
    if (animationValue > 0.8) {
      _drawLabels(canvas, size, padding, chartWidth, chartHeight, minValue, maxValue);
    }
  }

  void _drawGrid(
    Canvas canvas,
    Size size,
    double padding,
    double chartWidth,
    double chartHeight,
    double minValue,
    double maxValue,
  ) {
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;

    // Horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = padding + (i / 4) * chartHeight;
      canvas.drawLine(
        Offset(padding, y),
        Offset(padding + chartWidth, y),
        gridPaint,
      );
    }

    // Vertical grid lines
    for (int i = 0; i <= 6; i++) {
      final x = padding + (i / 6) * chartWidth;
      canvas.drawLine(
        Offset(x, padding),
        Offset(x, padding + chartHeight),
        gridPaint,
      );
    }
  }

  void _drawFilledArea(
    Canvas canvas,
    List<Offset> points,
    double padding,
    double chartHeight,
    Color fillColor,
  ) {
    if (points.length < 2) return;

    final path = Path();
    path.moveTo(points.first.dx, padding + chartHeight);
    path.lineTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    path.lineTo(points.last.dx, padding + chartHeight);
    path.close();

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, fillPaint);
  }

  void _drawLine(
    Canvas canvas,
    List<Offset> points,
    Color lineColor,
    double strokeWidth,
  ) {
    if (points.length < 2) return;

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);
  }

  void _drawDots(Canvas canvas, List<Offset> points, Color dotColor) {
    final animationValue = animation.value;
    
    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Add subtle pulse effect to dots
    final pulseRadius = 4 + (math.sin(animationValue * math.pi * 4) * 0.5);

    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      
      // Staggered dot appearance
      final dotDelay = i * 0.05;
      final dotAnimationValue = math.max(0.0, math.min(1.0, 
          (animationValue - dotDelay) / (1.0 - dotDelay)));
      
      if (dotAnimationValue > 0) {
        final dotRadius = pulseRadius * dotAnimationValue;
        canvas.drawCircle(point, dotRadius + 1, strokePaint);
        canvas.drawCircle(point, dotRadius, dotPaint);
      }
    }
  }

  void _drawLabels(
    Canvas canvas,
    Size size,
    double padding,
    double chartWidth,
    double chartHeight,
    double minValue,
    double maxValue,
  ) {
    // Y-axis labels (values)
    for (int i = 0; i <= 4; i++) {
      final value = minValue + (maxValue - minValue) * (1 - i / 4);
      final y = padding + (i / 4) * chartHeight;

      final textPainter = TextPainter(
        text: TextSpan(
          text: value.toStringAsFixed(0),
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          padding - textPainter.width - 8,
          y - textPainter.height / 2,
        ),
      );
    }

    // X-axis labels (dates/categories)
    for (int i = 0; i < data.length; i += math.max(1, data.length ~/ 6)) {
      final x = padding + (i / (data.length - 1)) * chartWidth;
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: data[i].label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          x - textPainter.width / 2,
          padding + chartHeight + 8,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) {
    return oldDelegate.data != data ||
           oldDelegate.animation != animation ||
           oldDelegate.lineColor != lineColor ||
           oldDelegate.fillColor != fillColor ||
           oldDelegate.strokeWidth != strokeWidth ||
           oldDelegate.showDots != showDots ||
           oldDelegate.showGrid != showGrid;
  }
}

class LineChart extends StatefulWidget {
  final List<ChartData> data;
  final Color lineColor;
  final Color? fillColor;
  final double strokeWidth;
  final bool showDots;
  final bool showGrid;
  final Duration animationDuration;

  const LineChart({
    Key? key,
    required this.data,
    this.lineColor = Colors.blue,
    this.fillColor,
    this.strokeWidth = 3.0,
    this.showDots = true,
    this.showGrid = true,
    this.animationDuration = const Duration(milliseconds: 2000),
  }) : super(key: key);

  @override
  State<LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<LineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(LineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: LineChartPainter(
            data: widget.data,
            animation: _animation,
            lineColor: widget.lineColor,
            fillColor: widget.fillColor,
            strokeWidth: widget.strokeWidth,
            showDots: widget.showDots,
            showGrid: widget.showGrid,
          ),
          size: const Size(double.infinity, 250),
        );
      },
    );
  }
}