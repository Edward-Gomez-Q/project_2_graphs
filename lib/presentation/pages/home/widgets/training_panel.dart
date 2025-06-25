import 'package:flutter/material.dart';
import 'package:project_2_graphs/data/models/home/graph.dart';
import 'package:project_2_graphs/data/models/home/network_data.dart';

class TrainingPanel extends StatefulWidget {
  final NetworkData networkData;

  const TrainingPanel({super.key, required this.networkData});

  @override
  State<TrainingPanel> createState() => _TrainingPanelState();
}

class _TrainingPanelState extends State<TrainingPanel> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tabla', style: Theme.of(context).textTheme.titleMedium),
                  IconButton(
                    icon: const Icon(Icons.arrow_drop_down),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            _buildTrainingTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingTable() {
    List<Graph> inputNodes = widget.networkData.getInputGraphs();
    List<Graph> perceptronNodes = widget.networkData.getPerceptronGraphs();
    int rowsLength = widget.networkData.rowsLength;

    if (inputNodes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'No hay suficientes nodos de entrada o perceptrones para mostrar la tabla.',
        ),
      );
    }
    // Validación adicional para evitar errores de índice
    for (Graph perceptron in perceptronNodes) {
      if (perceptron.weightedSum == null ||
          perceptron.outputs == null ||
          perceptron.error == null ||
          perceptron.expectedOutputs == null ||
          perceptron.weightedSum!.length != rowsLength ||
          perceptron.error!.length != rowsLength ||
          perceptron.expectedOutputs!.length != rowsLength) {
        // Reinicializar si hay inconsistencia
        widget.networkData.updatePerceptronValues();
        break;
      }
    }
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            ),
            columns: [
              //Columnas de entradas
              ...List.generate(
                inputNodes.length,
                (i) => DataColumn(
                  label: Text(
                    'X${i + 1}',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              //Columnas de perceptrones
              ...List.generate(
                perceptronNodes.length,
                (i) => DataColumn(
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'P${i + 1}',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Z | Salida | Error | Esperado',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            rows: List.generate(rowsLength, (rowIndex) {
              return DataRow(
                cells: [
                  // Celdas de entradas
                  ...List.generate(inputNodes.length, (colIndex) {
                    final inputValue =
                        widget.networkData.trainingInputs[rowIndex][colIndex];
                    return DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          inputValue.toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    );
                  }),
                  // Celdas de perceptrones
                  ...List.generate(perceptronNodes.length, (colIndex) {
                    //
                    final perceptron = perceptronNodes[colIndex];
                    final weightedSum = perceptron.weightedSum![rowIndex];
                    final output = perceptron.outputs![rowIndex];
                    final error = perceptron.error![rowIndex];
                    final expectedOutput =
                        perceptron.expectedOutputs![rowIndex];
                    return DataCell(
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Weighted Sum
                            Text(
                              weightedSum.toStringAsFixed(2),
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            // Output
                            Text(
                              output.toString(),
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            // Error
                            Text(
                              error.toStringAsFixed(2),
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            // Expected Output
                            Container(
                              width: 24,
                              height: 20,
                              decoration: BoxDecoration(
                                color: expectedOutput == 1
                                    ? Colors.green.shade100
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: expectedOutput == 1
                                      ? Colors.green.shade400
                                      : Colors.grey.shade400,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  expectedOutput.toString(),
                                  style: Theme.of(context).textTheme.bodySmall!
                                      .copyWith(
                                        color: expectedOutput == 1
                                            ? Colors.green.shade800
                                            : Colors.grey.shade700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          // Cambiar el valor de expectedOutputs en esta celda
                          perceptron.expectedOutputs![rowIndex] =
                              perceptron.expectedOutputs![rowIndex] == 1
                              ? 0
                              : 1;
                        });
                      },
                    );
                  }),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
