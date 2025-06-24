import 'package:flutter/material.dart';
import 'package:project_2_graphs/data/models/home/operation_mod.dart';

class ModButton extends StatelessWidget {
  final OperationMod mod;
  final IconData icon;
  final OperationMod actualMod;
  final VoidCallback onPressed;

  const ModButton({
    super.key,
    required this.mod,
    required this.icon,
    required this.actualMod,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final isSelected = actualMod == mod;
    return CircleAvatar(
      backgroundColor: isSelected
          ? theme.colorScheme.primary
          : theme.colorScheme.surface,
      foregroundColor: isSelected
          ? theme.colorScheme.onPrimary
          : theme.colorScheme.onSurface,
      child: IconButton(
        icon: Icon(
          icon,
          color: isSelected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface,
          size: theme.iconTheme.size,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
