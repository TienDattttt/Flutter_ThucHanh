import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class QuickAddButton extends StatefulWidget {
  final VoidCallback onPressed;

  const QuickAddButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<QuickAddButton> createState() => _QuickAddButtonState();
}

class _QuickAddButtonState extends State<QuickAddButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                heroTag: "quick_add_fab",
                onPressed: () {
                  _animationController.forward().then((_) {
                    _animationController.reverse();
                  });
                  widget.onPressed();
                },
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                icon: const Icon(Icons.add, size: 24),
                label: const Text(
                  'Thêm giao dịch',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}