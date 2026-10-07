import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_state.dart';
import '../../data/custom_food.dart' show parseNutritionNumber;
import '../../data/profile_validation.dart';
import '../../widgets/form_parts.dart';
import '../../widgets/section_card.dart';
import '../../widgets/weight_input_dialog.dart';

/// "Kişisel bilgiler": name, e-mail, gender, age, height and activity
/// level, plus the current weight (logged through the same history as the
/// Progress tab). Changing these doesn't silently rewrite the calorie goal;
/// the goals screen offers the recalculation.
class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AppState _state = context.read<AppState>();
  late final _name = TextEditingController(text: _state.user.name);
  late final _email = TextEditingController(text: _state.user.email);
  late final _age = TextEditingController(text: _state.age?.toString() ?? '');
  late final _height = TextEditingController(text: _num(_state.user.heightCm));
  late Gender? _gender = _state.gender;
  late ActivityLevel? _activity = _state.activityLevel;
  bool _showChoiceErrors = false;
  bool _saving = false;

  static String _num(double v) {
    if (v <= 0) return '';
    if (v == v.roundToDouble()) return v.round().toString();
    return v.toStringAsFixed(1).replaceAll('.', ',');
  }

  @override
  void dispose() {
    for (final c in [_name, _email, _age, _height]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _updateWeight() async {
    final current = _state.user.weightKg;
    final result = await showWeightInputDialog(
      context,
      title: 'Kilonu güncelle',
      initialKg: current > 0 ? current : 70,
    );
    if (result == null || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _state.logWeight(result);
    } catch (_) {
      messenger.showSnackBar(const SnackBar(
          content: Text('Kilo kaydedilemedi, lütfen tekrar dene.')));
    }
  }

  Future<void> _save() async {
    final formOk = _formKey.currentState!.validate();
    setState(() => _showChoiceErrors = true);
    if (!formOk || _gender == null || _activity == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _saving = true);
    try {
      await _state.updatePersonalInfo(
        name: _name.text,
        email: _email.text,
        gender: _gender,
        age: int.parse(_age.text.trim()),
        heightCm: parseNutritionNumber(_height.text)!,
        activityLevel: _activity,
      );
    } catch (_) {
      if (mounted) setState(() => _saving = false);
      messenger.showSnackBar(const SnackBar(
          content: Text('Bilgiler kaydedilemedi, lütfen tekrar dene.')));
      return;
    }
    messenger.showSnackBar(
        const SnackBar(content: Text('Kişisel bilgilerin kaydedildi')));
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weightKg = context.watch<AppState>().user.weightKg;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const FormScreenHeader('Kişisel bilgiler'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LabeledTextField(
                        label: 'Ad Soyad',
                        controller: _name,
                        capitalization: TextCapitalization.words,
                        validator: validateName,
                      ),
                      LabeledTextField(
                        label: 'E-posta',
                        controller: _email,
                        hint: 'İsteğe bağlı',
                        keyboardType: TextInputType.emailAddress,
                        validator: validateEmail,
                      ),
                      ChoiceChipGroup<Gender>(
                        label: 'Cinsiyet',
                        options: [for (final g in Gender.values) (g, g.label)],
                        selected: _gender,
                        onSelected: (g) => setState(() => _gender = g),
                        errorText: _showChoiceErrors && _gender == null
                            ? 'Cinsiyet seç'
                            : null,
                      ),
                      LabeledTextField(
                        label: 'Yaş',
                        controller: _age,
                        keyboardType: TextInputType.number,
                        validator: validateAge,
                      ),
                      LabeledTextField(
                        label: 'Boy',
                        controller: _height,
                        suffix: 'cm',
                        keyboardType: LabeledTextField.number,
                        validator: validateHeight,
                      ),
                      ChoiceChipGroup<ActivityLevel>(
                        label: 'Aktivite düzeyi',
                        options: [
                          for (final a in ActivityLevel.values) (a, a.label)
                        ],
                        selected: _activity,
                        onSelected: (a) => setState(() => _activity = a),
                        errorText: _showChoiceErrors && _activity == null
                            ? 'Aktivite düzeyini seç'
                            : null,
                      ),
                      Text('Kilo', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      SectionCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    weightKg > 0
                                        ? '${_num(weightKg)} kg'
                                        : 'Henüz girilmedi',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  Text(
                                    'Kilo geçmişine ve İlerleme grafiğine eklenir.',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: _updateWeight,
                              // The theme's full-width minimum size can't
                              // lay out inside a Row.
                              style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 48)),
                              child: const Text('Güncelle'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Kaydet'),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
