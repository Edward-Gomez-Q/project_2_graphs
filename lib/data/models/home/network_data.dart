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

  int epochs = 100;
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
    trainPerceptron(graph);
    return true;
  }

  void trainPerceptron(Graph perceptron) {
    if (currentEpoch >= epochs || hasConverged || !isTraining) {
      isTraining = false;
      currentTrainingHistory?.finish();
      print("Entrenamiento completado después de $currentEpoch épocas");
      return;
    }

    print('=== Época ${currentEpoch + 1} ===');
    double totalError = 0.0;
    List<TrainingStep> epochSteps = [];

    // Procesar todas las combinaciones de entrada en esta época
    for (int rowIndex = 0; rowIndex < rowsLength; rowIndex++) {
      List<int> inputs = trainingInputs[rowIndex];

      // Calcular la suma ponderada
      double weightedSum = calculatePerceptronOutput(perceptron, inputs);
      perceptron.weightedSum![rowIndex] = weightedSum;

      // Aplicar función de activación
      double output = activationFunction(weightedSum);
      perceptron.outputs![rowIndex] = output;

      // El valor esperado debe ser configurado manualmente por el usuario
      // o basado en la operación lógica deseada
      int expectedOutput = perceptron.expectedOutputs![rowIndex];

      // Calcular error
      double error = expectedOutput - output;
      perceptron.error![rowIndex] = error;
      totalError += error.abs();

      // Registrar pesos actuales antes de actualizarlos
      Map<String, double> currentWeights = {};
      List<Edge> inputEdges = getInputEdgesForPerceptron(perceptron);
      for (int i = 0; i < inputEdges.length; i++) {
        currentWeights['edge_$i'] = inputEdges[i].weight;
      }
      // Registrar este paso del entrenamiento
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

      // Actualizar pesos (algoritmo del perceptrón)
      if (error != 0) {
        List<Edge> inputEdges = getInputEdgesForPerceptron(perceptron);
        List<Graph> inputGraphs = getInputGraphs();

        for (Edge edge in inputEdges) {
          int inputIndex = inputGraphs.indexOf(edge.start);
          if (inputIndex != -1 && inputIndex < inputs.length) {
            edge.weight += learningRate * error * inputs[inputIndex];
          }
        }

        // Actualizar bias
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
      Future.delayed(Duration(milliseconds: 500), () {
        if (isTraining) {
          trainPerceptron(perceptron);
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
}
