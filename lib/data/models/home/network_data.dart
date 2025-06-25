import 'dart:math';

import 'package:project_2_graphs/data/models/home/edge.dart';
import 'package:project_2_graphs/data/models/home/epoch_result.dart';
import 'package:project_2_graphs/data/models/home/graph.dart';
import 'package:project_2_graphs/data/models/home/graph_type.dart';
import 'package:project_2_graphs/data/models/home/sequence.dart';
import 'package:project_2_graphs/data/models/home/sketch.dart';
import 'package:project_2_graphs/data/models/home/training_history.dart';
import 'package:project_2_graphs/data/models/home/training_step.dart';

class NetworkData {
  List<Edge> edges = [];
  List<Graph> graphs = [];
  List<Sequence> sequences = [];
  Sketch sketch = Sketch(x1: 0, y1: 0, x2: 0, y2: 0, isDrawing: false);
  int startingPoint = -1;

  int rowsLength = 0;

  int epochs = 5000;
  int currentEpoch = 0;
  List<List<int>> trainingInputs = [];
  double learningRate = 0.1;

  bool isTraining = false;
  List<List<double>> epochHistory = [];
  bool hasConverged = false;

  TrainingHistory? currentTrainingHistory;

  void clean() {
    edges.clear();
    graphs.clear();
    sequences.clear();
    startingPoint = -1;
    sketch.reset();
    trainingInputs.clear();
    rowsLength = 0;
    currentEpoch = 0;
    isTraining = false;
    hasConverged = false;
    epochHistory.clear();
    currentTrainingHistory = null;
  }

  void resetStartingPoint() {
    startingPoint = -1;
  }

  void resetSketch() {
    sketch.reset();
  }

  void buildInputs() {
    int inputSize = getInputGraphsLength();
    trainingInputs.clear();
    rowsLength = 1 << inputSize;
    for (int i = 0; i < rowsLength; i++) {
      List<int> combination = [];
      for (int j = inputSize - 1; j >= 0; j--) {
        combination.add(((i >> j) & 1).toInt());
      }
      trainingInputs.add(combination);
    }
  }

  void updatePerceptronValues() {
    if (rowsLength == 0) {
      buildInputs();
    }

    List<Graph> perceptrons = getPerceptronGraphs();
    for (Graph perceptron in perceptrons) {
      perceptron.outputs = List.filled(rowsLength, 0);
      perceptron.expectedOutputs = List.filled(rowsLength, 0);
      perceptron.weightedSum = List.filled(rowsLength, 0.0);
      perceptron.error = List.filled(rowsLength, 0.0);
    }
  }

  void updatePerceptronValuesForTraining() {
    if (rowsLength == 0) {
      buildInputs();
    }

    List<Graph> perceptrons = getPerceptronGraphs();
    for (Graph perceptron in perceptrons) {
      perceptron.outputs = List.filled(rowsLength, 0);
      perceptron.weightedSum = List.filled(rowsLength, 0.0);
      perceptron.error = List.filled(rowsLength, 0.0);
      if (perceptron.expectedOutputs == null ||
          perceptron.expectedOutputs!.length != rowsLength) {
        perceptron.expectedOutputs = List.filled(rowsLength, 0);
      }
    }
  }

  List<Graph> getInputGraphs() {
    return graphs.where((g) => g.type == GraphType.input).toList();
  }

  int getInputGraphsLength() {
    return graphs.where((g) => g.type == GraphType.input).length;
  }

  List<Graph> getPerceptronGraphs() {
    return graphs.where((g) => g.type == GraphType.perceptron).toList();
  }

  int getPerceptronGraphsLegth() {
    return graphs.where((g) => g.type == GraphType.perceptron).length;
  }

  //Función de activación de tipo escalón
  double activationFunction(double sum) {
    return sum >= 0 ? 1 : 0;
  }

  List<Edge> getInputEdgesForPerceptron(Graph perceptron) {
    return edges.where((edge) => edge.end == perceptron).toList();
  }

  double calculatePerceptronOutput(Graph perceptron, List<int> inputs) {
    List<Edge> inputEdges = getInputEdgesForPerceptron(perceptron);
    double sum = perceptron.bias ?? 0.0;

    for (Edge edge in inputEdges) {
      List<Graph> inputGraphs = getInputGraphs();
      int inputIndex = inputGraphs.indexOf(edge.start);

      if (inputIndex != -1 && inputIndex < inputs.length) {
        sum += inputs[inputIndex] * edge.weight;
      }
    }

    return sum;
  }

  bool startTraining(Graph graph, Duration duration) {
    //Validar si se tienen todos los datos necesarios
    if (getInputGraphsLength() == 0 || getPerceptronGraphsLegth() == 0) {
      return false;
    }
    if (graph.type != GraphType.perceptron) {
      return false;
    }
    if (isTraining) {
      return false;
    }
    // Verificar que el perceptrón tenga conexiones de entrada
    if (getInputEdgesForPerceptron(graph).isEmpty) {
      return false;
    }

    currentTrainingHistory = TrainingHistory(
      networkType: "simple",
      startTime: DateTime.now(),
      hyperparameters: {'learningRate': learningRate, 'epochs': epochs},
    );

    isTraining = true;
    currentEpoch = 0;
    hasConverged = false;
    epochHistory.clear();
    updatePerceptronValuesForTraining();
    trainPerceptron(graph, duration);
    return true;
  }

  void trainPerceptron(Graph perceptron, [Duration? duration]) {
    if (currentEpoch >= epochs || hasConverged || !isTraining) {
      isTraining = false;
      currentTrainingHistory?.finish();
      print("Entrenamiento completado después de $currentEpoch épocas");
      return;
    }

    print('=== Época ${currentEpoch + 1} ===');
    double totalError = 0.0;
    List<TrainingStep> epochSteps = [];
    for (int rowIndex = 0; rowIndex < rowsLength; rowIndex++) {
      List<int> inputs = trainingInputs[rowIndex];
      double weightedSum = calculatePerceptronOutput(perceptron, inputs);
      perceptron.weightedSum![rowIndex] = weightedSum;
      double output = activationFunction(weightedSum);
      perceptron.outputs![rowIndex] = output;
      int expectedOutput = perceptron.expectedOutputs![rowIndex];
      double error = expectedOutput - output;
      perceptron.error![rowIndex] = error;
      totalError += error.abs();
      Map<String, double> currentWeights = {};
      List<Edge> inputEdges = getInputEdgesForPerceptron(perceptron);
      for (int i = 0; i < inputEdges.length; i++) {
        currentWeights['edge_$i'] = inputEdges[i].weight;
      }
      epochSteps.add(
        TrainingStep(
          rowIndex: rowIndex,
          inputs: List.from(inputs),
          weightedSum: weightedSum,
          output: output,
          expectedOutput: expectedOutput,
          error: error,
          bias: perceptron.bias ?? 0.0,
          weights: Map.from(currentWeights),
        ),
      );
      if (error != 0) {
        List<Edge> inputEdges = getInputEdgesForPerceptron(perceptron);
        List<Graph> inputGraphs = getInputGraphs();

        for (Edge edge in inputEdges) {
          int inputIndex = inputGraphs.indexOf(edge.start);
          if (inputIndex != -1 && inputIndex < inputs.length) {
            edge.weight += learningRate * error * inputs[inputIndex];
          }
        }
        perceptron.bias = (perceptron.bias ?? 0.0) + learningRate * error;
      }

      print(
        'Fila $rowIndex: Inputs=$inputs, Sum=${weightedSum.toStringAsFixed(3)}, Output=${output.toInt()}, Expected=$expectedOutput, Error=${error.toStringAsFixed(3)}',
      );
    }

    print('Error total de la época: ${totalError.toStringAsFixed(3)}');
    print('Bias actual: ${perceptron.bias?.toStringAsFixed(3)}');

    // Registrar la época completa en el historial
    currentTrainingHistory?.addEpoch(
      EpochResult(
        epochNumber: currentEpoch + 1,
        steps: epochSteps,
        totalError: totalError,
        hasConverged: totalError == 0,
        perceptronId: perceptron.label,
      ),
    );
    // Guardar historial de la época
    epochHistory.add(List.from(perceptron.error!));

    currentEpoch++;

    // Verificar convergencia
    if (totalError == 0) {
      hasConverged = true;
      isTraining = false;
      print("¡Convergencia alcanzada en la época $currentEpoch!");
      return;
    }

    // Continuar con la siguiente época después de un delay
    if (currentEpoch < epochs && isTraining) {
      Future.delayed(duration!, () {
        if (isTraining) {
          trainPerceptron(perceptron, duration);
        }
      });
    } else {
      isTraining = false;
      print("Entrenamiento finalizado sin convergencia completa");
    }
  }

  void stopTraining() {
    isTraining = false;
    print("Entrenamiento detenido");
  }

  TrainingHistory? getLastTrainingHistory() {
    return currentTrainingHistory;
  }

  List<EpochResult> getEpochHistory() {
    return currentTrainingHistory?.epochs ?? [];
  }

  EpochResult? getEpochResult(int epochNumber) {
    return currentTrainingHistory?.epochs
        .where((e) => e.epochNumber == epochNumber)
        .firstOrNull;
  }

  //MULTILAYER PERCEPTRON
  // Función principal para iniciar entrenamiento multicapa
  void startMultilayerTraining(
    Graph outputPerceptron,
    Duration animationDuration,
  ) {
    if (outputPerceptron.type != GraphType.perceptron) return;

    // Verificar que es un perceptrón de salida (no tiene conexiones de salida)
    if (outputPerceptron.outputsGraphs != null &&
        outputPerceptron.outputsGraphs!.isNotEmpty) {
      return;
    }

    // Identificar si es una red multicapa
    List<List<Graph>> layers = _identifyNetworkLayers(outputPerceptron);
    isTraining = true;
    currentEpoch = 0;
    hasConverged = false;
    if (layers.length > 1) {
      // Es multicapa, usar backpropagation
      _trainMultilayerNetwork(layers, animationDuration);
    } else {
      // Es simple, usar el método existente
      trainPerceptron(outputPerceptron, animationDuration);
    }
  }

  // Identificar las capas de la red neuronal
  List<List<Graph>> _identifyNetworkLayers(Graph outputPerceptron) {
    List<List<Graph>> layers = [];
    Set<Graph> visited = {};

    // Comenzar desde la capa de salida
    List<Graph> currentLayer = [outputPerceptron];
    layers.insert(0, currentLayer);
    visited.add(outputPerceptron);

    while (true) {
      List<Graph> nextLayer = [];

      for (Graph perceptron in currentLayer) {
        if (perceptron.inputsGraphs != null) {
          for (Graph inputGraph in perceptron.inputsGraphs!) {
            if (!visited.contains(inputGraph) &&
                inputGraph.type == GraphType.perceptron) {
              nextLayer.add(inputGraph);
              visited.add(inputGraph);
            }
          }
        }
      }

      if (nextLayer.isEmpty) break;

      layers.insert(0, nextLayer);
      currentLayer = nextLayer;
    }

    return layers;
  }

  // Entrenamiento multicapa con backpropagation
  void _trainMultilayerNetwork(List<List<Graph>> layers, Duration duration) {
    if (currentEpoch == 0) {
      isTraining = true;
      print('=== INICIANDO ENTRENAMIENTO ===');
      _initializeNetwork(layers);
    }

    if (currentEpoch >= epochs || hasConverged || !isTraining) {
      isTraining = false;
      currentTrainingHistory?.finish();
      return;
    }

    print('\n=== Época ${currentEpoch + 1} ===');
    double totalError = 0.0;

    // Procesar cada patrón de entrenamiento
    for (int rowIndex = 0; rowIndex < rowsLength; rowIndex++) {
      List<int> inputs = trainingInputs[rowIndex];
      int expectedOutput = layers.last[0].expectedOutputs![rowIndex];

      // 1. Forward pass
      _forwardPassSimple(layers, inputs, rowIndex);

      // 2. Calcular error de salida
      Graph outputNode = layers.last[0];
      double actualOutput = outputNode.outputs![rowIndex];
      double outputError = expectedOutput - actualOutput;
      outputNode.error![rowIndex] = outputError;

      totalError += outputError.abs();

      // 3. Backward pass
      _backwardPassSimple(layers, rowIndex);

      // 4. Actualizar pesos
      _updateWeightsSimple(layers, inputs, rowIndex);
    }
    currentEpoch++;

    // Verificar convergencia
    if (totalError < 0.1) {
      hasConverged = true;
      isTraining = false;
      print("¡Convergencia alcanzada!");
      return;
    }

    // Continuar entrenamiento
    if (currentEpoch < epochs && isTraining) {
      Future.delayed(duration, () {
        if (isTraining) {
          _trainMultilayerNetwork(layers, Duration(milliseconds: 3));
        }
      });
    } else {
      isTraining = false;
      print("Entrenamiento finalizado");
    }
  }

  // INICIALIZACIÓN CORRECTA
  void _initializeNetwork(List<List<Graph>> layers) {
    Random random = Random();

    // Inicializar pesos aleatorios pequeños
    for (Edge edge in edges) {
      edge.weight = (random.nextDouble() - 0.5) * 2.0; // Rango [-1, 1]
    }

    // Inicializar bias aleatorios pequeños
    for (List<Graph> layer in layers) {
      for (Graph node in layer) {
        node.bias = (random.nextDouble() - 0.5) * 2.0; // Rango [-1, 1]
      }
    }

    print('Red inicializada con pesos aleatorios');
  }

  // FORWARD PASS SIMPLIFICADO
  void _forwardPassSimple(
    List<List<Graph>> layers,
    List<int> inputs,
    int rowIndex,
  ) {
    for (int layerIndex = 0; layerIndex < layers.length; layerIndex++) {
      List<Graph> currentLayer = layers[layerIndex];

      for (Graph node in currentLayer) {
        double sum = node.bias ?? 0.0;

        if (layerIndex == 0) {
          // Primera capa: conectada a inputs
          List<Edge> inputEdges = getInputEdgesForPerceptron(node);
          List<Graph> inputNodes = getInputGraphs();

          for (Edge edge in inputEdges) {
            int inputIndex = inputNodes.indexOf(edge.start);
            if (inputIndex >= 0 && inputIndex < inputs.length) {
              sum += edge.weight * inputs[inputIndex];
            }
          }
        } else {
          // Capas ocultas/salida: conectadas a capa anterior
          List<Graph> previousLayer = layers[layerIndex - 1];
          List<Edge> inputEdges = getInputEdgesForPerceptron(node);

          for (Edge edge in inputEdges) {
            if (previousLayer.contains(edge.start)) {
              sum += edge.weight * edge.start.outputs![rowIndex];
            }
          }
        }

        node.weightedSum![rowIndex] = sum;
        node.outputs![rowIndex] = _sigmoid(sum);
      }
    }
  }

  // BACKWARD PASS SIMPLIFICADO
  void _backwardPassSimple(List<List<Graph>> layers, int rowIndex) {
    // Propagar error hacia atrás desde la salida
    for (int layerIndex = layers.length - 2; layerIndex >= 0; layerIndex--) {
      List<Graph> currentLayer = layers[layerIndex];
      List<Graph> nextLayer = layers[layerIndex + 1];

      for (Graph node in currentLayer) {
        double errorSum = 0.0;

        // Sumar errores de todas las conexiones hacia la siguiente capa
        for (Graph nextNode in nextLayer) {
          Edge? edge = _findEdgeBetween(node, nextNode);
          if (edge != null) {
            errorSum += nextNode.error![rowIndex] * edge.weight;
          }
        }

        // Error = suma_errores * derivada_activación
        double output = node.outputs![rowIndex];
        double derivative = _sigmoidDerivative(output);
        node.error![rowIndex] = errorSum * derivative;
      }
    }
  }

  // ACTUALIZACIÓN DE PESOS SIMPLIFICADA
  void _updateWeightsSimple(
    List<List<Graph>> layers,
    List<int> inputs,
    int rowIndex,
  ) {
    double learningRate = 0.5; // Usar valor fijo para simplicidad

    for (int layerIndex = 0; layerIndex < layers.length; layerIndex++) {
      List<Graph> currentLayer = layers[layerIndex];

      for (Graph node in currentLayer) {
        double error = node.error![rowIndex];

        // Actualizar bias
        node.bias = (node.bias ?? 0.0) + learningRate * error;

        // Actualizar pesos
        List<Edge> inputEdges = getInputEdgesForPerceptron(node);

        for (Edge edge in inputEdges) {
          double inputValue;

          if (layerIndex == 0) {
            // Primera capa: usar inputs originales
            List<Graph> inputNodes = getInputGraphs();
            int inputIndex = inputNodes.indexOf(edge.start);
            inputValue = (inputIndex >= 0 && inputIndex < inputs.length)
                ? inputs[inputIndex].toDouble()
                : 0.0;
          } else {
            // Capas posteriores: usar output de la neurona anterior
            inputValue = edge.start.outputs![rowIndex];
          }

          edge.weight += learningRate * error * inputValue;
        }
      }
    }
  }

  // FUNCIONES DE ACTIVACIÓN CORRECTAS
  double _sigmoid(double x) {
    if (x > 500) return 1.0; // Evitar overflow
    if (x < -500) return 0.0;
    return 1.0 / (1.0 + exp(-x));
  }

  double _sigmoidDerivative(double sigmoidOutput) {
    return sigmoidOutput * (1.0 - sigmoidOutput);
  }

  // FUNCIÓN AUXILIAR MEJORADA
  Edge? _findEdgeBetween(Graph start, Graph end) {
    try {
      return edges.firstWhere((edge) => edge.start == start && edge.end == end);
    } catch (e) {
      return null;
    }
  }

  // PARA DEBUGGING - Imprimir estado de la red
  void _printNetworkState(List<List<Graph>> layers, int rowIndex) {
    print('--- Estado de la red ---');
    for (int i = 0; i < layers.length; i++) {
      print('Capa $i:');
      for (int j = 0; j < layers[i].length; j++) {
        Graph node = layers[i][j];
        print(
          '  Neurona $j: output=${node.outputs![rowIndex].toStringAsFixed(3)}, bias=${(node.bias ?? 0.0).toStringAsFixed(3)}',
        );
      }
    }
  }
}
