import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_state.dart';
import '../../data/custom_food.dart';
import '../../data/models.dart';
import '../../router.dart';
import '../../widgets/app_back_button.dart';

/// Lets the user add a food that isn't in the catalog (or edit / delete
/// one they added before). A new food goes straight on to the food detail
/// screen so it can be logged right away.
class CustomFoodScreen extends StatefulWidget {
  const CustomFoodScreen({
    super.key,
    this.initialName = '',
    this.barcode,
    this.initialMeal,
    this.existing,
  });

  /// Pre-filled from the search text that found nothing.
  final String initialName;

  /// Set when opened from an unrecognised barcode scan; stored with the
  /// food so the next scan of it finds this food.
  final String? barcode;

  /// Meal pre-selected on the food detail screen after saving.
  final MealType? initialMeal;

  /// When set, the screen edits this food instead of creating one.
  final CustomFood? existing;

  @override
  State<CustomFoodScreen> createState() => _CustomFoodScreenState();
}

class _CustomFoodScreenState extends State<CustomFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name =
      TextEditingController(text: widget.existing?.name ?? widget.initialName);
  late final _brand = TextEditingController(text: widget.existing?.brand);
  late final _serving = TextEditingController(
      text: widget.existing?.servingLabel ?? '1 porsiyon');
  late final _kcal =
      TextEditingController(text: _num(widget.existing?.kcalPerServing));
  late final _protein =
      TextEditingController(text: _num(widget.existing?.proteinG));
  late final _carbs = TextEditingController(text: _num(widget.existing?.carbsG));
  late final _fat = TextEditingController(text: _num(widget.existing?.fatG));
  late FoodCategory _category =
      widget.existing?.category ?? FoodCategory.atistirmalik;
  bool _saving = false;

  static String _num(num? v) {
    if (v == null) return '';
    if (v == v.roundToDouble()) return v.round().toString();
    return v.toString().replaceAll('.', ',');
  }

  @override
  void dispose() {
    for (final c in [_name, _brand, _serving, _kcal, _protein, _carbs, _fat]) {
      c.dispose();
    }
    super.dispose();
  }

  CustomFood _draft() => CustomFood(
        id: widget.existing?.id ?? '',
        name: _name.text.trim(),
        brand: _brand.text.trim(),
        servingLabel:
            _serving.text.trim().isEmpty ? '1 porsiyon' : _serving.text.trim(),
        kcalPerServing: parseNutritionNumber(_kcal.text)!.round(),
        proteinG: parseNutritionNumber(_protein.text)!,
        carbsG: parseNutritionNumber(_carbs.text)!,
        fatG: parseNutritionNumber(_fat.text)!,
        category: _category,
        barcode: widget.existing?.barcode ?? widget.barcode,
      );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final state = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _saving = true);
    try {
      final existing = widget.existing;
      if (existing != null) {
        await state.updateCustomFood(_draft());
        messenger.showSnackBar(
            SnackBar(content: Text('${_name.text.trim()} güncellendi')));
        navigator.pop();
        return;
      }
      final saved = await state.addCustomFood(_draft());
      messenger.showSnackBar(
          SnackBar(content: Text('${saved.name} kaydedildi')));
      navigator.pushReplacement(AppRoutes.pushFoodDetail(
        saved.asFoodItem,
        initialMeal: widget.initialMeal,
        source: FoodLogSource.custom,
        sourceRef: saved.id,
      ));
    } catch (_) {
      if (mounted) setState(() => _saving = false);
      messenger.showSnackBar(const SnackBar(
          content: Text('Yiyecek kaydedilemedi, lütfen tekrar dene.')));
    }
  }

  Future<void> _delete(CustomFood food) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yiyeceği sil'),
        content: Text(
            '${food.name} listenden silinsin mi? Günlüğe daha önce eklediğin '
            'kayıtlar etkilenmez.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await context.read<AppState>().deleteCustomFood(food.id);
    } catch (_) {
      messenger.showSnackBar(const SnackBar(
          content: Text('Silinemedi, lütfen tekrar dene.')));
      return;
    }
    messenger.showSnackBar(SnackBar(content: Text('${food.name} silindi')));
    navigator.pop();
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    String? hint,
    String? suffix,
    bool number = false,
    String? Function(String)? validator,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.titleSmall),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            textCapitalization: capitalization,
            keyboardType: number
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            decoration: InputDecoration(hintText: hint, suffixText: suffix),
            validator:
                validator == null ? null : (value) => validator(value ?? ''),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final existing = widget.existing;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Row(
                children: [
                  AppBackButton(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      existing == null ? 'Yiyeceği kendin ekle' : 'Yiyeceği düzenle',
                      style: textTheme.titleLarge,
                    ),
                  ),
                  if (existing != null)
                    IconButton(
                      tooltip: 'Sil',
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () => _delete(existing),
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.barcode != null) ...[
                        Text('Barkod: ${widget.barcode}',
                            style: textTheme.bodyMedium),
                        const SizedBox(height: 16),
                      ],
                      _field('Ad', _name,
                          hint: 'Örn. Annemin böreği',
                          validator: validateCustomFoodName,
                          capitalization: TextCapitalization.sentences),
                      _field('Marka', _brand, hint: 'İsteğe bağlı'),
                      _field('Porsiyon', _serving, hint: 'Örn. 1 dilim (120 g)'),
                      Text(
                        'Aşağıdaki değerler bir porsiyon içindir.',
                        style: textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      _field('Kalori', _kcal,
                          suffix: 'kcal', number: true, validator: (v) {
                        if (v.trim().isEmpty) return 'Kalori gerekli';
                        return validateKcal(v);
                      }),
                      _field('Protein', _protein,
                          suffix: 'g', number: true, validator: validateMacro),
                      _field('Karbonhidrat', _carbs,
                          suffix: 'g', number: true, validator: validateMacro),
                      _field('Yağ', _fat,
                          suffix: 'g', number: true, validator: validateMacro),
                      Text('Kategori', style: textTheme.titleSmall),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<FoodCategory>(
                        initialValue: _category,
                        isExpanded: true,
                        items: [
                          for (final c in FoodCategory.values)
                            DropdownMenuItem(
                              value: c,
                              child: Text(c.label,
                                  overflow: TextOverflow.ellipsis),
                            ),
                        ],
                        onChanged: (c) {
                          if (c != null) setState(() => _category = c);
                        },
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
