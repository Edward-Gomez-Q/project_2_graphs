import 'package:flutter/material.dart';
import 'package:project_2_graphs/data/models/home/graph_type.dart';

class GraphTypeSelector extends StatelessWidget {
  final Function(GraphType) onTypeSelected;
  const GraphTypeSelector({super.key, required this.onTypeSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seleccionar tipo de nodo:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTypeChip(context, GraphType.input, 'Input', Colors.green),
              _buildTypeChip(
                context,
                GraphType.perceptron,
                'Perceptron',
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(
    BuildContext context,
    GraphType type,
    String label,
    Color color,
  ) {
    return ActionChip(
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.2),
      avatar: CircleAvatar(backgroundColor: color, radius: 8),
      onPressed: () => onTypeSelected(type),
    );
  }
}
