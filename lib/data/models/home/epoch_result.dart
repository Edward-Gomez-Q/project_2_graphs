import 'package:project_2_graphs/data/models/home/training_step.dart';

class EpochResult {
  final int epochNumber;
  final List<TrainingStep> steps;
  final double totalError;
  final bool hasConverged;
  final String perceptronId; // Para identificar el perceptrón

  EpochResult({
    required this.epochNumber,
    required this.steps,
    required this.totalError,
    required this.hasConverged,
    required this.perceptronId,
  });
}
