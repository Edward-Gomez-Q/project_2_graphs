import 'package:flutter/material.dart';
import 'package:project_2_graphs/data/models/home/graph_type.dart';
import 'package:project_2_graphs/data/models/home/logic_operation.dart';

class Graph {
  double x;
  double y;
  double radius;
  String label;
  Color color;
  Color opositeColor;
  bool isSelected;

  GraphType type;
  List<Graph>? inputsGraphs;
  List<Graph>? outputsGraphs;

  LogicOperation? operation;
  double? bias = 0.0;
  int? activationValue;

  List<double>? weightedSum;
  List<double>? outputs;
  List<double>? error;
  List<int>? expectedOutputs;

  Graph({
    required this.x,
    required this.y,
    required this.radius,
    required this.label,
    required this.color,
    required this.opositeColor,
    this.isSelected = false,
    this.type = GraphType.input,
    this.inputsGraphs,
    this.outputsGraphs,

    this.operation,
    this.bias,
    this.activationValue,
    this.weightedSum,
    this.outputs,
    this.error,
    this.expectedOutputs,
  });
  // Método para inicializar las listas con el tamaño correcto
  void initializeLists(int size) {
    weightedSum = List.filled(size, 0.0);
    outputs = List.filled(size, 0.0);
    error = List.filled(size, 0.0);
    expectedOutputs = List.filled(size, 0);
  }

  // Método para verificar si las listas están inicializadas correctamente
  bool areListsValid(int expectedSize) {
    return weightedSum?.length == expectedSize &&
        outputs?.length == expectedSize &&
        error?.length == expectedSize &&
        expectedOutputs?.length == expectedSize;
  }
}
