class TrainingStep {
  final int rowIndex;
  final List<int> inputs;
  final double weightedSum;
  final double output;
  final int expectedOutput;
  final double error;
  final double bias;
  final Map<String, double> weights; // Para guardar pesos de las conexiones

  TrainingStep({
    required this.rowIndex,
    required this.inputs,
    required this.weightedSum,
    required this.output,
    required this.expectedOutput,
    required this.error,
    required this.bias,
    required this.weights,
  });
}
