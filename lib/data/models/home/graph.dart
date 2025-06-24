import 'package:flutter/material.dart';

class Graph {
  double x;
  double y;
  double radius;
  String label;
  Color color;
  bool isSelected;

  Graph({
    required this.x,
    required this.y,
    required this.radius,
    required this.label,
    required this.color,
    this.isSelected = false,
  });
}
