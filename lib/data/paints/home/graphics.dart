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
  bool isTraining;

  int? currentEpoch;
  int? totalEpochs;

  PaintNN({
    required this.graphs,
    required this.edges,
    required this.sequences,
    required this.sketch,
    required this.progress,
    required this.borderColor,
    required this.isTraining,
    this.currentEpoch,
    this.totalEpochs,
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
      // Si no esta en entrenamiento, dibujar el peso en el centro de la línea
      if (!isTraining) {
        _drawWeightText(canvas, edge, edge.weight);
      }
    }
    final paintPoint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;

    if (isTraining && sequences.isNotEmpty) {
      Offset pointPath;
      for (int i = 0; i < sequences.length; i++) {
        var sequence = sequences[i];
        pointPath = Offset(
          sequence.start.x + (sequence.end.x - sequence.start.x) * progress,
          sequence.start.y + (sequence.end.y - sequence.start.y) * progress,
        );
        canvas.drawCircle(pointPath, 5, paintPoint);

        _drawWeightText(canvas, sequence, sequence.edge.weight, pointPath);
      }
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
          text: 'Sesgo: ${graph.bias!.toStringAsFixed(2)}',
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

  void _drawWeightText(
    Canvas canvas,
    dynamic item,
    double weight, [
    Offset? position,
  ]) {
    TextSpan span = TextSpan(
      style: TextStyle(color: borderColor, fontSize: 12),
      text: weight.toStringAsFixed(2),
    );

    TextPainter textPainter = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    Offset offset;
    if (position != null) {
      // Para puntos en movimiento
      offset = Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2 - 15, // Encima del punto
      );
    } else if (item is Edge) {
      // Para edges estáticos
      double midX = (item.start.x + item.end.x) / 2;
      double midY = (item.start.y + item.end.y) / 2;

      double dx = item.end.y - item.start.y;
      double dy = -(item.end.x - item.start.x);
      double length = sqrt(dx * dx + dy * dy);
      if (length != 0) {
        dx /= length;
        dy /= length;
      }

      double offsetAmount = 15;
      offset = Offset(
        midX + dx * offsetAmount - textPainter.width / 2,
        midY + dy * offsetAmount - textPainter.height / 2,
      );
    } else {
      return;
    }

    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
