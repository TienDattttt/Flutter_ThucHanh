import 'package:eshop/core/constant/images.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/constant/colors.dart';

class InputFormButton extends StatelessWidget {
  final Function() onClick;
  final String? titleText;
  final Icon? icon;
  final Color? color;
  final double? cornerRadius;
  final EdgeInsets padding;
  final bool useGradient;

  const InputFormButton({
    super.key,
    required this.onClick,
    this.titleText,
    this.icon,
    this.color,
    this.cornerRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.useGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: useGradient && color != null
          ? BoxDecoration(
              gradient: LinearGradient(
                colors: [kGradientStart, kGradientEnd],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(cornerRadius ?? 12.0),
            )
          : null,
      child: ElevatedButton(
        onPressed: onClick,
        style: ButtonStyle(
          padding: WidgetStateProperty.all<EdgeInsets>(padding),
          maximumSize:
              WidgetStateProperty.all<Size>(Size(double.maxFinite, 28.sp)),
          minimumSize:
              WidgetStateProperty.all<Size>(Size(double.maxFinite, 28.sp)),
          backgroundColor: WidgetStateProperty.all<Color>(
              useGradient ? Colors.transparent : (color ?? Theme.of(context).primaryColor)),
          elevation: WidgetStateProperty.all<double>(0),
          shadowColor: WidgetStateProperty.all<Color>(Colors.transparent),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(cornerRadius ?? 12.0)),
          ),
        ),
        child: titleText != null
            ? Text(
                titleText!,
                style: const TextStyle(color: Colors.white),
              )
            : Image.asset(
                kFilterIcon,
                color: Colors.white,
                height: 22.sp,
                width: 22.sp,
              ),
      ),
    );
  }
}
