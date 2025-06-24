import 'package:flutter/material.dart';
import 'package:project_2_graphs/data/models/home/edge.dart';
import 'package:project_2_graphs/data/models/home/graph.dart';
import 'package:project_2_graphs/data/models/home/sequence.dart';
import 'package:project_2_graphs/data/models/home/sketch.dart';

class PaintNN extends CustomPainter {
  List<Graph> graphs;
  List<Edge> edges;
  List<Sequence> sequences;
  Sketch sketch;
  double progress;
  Color borderColor;

  PaintNN({
    required this.graphs,
    required this.edges,
    required this.sequences,
    required this.sketch,
    required this.progress,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paintBrush = Paint()..style = PaintingStyle.fill;

    Paint borderBrush = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    if (sketch.isDrawing &&
        (sketch.x1 != 0 &&
            sketch.y1 != 0 &&
            sketch.x2 != 0 &&
            sketch.y2 != 0)) {
      canvas.drawLine(
        Offset(sketch.x1, sketch.y1),
        Offset(sketch.x2, sketch.y2),
        borderBrush,
      );
    }

    for (var edge in edges) {
      canvas.drawLine(
        Offset(edge.start.x, edge.start.y),
        Offset(edge.end.x, edge.end.y),
        borderBrush,
      );
    }
    final paintPoint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;

    Offset pointPath;
    double t = progress;
    for (var sequence in sequences) {
      pointPath = Offset(
        sequence.start.x + (sequence.end.x - sequence.start.x) * t,
        sequence.start.y + (sequence.end.y - sequence.start.y) * t,
      );
      canvas.drawCircle(pointPath, 10, paintPoint);
    }
    for (var graph in graphs) {
      paintBrush.color = graph.isSelected ? graph.opositeColor : graph.color;
      canvas.drawCircle(Offset(graph.x, graph.y), graph.radius, paintBrush);
      canvas.drawCircle(Offset(graph.x, graph.y), graph.radius, borderBrush);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
