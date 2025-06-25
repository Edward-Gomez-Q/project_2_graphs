import 'package:flutter/material.dart';

class WeightInputDialog extends StatefulWidget {
  final double initialWeight;
  final Function(double) onWeightSet;
  final VoidCallback onCancel;

  const WeightInputDialog({
    super.key,
    required this.initialWeight,
    required this.onWeightSet,
    required this.onCancel,
  });

  @override
  State<WeightInputDialog> createState() => _WeightInputDialogState();
}

class _WeightInputDialogState extends State<WeightInputDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialWeight.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configurar Peso'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Peso del enlace',
              hintText: 'Ingrese un valor numérico',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Slider(
            value: double.tryParse(_controller.text) ?? widget.initialWeight,
            min: -1.0,
            max: 1.0,
            divisions: 20,
            onChanged: (value) {
              setState(() {
                _controller.text = value.toStringAsFixed(2);
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onCancel();
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final weight =
                double.tryParse(_controller.text) ?? widget.initialWeight;
            widget.onWeightSet(weight);
            Navigator.of(context).pop();
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
