import 'package:flutter/material.dart';
import 'package:project_2_graphs/data/models/splash/data_circle.dart';

class OptimizedCircle extends StatelessWidget {
  final CircleData circle;
  final double elapsed;
  final double containerWidth;

  const OptimizedCircle({
    super.key,
    required this.circle,
    required this.elapsed,
    required this.containerWidth,
  });

  @override
  Widget build(BuildContext context) {
    final left = _circleLeftOffset(circle.speed, containerWidth, elapsed);
    return Positioned(
      top: circle.top,
      left: left,
      child: Container(
        width: circle.size,
        height: circle.size,
        decoration: BoxDecoration(color: circle.color, shape: BoxShape.circle),
      ),
    );
  }

  double _circleLeftOffset(double speed, double width, double time) {
    return width - (time * speed) % (width + 100);
  }
}
