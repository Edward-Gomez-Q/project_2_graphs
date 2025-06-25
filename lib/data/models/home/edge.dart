import 'package:flutter/material.dart';
import 'package:project_2_graphs/data/models/home/graph.dart';

class Edge {
  Graph start;
  Graph end;
  double weight;
  Color color;
  bool isSelected;

  Edge({
    required this.start,
    required this.end,
    required this.weight,
    required this.color,
    this.isSelected = false,
  });
}
