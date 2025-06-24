import 'package:flutter/material.dart';
import 'package:project_2_graphs/data/models/splash/data_circle.dart';
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
  static final Random _random = Random();
  late AnimationController _controller;
  late List<CircleData> circles;
  late List<CircleData> targetCircles;

  late final List<double> _precomputedXValues;
  late final List<double> _precomputedYValues;
  late final List<Color> _precomputedColors;
  late final List<double> _precomputedSizes;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _precomputeRandomValues();
    _initializeCircles();
    _setupAnimationController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Stack(
        children: circles.asMap().entries.map((entry) {
          final circle = entry.value;
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

  void _precomputeRandomValues() {
    const int poolSize = 1000;

    _precomputedXValues = List.generate(
      poolSize,
      (_) => _random.nextDouble() * widget.width,
    );

    _precomputedYValues = List.generate(
      poolSize,
      (_) => _random.nextDouble() * widget.height,
    );

    _precomputedColors = List.generate(poolSize, (_) {
      return Color.fromARGB(
        255,
        _random.nextInt(256),
        _random.nextInt(256),
        _random.nextInt(256),
      );
    });

    _precomputedSizes = List.generate(
      poolSize,
      (_) => _random.nextDouble() * 40 + 10,
    );
  }

  void _initializeCircles() {
    circles = List.generate(
      widget.circleCount,
      (index) => _getCircleFromPool(index),
    );
    targetCircles = List.generate(
      widget.circleCount,
      (index) => _getCircleFromPool(index + widget.circleCount),
    );
  }

  CircleData _getCircleFromPool(int seed) {
    final xIndex = (seed * 17) % _precomputedXValues.length;
    final yIndex = (seed * 23) % _precomputedYValues.length;
    final colorIndex = (seed * 31) % _precomputedColors.length;
    final sizeIndex = (seed * 37) % _precomputedSizes.length;

    return CircleData(
      left: _precomputedXValues[xIndex],
      top: _precomputedYValues[yIndex],
      color: _precomputedColors[colorIndex],
      size: _precomputedSizes[sizeIndex],
    );
  }

  void _setupAnimationController() {
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _updateCircles();
        _controller.reset();
        _controller.forward();
      }
    });

    _controller.forward();
  }

  void _updateCircles() {
    setState(() {
      final temp = circles;
      circles = targetCircles;
      targetCircles = temp;
      for (int i = 0; i < widget.circleCount; i++) {
        _currentIndex =
            (_currentIndex + 1) %
            (_precomputedXValues.length - widget.circleCount);
        targetCircles[i] = _getCircleFromPool(_currentIndex + i);
      }
    });
  }
}
