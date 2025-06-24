import 'package:flutter/material.dart';
import 'package:project_2_graphs/data/models/home/edge.dart';
import 'package:project_2_graphs/data/models/home/graph.dart';
import 'package:project_2_graphs/data/models/home/sequence.dart';

class PaintNN extends CustomPainter {
  List<Graph> graphs;
  List<Edge> edges;
  List<Sequence> sequences;
  double progress;

  PaintNN({
    required this.graphs,
    required this.edges,
    required this.sequences,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paintBrush = Paint()..style = PaintingStyle.fill;

    Paint borderBrush = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var edge in edges) {
      borderBrush.color = edge.isSelected ? Colors.blue : Colors.black;
      canvas.drawLine(
        Offset(edge.start.x, edge.start.y),
        Offset(edge.end.x, edge.end.y),
        borderBrush,
      );
    }
    final paintPoint = Paint()
      ..color = Colors.black
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
      paintBrush.color = graph.color;
      canvas.drawCircle(Offset(graph.x, graph.y), graph.radius, paintBrush);
      borderBrush.color = graph.isSelected ? Colors.blue : Colors.black;
      canvas.drawCircle(Offset(graph.x, graph.y), graph.radius, borderBrush);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
