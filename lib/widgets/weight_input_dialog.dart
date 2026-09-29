import 'package:flutter/material.dart';

/// Shows a "enter a weight in kg" dialog and returns the entered value, or
/// null if cancelled. [validate] may return an error message for values
/// that are numeric and in range but otherwise unacceptable.
Future<double?> showWeightInputDialog(
  BuildContext context, {
  required String title,
  required double initialKg,
  String? Function(double value)? validate,
}) {
  return showDialog<double>(
    context: context,
    builder: (context) => _WeightInputDialog(
      title: title,
      initialKg: initialKg,
      validate: validate,
    ),
  );
}

/// Owns its [TextEditingController] so the controller outlives the
/// dialog's closing animation and is disposed only when the dialog is
/// actually removed from the tree.
class _WeightInputDialog extends StatefulWidget {
  const _WeightInputDialog({
    required this.title,
    required this.initialKg,
    required this.validate,
  });

  final String title;
  final double initialKg;
  final String? Function(double value)? validate;

  @override
  State<_WeightInputDialog> createState() => _WeightInputDialogState();
}

class _WeightInputDialogState extends State<_WeightInputDialog> {
  late final _controller =
      TextEditingController(text: widget.initialKg.round().toString());
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = double.tryParse(_controller.text.replaceAll(',', '.'));
    if (value == null || value < 30 || value > 300) {
      setState(() => _error = 'Geçerli bir kilo girin');
      return;
    }
    final error = widget.validate?.call(value);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(suffixText: 'kg', errorText: _error),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Vazgeç'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Kaydet')),
      ],
    );
  }
}
