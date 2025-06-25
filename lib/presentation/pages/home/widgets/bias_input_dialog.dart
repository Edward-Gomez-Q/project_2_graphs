import 'package:flutter/material.dart';

class BiasInputDialog extends StatefulWidget {
  final double initialBias;
  final Function(double) onBiasSet;
  final VoidCallback onCancel;
  const BiasInputDialog({
    super.key,
    required this.initialBias,
    required this.onBiasSet,
    required this.onCancel,
  });

  @override
  State<BiasInputDialog> createState() => _BiasInputDialogState();
}

class _BiasInputDialogState extends State<BiasInputDialog> {
  late TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialBias.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configurar Sesgo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Sesgo',
              hintText: 'Ingrese un valor numérico',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Slider(
            value: double.tryParse(_controller.text) ?? widget.initialBias,
            min: 0.0,
            max: 1.0,
            divisions: 25,
            onChanged: (value) {
              setState(() {
                _controller.text = value.toStringAsFixed(2);
              });
            },
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            final weight =
                double.tryParse(_controller.text) ?? widget.initialBias;
            widget.onBiasSet(weight);
            Navigator.of(context).pop();
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
