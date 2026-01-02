import 'package:flutter/material.dart';
import 'package:ps_institute/config/palette.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color color;

  const LoadingIndicator({
    super.key,
    this.size = 30,
    this.strokeWidth = 3,
    this.color = Palette.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: CircularProgressIndicator(
          color: color,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}
