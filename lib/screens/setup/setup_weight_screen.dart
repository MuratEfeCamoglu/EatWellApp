import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_back_button.dart';

/// Port of project/SetupWeight.dc.html — step 4/6 of the setup flow.
///
/// The design's draggable ruler is rebuilt as a [CustomPaint] tick strip
/// driven by horizontal drag gestures. The kg/lb toggle only changes how the
/// value is *displayed* — the underlying value stays in kilograms
/// (simplification). The BMI shown uses the height entered on the previous
/// setup step, carried over via [AppState.draft].
class SetupWeightScreen extends StatefulWidget {
  const SetupWeightScreen({super.key});

  @override
  State<SetupWeightScreen> createState() => _SetupWeightScreenState();
}

class _SetupWeightScreenState extends State<SetupWeightScreen> {
  static const _minKg = 30.0;
  static const _maxKg = 200.0;
  static const _pxPerKg = 10.0;

  late double _weightKg = AppState.instance.draft.weightKg;
  bool _isKg = true;

  void _onDrag(double dx) {
    setState(() {
      _weightKg = (_weightKg - dx / _pxPerKg).clamp(_minKg, _maxKg);
    });
  }

  String get _valueText {
    final v = _isKg ? _weightKg : _weightKg * 2.20462;
    return v.toStringAsFixed(1).replaceAll('.', ',');
  }

  double get _bmi {
    final heightM = AppState.instance.draft.heightCm / 100;
    return _weightKg / (heightM * heightM);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SetupProgressHeader(step: 4, label: 'Kilo'),
                  const SizedBox(height: 32),
                  Text(
                    'Şu anki kilon?',
                    style: textTheme.headlineLarge?.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Başlangıç noktanı kaydedelim; ilerlemeni buna göre göstereceğiz.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  _UnitToggle(
                    leftLabel: 'kg',
                    rightLabel: 'lb',
                    isLeft: _isKg,
                    onChanged: (isLeft) => setState(() => _isKg = isLeft),
                  ),
                  const SizedBox(height: 48),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _valueText,
                          style: const TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(_isKg ? 'kg' : 'lb',
                            style: textTheme.bodyMedium
                                ?.copyWith(fontSize: 20, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _RulerPicker(value: _weightKg, onDrag: _onDrag),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.monitor_weight_rounded,
                            size: 20, color: AppTheme.primaryText(scheme.brightness)),
                        const SizedBox(width: 12),
                        Text(
                          'Vücut kitle indeksin: ${_bmi.toStringAsFixed(1).replaceAll('.', ',')}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryText(scheme.brightness),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    AppState.instance.draft.weightKg = _weightKg;
                    Navigator.of(context).pushNamed(AppRoutes.setupActivity);
                  },
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

/// Segmented cm / ft-in (or kg / lb) unit toggle used on the height and
/// weight setup screens.
class _UnitToggle extends StatelessWidget {
  const _UnitToggle({
    required this.leftLabel,
    required this.rightLabel,
    required this.isLeft,
    required this.onChanged,
  });

  final String leftLabel;
  final String rightLabel;
  final bool isLeft;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.dengeColors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.trackBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: _segment(context, leftLabel, isLeft, () => onChanged(true))),
          Expanded(child: _segment(context, rightLabel, !isLeft, () => onChanged(false))),
        ],
      ),
    );
  }

  Widget _segment(
      BuildContext context, String label, bool selected, VoidCallback onTap) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? scheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

/// The draggable ruler used by the height and weight setup screens: ticks
/// scroll horizontally underneath a fixed center indicator as the user drags.
class _RulerPicker extends StatelessWidget {
  const _RulerPicker({required this.value, required this.onDrag});

  final double value;
  final ValueChanged<double> onDrag;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.dengeColors;
    return GestureDetector(
      onHorizontalDragUpdate: (details) => onDrag(details.delta.dx),
      child: Container(
        height: 96,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size.infinite,
              painter: _RulerPainter(
                value: value,
                minorColor: colors.divider,
                majorColor: Theme.of(context).textTheme.bodyMedium?.color ??
                    colors.divider,
              ),
            ),
            Positioned(
              top: 8,
              child: Container(
                width: 4,
                height: 64,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  _RulerPainter({
    required this.value,
    required this.minorColor,
    required this.majorColor,
  });

  final double value;
  final Color minorColor;
  final Color majorColor;

  static const _pxPerUnit = 10.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.width / 2;
    final firstVisible = (value - center / _pxPerUnit).floor() - 1;
    final lastVisible = (value + center / _pxPerUnit).ceil() + 1;
    final midY = size.height / 2 - 8;

    for (int i = firstVisible; i <= lastVisible; i++) {
      final x = center + (i - value) * _pxPerUnit;
      if (x < -4 || x > size.width + 4) continue;
      final isMajor = i % 5 == 0;
      final tickHeight = isMajor ? 40.0 : 24.0;
      final paint = Paint()
        ..color = isMajor ? majorColor : minorColor
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(x, midY - tickHeight / 2),
        Offset(x, midY + tickHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RulerPainter oldDelegate) =>
      oldDelegate.value != value;
}

/// The "Adım X / 6" step header + back button + progress dots used by every
/// screen in the setup flow (project/Setup*.dc.html). Duplicated privately in
/// each setup screen file rather than extracted to a shared widget, since
/// each of these screens is edited independently.
class _SetupProgressHeader extends StatelessWidget {
  const _SetupProgressHeader({
    required this.step,
    required this.label,
  });

  static const totalSteps = 6;

  final int step;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.dengeColors;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const AppBackButton(),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Adım $step / $totalSteps',
                      style: textTheme.bodySmall
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  Text(label,
                      style: textTheme.bodySmall
                          ?.copyWith(fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(totalSteps, (i) {
                  final filled = i < step;
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: i == totalSteps - 1 ? 0 : 4),
                      height: 6,
                      decoration: BoxDecoration(
                        color: filled ? scheme.primary : colors.trackBackground,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
