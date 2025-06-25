import 'package:flutter/material.dart';
import 'package:project_2_graphs/data/models/home/edge.dart';
import 'package:project_2_graphs/data/models/home/graph.dart';
import 'package:project_2_graphs/data/models/home/graph_type.dart';
import 'package:project_2_graphs/data/models/home/sequence.dart';
import 'package:project_2_graphs/data/models/home/sketch.dart';
import 'dart:math';

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
      // Dibujar la línea
      canvas.drawLine(
        Offset(edge.start.x, edge.start.y),
        Offset(edge.end.x, edge.end.y),
        borderBrush,
      );

      // Texto del peso
      TextSpan span = TextSpan(
        style: TextStyle(color: borderColor, fontSize: 12),
        text: edge.weight.toStringAsFixed(2),
      );
      TextPainter textPainter = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Centro del borde
      double midX = (edge.start.x + edge.end.x) / 2;
      double midY = (edge.start.y + edge.end.y) / 2;

      // Vector perpendicular normalizado
      double dx = edge.end.y - edge.start.y;
      double dy = -(edge.end.x - edge.start.x);
      double length = sqrt(dx * dx + dy * dy);
      if (length != 0) {
        dx /= length;
        dy /= length;
      }

      // Desplazamiento del texto hacia arriba de la línea
      double offsetAmount = 10;
      Offset offset = Offset(
        midX + dx * offsetAmount - textPainter.width / 2,
        midY + dy * offsetAmount - textPainter.height / 2,
      );

      // Pintar el texto
      textPainter.paint(canvas, offset);
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
      TextSpan span = TextSpan(
        style: TextStyle(color: borderColor, fontSize: 12),
        text: graph.label,
      );
      TextPainter textPainter = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      Offset offset = Offset(
        graph.x - textPainter.width / 2,
        graph.y - textPainter.height / 2,
      );
      textPainter.paint(canvas, offset);
      //Dibujar el sesgo arriba si es un grafo de tipo perceptrón
      if (graph.type == GraphType.perceptron && graph.bias != null) {
        TextSpan biasSpan = TextSpan(
          style: TextStyle(color: borderColor, fontSize: 10),
          text: 'Bias: ${graph.bias!.toStringAsFixed(2)}',
        );
        TextPainter biasPainter = TextPainter(
          text: biasSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        biasPainter.layout();
        Offset biasOffset = Offset(
          graph.x - biasPainter.width / 2,
          graph.y - graph.radius - biasPainter.height - 5,
        );
        biasPainter.paint(canvas, biasOffset);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
