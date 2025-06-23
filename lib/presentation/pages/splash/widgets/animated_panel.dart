import 'package:flutter/material.dart';
import 'package:project_2_graphs/data/models/splash/data_circle_model.dart';
import 'dart:math';

class AnimatedColorPanel extends StatefulWidget {
  final double height;
  final double width;
  final Duration duration;
  final int circleCount;

  const AnimatedColorPanel({
    super.key,
    required this.height,
    required this.width,
    required this.duration,
    this.circleCount = 20,
  });

  @override
  State<AnimatedColorPanel> createState() => _AnimatedColorPanelState();
}

class _AnimatedColorPanelState extends State<AnimatedColorPanel>
    with SingleTickerProviderStateMixin {
  final Random random = Random();
  late List<CircleData> circles;

  @override
  void initState() {
    super.initState();
    _generateCircles();
    _startAnimationLoop();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Stack(
        children: circles.map((circle) {
          return AnimatedPositioned(
            duration: widget.duration,
            left: circle.left,
            top: circle.top,
            child: AnimatedContainer(
              duration: widget.duration,
              width: circle.size,
              height: circle.size,
              decoration: BoxDecoration(
                color: circle.color.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _generateCircles() {
    circles = List.generate(widget.circleCount, (_) => _randomCircle());
  }

  CircleData _randomCircle() {
    return CircleData(
      left: random.nextDouble() * widget.width,
      top: random.nextDouble() * widget.height,
      color: Color.fromARGB(
        255,
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
      ),
      size: random.nextDouble() * 40 + 10,
    );
  }

  void _startAnimationLoop() async {
    while (mounted) {
      await Future.delayed(widget.duration);
      setState(() {
        circles = List.generate(widget.circleCount, (_) => _randomCircle());
      });
    }
  }
}
