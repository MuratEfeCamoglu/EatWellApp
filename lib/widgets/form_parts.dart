import 'package:flutter/material.dart';

import 'app_back_button.dart';

/// Back button + centred title, the header used by the profile edit screens.
class FormScreenHeader extends StatelessWidget {
  const FormScreenHeader(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Row(
        children: [
          const AppBackButton(),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
        ],
      ),
    );
  }
}

/// A titled text field, matching the sign-up / custom food forms.
class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.suffix,
    this.keyboardType,
    this.validator,
    this.enabled = true,
    this.capitalization = TextCapitalization.none,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? suffix;
  final TextInputType? keyboardType;
  final String? Function(String)? validator;
  final bool enabled;
  final TextCapitalization capitalization;
  final ValueChanged<String>? onChanged;

  static const number = TextInputType.numberWithOptions(decimal: true);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            textCapitalization: capitalization,
            onChanged: onChanged,
            decoration: InputDecoration(hintText: hint, suffixText: suffix),
            validator:
                validator == null ? null : (value) => validator!(value ?? ''),
          ),
        ],
      ),
    );
  }
}

/// A titled, wrapping row of single-choice chips (wraps instead of
/// overflowing at large text sizes). Shows [errorText] underneath when set.
class ChoiceChipGroup<T> extends StatelessWidget {
  const ChoiceChipGroup({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.errorText,
  });

  final String label;
  final List<(T, String)> options;
  final T? selected;
  final ValueChanged<T> onSelected;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (value, text) in options)
                ChoiceChip(
                  label: Text(text),
                  selected: value == selected,
                  onSelected: (_) => onSelected(value),
                ),
            ],
          ),
          if (errorText != null) ...[
            const SizedBox(height: 6),
            Text(errorText!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.error)),
          ],
        ],
      ),
    );
  }
}
