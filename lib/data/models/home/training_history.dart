import 'package:project_2_graphs/data/models/home/epoch_result.dart';

class TrainingHistory {
  final String networkType; // "simple" o "multilayer"
  final DateTime startTime;
  DateTime? endTime;
  final List<EpochResult> epochs;
  final Map<String, dynamic> hyperparameters; // learning rate, etc.

  TrainingHistory({
    required this.networkType,
    required this.startTime,
    required this.hyperparameters,
    this.endTime,
  }) : epochs = [];

  void addEpoch(EpochResult epoch) {
    epochs.add(epoch);
  }

  void finish() {
    endTime = DateTime.now();
  }

  Duration get trainingDuration {
    return (endTime ?? DateTime.now()).difference(startTime);
  }
}
