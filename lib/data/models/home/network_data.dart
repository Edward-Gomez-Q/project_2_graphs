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

  int epochs = 1000;
  int currentEpoch = 0;
  List<List<int>> trainingInputs = [];
  double learningRate = 0.01;

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
    }

    if (currentEpoch >= epochs || hasConverged || !isTraining) {
      isTraining = false;
      currentTrainingHistory?.finish();
      return;
    }

    print('=== Época Multicapa ${currentEpoch + 1} ===');
    double totalError = 0.0;

    for (int rowIndex = 0; rowIndex < rowsLength; rowIndex++) {
      List<int> inputs = trainingInputs[rowIndex];
      _forwardPass(layers, inputs, rowIndex);
      Graph outputPerceptron = layers.last[0];
      int expectedOutput = outputPerceptron.expectedOutputs![rowIndex];
      double actualOutput = outputPerceptron.outputs![rowIndex];
      double outputError = expectedOutput - actualOutput;
      outputPerceptron.error![rowIndex] = outputError;
      totalError += outputError.abs();
      _backwardPass(layers, rowIndex);
      _updateWeights(layers, inputs, rowIndex);
      print(
        'Fila $rowIndex: Output=${actualOutput.toInt()}, Expected=$expectedOutput, Error=${outputError.toStringAsFixed(3)}',
      );
    }

    print('Error total multicapa: ${totalError.toStringAsFixed(3)}');

    currentEpoch++;

    // Verificar convergencia
    if (totalError == 0) {
      hasConverged = true;
      isTraining = false;
      print("¡Convergencia multicapa alcanzada en la época $currentEpoch!");
      return;
    }

    // Continuar entrenamiento
    if (currentEpoch < epochs && isTraining) {
      Future.delayed(duration, () {
        if (isTraining) {
          _trainMultilayerNetwork(layers, duration);
        }
      });
    } else {
      isTraining = false;
      print("Entrenamiento multicapa finalizado");
    }
  }

  void _forwardPass(List<List<Graph>> layers, List<int> inputs, int rowIndex) {
    // Procesar cada capa
    for (int layerIndex = 0; layerIndex < layers.length; layerIndex++) {
      List<Graph> currentLayer = layers[layerIndex];

      for (Graph perceptron in currentLayer) {
        double weightedSum;

        if (layerIndex == 0) {
          // Primera capa oculta: usar inputs originales
          weightedSum = _calculateWeightedSum(perceptron, inputs);
        } else {
          // Capas siguientes: usar outputs de la capa anterior
          List<double> previousOutputs = [];
          List<Graph> previousLayer = layers[layerIndex - 1];

          for (Graph prevPerceptron in previousLayer) {
            if (perceptron.inputsGraphs != null &&
                perceptron.inputsGraphs!.contains(prevPerceptron)) {
              previousOutputs.add(prevPerceptron.outputs![rowIndex]);
            }
          }

          weightedSum = _calculateWeightedSumFromOutputs(
            perceptron,
            previousOutputs,
          );
        }

        perceptron.weightedSum![rowIndex] = weightedSum;
        double output = activationFunction(weightedSum);
        perceptron.outputs![rowIndex] = output;
      }
    }
  }

  // Backward pass: propagar errores hacia atrás
  void _backwardPass(List<List<Graph>> layers, int rowIndex) {
    // Procesar capas desde la salida hacia la entrada
    for (int layerIndex = layers.length - 2; layerIndex >= 0; layerIndex--) {
      List<Graph> currentLayer = layers[layerIndex];
      List<Graph> nextLayer = layers[layerIndex + 1];

      for (Graph perceptron in currentLayer) {
        double errorSum = 0.0;

        // Sumar errores ponderados de la capa siguiente
        for (Graph nextPerceptron in nextLayer) {
          if (nextPerceptron.inputsGraphs != null &&
              nextPerceptron.inputsGraphs!.contains(perceptron)) {
            // Encontrar el peso de la conexión
            Edge? connectionEdge = _findEdgeBetween(perceptron, nextPerceptron);
            if (connectionEdge != null) {
              double nextError = nextPerceptron.error![rowIndex];
              errorSum += nextError * connectionEdge.weight;
            }
          }
        }

        // Error = errorSum * derivada de la función de activación
        double output = perceptron.outputs![rowIndex];
        double derivative = _activationDerivative(output);
        perceptron.error![rowIndex] = errorSum * derivative;
      }
    }
  }

  // Actualizar pesos y bias
  void _updateWeights(
    List<List<Graph>> layers,
    List<int> originalInputs,
    int rowIndex,
  ) {
    for (int layerIndex = 0; layerIndex < layers.length; layerIndex++) {
      List<Graph> currentLayer = layers[layerIndex];

      for (Graph perceptron in currentLayer) {
        double error = perceptron.error![rowIndex];

        // Actualizar pesos de las conexiones de entrada
        List<Edge> inputEdges = getInputEdgesForPerceptron(perceptron);

        for (Edge edge in inputEdges) {
          double inputValue;

          if (layerIndex == 0) {
            // Primera capa: usar inputs originales
            List<Graph> inputGraphs = getInputGraphs();
            int inputIndex = inputGraphs.indexOf(edge.start);
            inputValue =
                (inputIndex != -1 && inputIndex < originalInputs.length)
                ? originalInputs[inputIndex].toDouble()
                : 0.0;
          } else {
            // Capas posteriores: usar output del perceptrón anterior
            inputValue = edge.start.outputs![rowIndex];
          }

          edge.weight += learningRate * error * inputValue;
        }

        // Actualizar bias
        perceptron.bias = (perceptron.bias ?? 0.0) + learningRate * error;
      }
    }
  }

  // Funciones auxiliares
  double _calculateWeightedSum(Graph perceptron, List<int> inputs) {
    double sum = perceptron.bias ?? 0.0;
    List<Edge> inputEdges = getInputEdgesForPerceptron(perceptron);
    List<Graph> inputGraphs = getInputGraphs();

    for (Edge edge in inputEdges) {
      int inputIndex = inputGraphs.indexOf(edge.start);
      if (inputIndex != -1 && inputIndex < inputs.length) {
        sum += edge.weight * inputs[inputIndex];
      }
    }

    return sum;
  }

  double _calculateWeightedSumFromOutputs(
    Graph perceptron,
    List<double> previousOutputs,
  ) {
    double sum = perceptron.bias ?? 0.0;
    List<Edge> inputEdges = getInputEdgesForPerceptron(perceptron);

    for (int i = 0; i < inputEdges.length && i < previousOutputs.length; i++) {
      sum += inputEdges[i].weight * previousOutputs[i];
    }

    return sum;
  }

  Edge? _findEdgeBetween(Graph start, Graph end) {
    return edges.firstWhere(
      (edge) => edge.start == start && edge.end == end,
      orElse: () => null as Edge,
    );
  }

  double _activationDerivative(double output) {
    // Para función escalón, usar aproximación con sigmoid
    // Si usas sigmoid: return output * (1 - output);
    // Para escalón, usar una constante pequeña
    return 0.1;
  }
}
