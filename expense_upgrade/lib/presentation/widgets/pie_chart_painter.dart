import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../domain/entities/chart_data.dart';

class PieChartPainter extends CustomPainter {
  final List<ChartData> data;
  final Animation<double> animation;
  final bool showLabels;
  final double strokeWidth;

  PieChartPainter({
    required this.data,
    required this.animation,
    this.showLabels = true,
    this.strokeWidth = 2.0,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.7;
    final total = data.fold(0.0, (sum, item) => sum + item.value);

    if (total == 0) return;

    double startAngle = -math.pi / 2;
    final animationValue = animation.value;

    // Draw pie slices with staggered animation
    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      
      // Staggered animation: each slice starts animating slightly after the previous one
      final staggerDelay = i * 0.1;
      final adjustedAnimationValue = math.max(0.0, math.min(1.0, 
          (animationValue - staggerDelay) / (1.0 - staggerDelay)));
      
      final sweepAngle = (item.value / total) * 2 * math.pi * adjustedAnimationValue;

      // Draw slice
      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw stroke
      final strokePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        strokePaint,
      );

      // Draw labels if enabled and animation is complete
      if (showLabels && animationValue > 0.8 && sweepAngle > 0.1) {
        _drawLabel(
          canvas,
          center,
          radius,
          startAngle + sweepAngle / 2,
          item,
          total,
        );
      }

      startAngle += sweepAngle;
    }

    // Draw center circle for donut effect
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.4, centerPaint);

    // Draw total amount in center
    if (animationValue > 0.5) {
      _drawCenterText(canvas, center, total);
    }
  }

  void _drawLabel(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    ChartData item,
    double total,
  ) {
    final percentage = (item.value / total * 100);
    if (percentage < 5) return; // Don't show labels for very small slices

    final labelRadius = radius + 30;
    final labelX = center.dx + labelRadius * math.cos(angle);
    final labelY = center.dy + labelRadius * math.sin(angle);

    // Draw line from slice to label
    final linePaint = Paint()
      ..color = item.color
      ..strokeWidth = 1.5;

    final lineStartX = center.dx + radius * 0.9 * math.cos(angle);
    final lineStartY = center.dy + radius * 0.9 * math.sin(angle);

    canvas.drawLine(
      Offset(lineStartX, lineStartY),
      Offset(labelX, labelY),
      linePaint,
    );

    // Draw label background
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${percentage.toStringAsFixed(1)}%',
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final labelRect = Rect.fromCenter(
      center: Offset(labelX, labelY),
      width: textPainter.width + 8,
      height: textPainter.height + 4,
    );

    final labelPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final labelStrokePaint = Paint()
      ..color = item.color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, const Radius.circular(4)),
      labelPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, const Radius.circular(4)),
      labelStrokePaint,
    );

    // Draw text
    textPainter.paint(
      canvas,
      Offset(
        labelX - textPainter.width / 2,
        labelY - textPainter.height / 2,
      ),
    );
  }

  void _drawCenterText(Canvas canvas, Offset center, double total) {
    // Draw "Tổng cộng" label
    final labelPainter = TextPainter(
      text: const TextSpan(
        text: 'Tổng cộng',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    labelPainter.layout();
    labelPainter.paint(
      canvas,
      Offset(
        center.dx - labelPainter.width / 2,
        center.dy - 20,
      ),
    );

    // Draw total amount
    final amountPainter = TextPainter(
      text: TextSpan(
        text: '${total.toStringAsFixed(0)} VNĐ',
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    amountPainter.layout();
    amountPainter.paint(
      canvas,
      Offset(
        center.dx - amountPainter.width / 2,
        center.dy + 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant PieChartPainter oldDelegate) {
    return oldDelegate.data != data ||
           oldDelegate.animation != animation ||
           oldDelegate.showLabels != showLabels ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}

class PieChart extends StatefulWidget {
  final List<ChartData> data;
  final bool showLabels;
  final double strokeWidth;
  final Duration animationDuration;

  const PieChart({
    Key? key,
    required this.data,
    this.showLabels = true,
    this.strokeWidth = 2.0,
    this.animationDuration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  State<PieChart> createState() => _PieChartState();
}

class _PieChartState extends State<PieChart>
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
  void didUpdateWidget(PieChart oldWidget) {
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
          painter: PieChartPainter(
            data: widget.data,
            animation: _animation,
            showLabels: widget.showLabels,
            strokeWidth: widget.strokeWidth,
          ),
          size: const Size(300, 300),
        );
      },
    );
  }
}