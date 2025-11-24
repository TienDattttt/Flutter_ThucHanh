import 'package:flutter/material.dart';

import '../../core/constant/colors.dart';

class FavoriteIconButton extends StatelessWidget {
  const FavoriteIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: kLightPrimaryColor,
          shape: const CircleBorder(),
          elevation: 0,
          padding: const EdgeInsets.all(4),
        ),
        child: const Icon(
          Icons.favorite_border,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}
