import 'package:flutter/material.dart';
import 'package:project_2_graphs/data/models/splash/data_circle.dart';
import 'package:project_2_graphs/presentation/pages/splash/widgets/optimized_circle.dart';

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
  late AnimationController _controller;
  late List<CircleData> circles;
  late Animation<Color?> _colorAnimation;
  Color? _cachedBackgroundColor;
  Color? _cachedGradientColor;

  final List<Color> backgroundColors = [
    Colors.blue,
    Colors.purple,
    Colors.red,
    Colors.orange,
    Colors.green,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimationController();
    _setupAnimationBackground();
    _initializeCircles();
    _controller.addListener(_onAnimationUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onAnimationUpdate);
    _controller.dispose();
    circles.clear();
    super.dispose();
  }

  void _onAnimationUpdate() {
    final newColor = _colorAnimation.value;
    if (newColor != _cachedBackgroundColor) {
      setState(() {
        _cachedBackgroundColor = newColor;
        _cachedGradientColor = newColor?.withValues(alpha: 0.6);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = _controller.value * widget.duration.inSeconds;

    return Container(
      height: widget.height,
      width: widget.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _cachedBackgroundColor ?? Colors.blue,
            _cachedGradientColor ?? Colors.blue.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: circles.map((circle) {
          return OptimizedCircle(
            circle: circle,
            elapsed: elapsed,
            containerWidth: widget.width,
          );
        }).toList(),
      ),
    );
  }

  void _initializeCircles() {
    // Reducir número de círculos para mejor rendimiento
    circles = [
      CircleData(
        top: 50,
        size: 30,
        speed: 20,
        color: Colors.white.withValues(alpha: 0.3),
      ),
      CircleData(
        top: 100,
        size: 40,
        speed: 15,
        color: Colors.white.withValues(alpha: 0.4),
      ),
      CircleData(
        top: 150,
        size: 50,
        speed: 10,
        color: Colors.white.withValues(alpha: 0.5),
      ),
      CircleData(
        top: 200,
        size: 60,
        speed: 5,
        color: Colors.white.withValues(alpha: 0.6),
      ),
      CircleData(
        top: 250,
        size: 70,
        speed: 3,
        color: Colors.white.withValues(alpha: 0.7),
      ),
      CircleData(
        top: 300,
        size: 80,
        speed: 2,
        color: Colors.white.withValues(alpha: 0.8),
      ),
      CircleData(
        top: 350,
        size: 90,
        speed: 1,
        color: Colors.white.withValues(alpha: 0.9),
      ),
    ];
  }

  void _setupAnimationController() {
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat();
  }

  void _setupAnimationBackground() {
    _colorAnimation = _controller.drive(
      TweenSequence<Color?>(
        List.generate(backgroundColors.length, (index) {
          final next = backgroundColors[(index + 1) % backgroundColors.length];
          return TweenSequenceItem(
            tween: ColorTween(begin: backgroundColors[index], end: next),
            weight: 1.0,
          );
        }),
      ),
    );

    // Inicializar colores cache
    _cachedBackgroundColor = backgroundColors.first;
    _cachedGradientColor = backgroundColors.first.withValues(alpha: 0.6);
  }
}
