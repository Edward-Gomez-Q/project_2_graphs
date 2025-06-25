import 'package:flutter/material.dart';
import 'package:project_2_graphs/data/models/home/edge.dart';
import 'package:project_2_graphs/data/models/home/graph.dart';
import 'package:project_2_graphs/data/models/home/graph_type.dart';
import 'package:project_2_graphs/data/models/home/network_data.dart';

class CartesianPlanePainter extends CustomPainter {
  final NetworkData networkData;

  CartesianPlanePainter({required this.networkData});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.0;

    // Dibujar ejes
    _drawAxes(canvas, size, paint);

    // Dibujar puntos de entrenamiento
    _drawTrainingPoints(canvas, size);

    // Dibujar línea de separación si hay un perceptrón entrenado
    drawSeparationLine(canvas, size);

    // Dibujar etiquetas
    _drawLabels(canvas, size);
  }

  void _drawAxes(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Eje X
    canvas.drawLine(
      Offset(20, centerY),
      Offset(size.width - 20, centerY),
      paint,
    );

    // Eje Y
    canvas.drawLine(
      Offset(centerX, 20),
      Offset(centerX, size.height - 20),
      paint,
    );

    // Marcas en los ejes
    final markPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;

    // Marcas X (0, 1)
    final x0 = _mapInputToCanvas(0, size.width, 20, size.width - 20);
    final x1 = _mapInputToCanvas(1, size.width, 20, size.width - 20);

    canvas.drawLine(
      Offset(x0, centerY - 5),
      Offset(x0, centerY + 5),
      markPaint,
    );
    canvas.drawLine(
      Offset(x1, centerY - 5),
      Offset(x1, centerY + 5),
      markPaint,
    );

    // Marcas Y (0, 1)
    final y0 = _mapInputToCanvas(
      1,
      size.height,
      20,
      size.height - 20,
    ); // Invertido
    final y1 = _mapInputToCanvas(
      0,
      size.height,
      20,
      size.height - 20,
    ); // Invertido

    canvas.drawLine(
      Offset(centerX - 5, y0),
      Offset(centerX + 5, y0),
      markPaint,
    );
    canvas.drawLine(
      Offset(centerX - 5, y1),
      Offset(centerX + 5, y1),
      markPaint,
    );
  }

  void _drawTrainingPoints(Canvas canvas, Size size) {
    if (networkData.trainingInputs.isEmpty) return;

    Graph? outputPerceptron = _getOutputPerceptron();
    if (outputPerceptron?.expectedOutputs == null) return;

    for (int i = 0; i < networkData.trainingInputs.length; i++) {
      final inputs = networkData.trainingInputs[i];
      if (inputs.length >= 2) {
        final x = _mapInputToCanvas(
          inputs[0].toDouble(),
          size.width,
          20,
          size.width - 20,
        );
        final y = _mapInputToCanvas(
          1 - inputs[1].toDouble(),
          size.height,
          20,
          size.height - 20,
        );

        final expectedOutput = outputPerceptron!.expectedOutputs![i];
        final pointColor = expectedOutput == 1 ? Colors.red : Colors.blue;

        final paint = Paint()
          ..color = pointColor
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(x, y), 8.0, paint);

        // Borde del punto
        final borderPaint = Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

        canvas.drawCircle(Offset(x, y), 8.0, borderPaint);
      }
    }
  }

  void drawSeparationLine(Canvas canvas, Size size) {
    Graph? outputPerceptron = _getOutputPerceptron();
    if (outputPerceptron == null) return;

    List<Edge> inputEdges = _getInputEdgesForPerceptron(outputPerceptron);
    if (inputEdges.length < 2) return;

    double w1 = inputEdges[0].weight;
    double w2 = inputEdges[1].weight;
    double bias = outputPerceptron.bias ?? 0.0;

    // Evitar valores muy pequeños que causen problemas
    if (w1.abs() < 0.001 && w2.abs() < 0.001) return;

    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3.0;

    // Definir el área de dibujo con margen
    const double margin = 20.0;
    final double minX = 0.0;
    final double maxX = 1.0;
    final double minY = 0.0;
    final double maxY = 1.0;

    List<Offset> intersections = [];

    if (w2.abs() > 0.001) {
      // Caso normal: línea no vertical

      // Intersecciones con los bordes verticales (x = 0 y x = 1)
      double y_at_x0 = -(w1 * minX + bias) / w2;
      if (y_at_x0 >= minY && y_at_x0 <= maxY) {
        intersections.add(Offset(minX, y_at_x0));
      }

      double y_at_x1 = -(w1 * maxX + bias) / w2;
      if (y_at_x1 >= minY && y_at_x1 <= maxY) {
        intersections.add(Offset(maxX, y_at_x1));
      }

      // Intersecciones con los bordes horizontales (y = 0 y y = 1)
      double x_at_y0 = -(w2 * minY + bias) / w1;
      if (x_at_y0 >= minX && x_at_y0 <= maxX) {
        intersections.add(Offset(x_at_y0, minY));
      }

      double x_at_y1 = -(w2 * maxY + bias) / w1;
      if (x_at_y1 >= minX && x_at_y1 <= maxX) {
        intersections.add(Offset(x_at_y1, maxY));
      }
    } else {
      // Caso especial: línea vertical (w2 ≈ 0)
      if (w1.abs() < 0.001) return; // Evitar caso degenerado

      double xLine = -bias / w1;
      if (xLine >= minX && xLine <= maxX) {
        intersections.add(Offset(xLine, minY));
        intersections.add(Offset(xLine, maxY));
      }
    }

    // Eliminar puntos duplicados y quedarnos solo con los primeros 2
    if (intersections.length >= 2) {
      // Eliminar duplicados
      List<Offset> uniqueIntersections = [];
      for (Offset point in intersections) {
        bool isDuplicate = false;
        for (Offset existing in uniqueIntersections) {
          if ((point.dx - existing.dx).abs() < 0.001 &&
              (point.dy - existing.dy).abs() < 0.001) {
            isDuplicate = true;
            break;
          }
        }
        if (!isDuplicate) {
          uniqueIntersections.add(point);
        }
      }

      if (uniqueIntersections.length >= 2) {
        // Tomar los dos primeros puntos únicos
        final point1 = uniqueIntersections[0];
        final point2 = uniqueIntersections[1];

        // Convertir a coordenadas del canvas
        final canvasX1 = _mapInputToCanvas(
          point1.dx,
          size.width,
          margin,
          size.width - margin,
        );
        final canvasY1 = _mapInputToCanvas(
          1 - point1.dy,
          size.height,
          margin,
          size.height - margin,
        );
        final canvasX2 = _mapInputToCanvas(
          point2.dx,
          size.width,
          margin,
          size.width - margin,
        );
        final canvasY2 = _mapInputToCanvas(
          1 - point2.dy,
          size.height,
          margin,
          size.height - margin,
        );

        canvas.drawLine(
          Offset(canvasX1, canvasY1),
          Offset(canvasX2, canvasY2),
          paint,
        );
      }
    }
  }

  void _drawLabels(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Etiquetas de los ejes
    final labels = ['0', '1'];
    final positions = [
      // X axis labels
      [
        _mapInputToCanvas(0, size.width, 20, size.width - 20),
        size.height / 2 + 20,
      ],
      [
        _mapInputToCanvas(1, size.width, 20, size.width - 20),
        size.height / 2 + 20,
      ],
      // Y axis labels
      [
        size.width / 2 - 20,
        _mapInputToCanvas(0, size.height, 20, size.height - 20),
      ],
      [
        size.width / 2 - 20,
        _mapInputToCanvas(1, size.height, 20, size.height - 20),
      ],
    ];

    for (int i = 0; i < 4; i++) {
      textPainter.text = TextSpan(text: labels[i % 2], style: textStyle);
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          positions[i][0] - textPainter.width / 2,
          positions[i][1] - textPainter.height / 2,
        ),
      );
    }
  }

  double _mapInputToCanvas(
    double input,
    double canvasSize,
    double margin,
    double maxPos,
  ) {
    return margin + (input * (maxPos - margin));
  }

  Graph? _getOutputPerceptron() {
    try {
      return networkData.graphs.firstWhere(
        (graph) =>
            graph.type == GraphType.perceptron &&
            (graph.outputsGraphs == null || graph.outputsGraphs!.isEmpty),
      );
    } catch (e) {
      return null; // No se encontró ningún perceptrón de salida
    }
  }

  List<Edge> _getInputEdgesForPerceptron(Graph perceptron) {
    return networkData.edges.where((edge) => edge.end == perceptron).toList();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
