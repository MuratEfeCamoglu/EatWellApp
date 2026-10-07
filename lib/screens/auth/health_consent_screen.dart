import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/health_consent.dart';
import '../../router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_back_button.dart';

/// Shown right after sign-up, before the setup wizard: asks about food
/// allergies (F21) and collects KVKK explicit consent (F20). The wizard
/// cannot be reached without ticking the consent box.
class HealthConsentScreen extends StatefulWidget {
  const HealthConsentScreen({super.key});

  @override
  State<HealthConsentScreen> createState() => _HealthConsentScreenState();
}

class _HealthConsentScreenState extends State<HealthConsentScreen> {
  late final Set<Allergen> _selected = {
    ...AppState.instance.allergies.allergens,
  };
  late final _otherController = TextEditingController(
    text: AppState.instance.allergies.otherNote,
  );
  bool _consentGiven = false;
  bool _saving = false;

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    setState(() => _saving = true);
    await AppState.instance.saveHealthConsent(
      allergies: AllergyProfile(
        allergens: _selected,
        otherNote: _otherController.text,
      ),
      now: DateTime.now(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pushNamed(AppRoutes.setupGender);
  }

  void _showPrivacyNotice() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aydınlatma metni',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                kPrivacyNoticePlaceholder,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppBackButton(),
                    const SizedBox(height: 24),
                    Text(
                      'Alerjin var mı?',
                      style: textTheme.headlineLarge?.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Alerjen içeren yiyecekleri ayırt edebilmen için '
                      'kaydediyoruz. Birden fazla seçebilirsin.',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('Alerjim yok'),
                          selected: _selected.isEmpty,
                          onSelected: (_) => setState(_selected.clear),
                        ),
                        for (final allergen in Allergen.values)
                          FilterChip(
                            label: Text(allergen.label),
                            selected: _selected.contains(allergen),
                            onSelected: (on) => setState(() {
                              on
                                  ? _selected.add(allergen)
                                  : _selected.remove(allergen);
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('Diğer (isteğe bağlı)', style: textTheme.titleSmall),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _otherController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLength: 100,
                      decoration: const InputDecoration(
                        hintText: 'Örn. çilek, kivi',
                        prefixIcon: Icon(Icons.edit_note_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ConsentCard(
                      consentGiven: _consentGiven,
                      onChanged: (value) =>
                          setState(() => _consentGiven = value),
                      onOpenNotice: _showPrivacyNotice,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _consentGiven && !_saving ? _continue : null,
                  child: const Text('Devam'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsentCard extends StatelessWidget {
  const _ConsentCard({
    required this.consentGiven,
    required this.onChanged,
    required this.onOpenNotice,
  });

  final bool consentGiven;
  final ValueChanged<bool> onChanged;
  final VoidCallback onOpenNotice;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // A Material (not a decorated Container) so the CheckboxListTile's ink
    // splash is painted on the card instead of hidden behind it.
    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.dengeColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shield_rounded, size: 20, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('KVKK onayı', style: textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Kilo, beslenme ve alerji bilgilerin sağlık verisi sayılır. '
              'Devam etmek için aydınlatma metnini okuyup açık rıza vermen '
              'gerekiyor.',
              style: textTheme.bodyMedium,
            ),
            TextButton(
              onPressed: onOpenNotice,
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: const Text('Aydınlatma metnini oku'),
            ),
            CheckboxListTile(
              value: consentGiven,
              onChanged: (value) => onChanged(value ?? false),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(kConsentCheckboxText, style: textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}
