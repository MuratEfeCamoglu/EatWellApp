import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_back_button.dart';

/// Port of project/SetupHeight.dc.html — step 3/6 of the setup flow.
///
/// The design's draggable ruler is rebuilt as a [CustomPaint] tick strip
/// driven by horizontal drag gestures rather than the exact static markup.
/// The cm/ft-in toggle only changes how the value is *displayed* — the
/// underlying value and the drag ruler stay in centimeters (simplification).
class SetupHeightScreen extends StatefulWidget {
  const SetupHeightScreen({super.key});

  @override
  State<SetupHeightScreen> createState() => _SetupHeightScreenState();
}

class _SetupHeightScreenState extends State<SetupHeightScreen> {
  static const _minCm = 120.0;
  static const _maxCm = 220.0;
  static const _pxPerCm = 10.0;

  late double _heightCm = AppState.instance.draft.heightCm;
  bool _isCm = true;

  void _onDrag(double dx) {
    setState(() {
      _heightCm = (_heightCm - dx / _pxPerCm).clamp(_minCm, _maxCm);
    });
  }

  String get _valueText {
    if (_isCm) return _heightCm.round().toString();
    final totalInches = _heightCm / 2.54;
    final feet = (totalInches / 12).floor();
    final inches = (totalInches % 12).round();
    return "$feet'$inches\"";
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
                  const _SetupProgressHeader(step: 3, label: 'Boy'),
                  const SizedBox(height: 32),
                  Text(
                    'Boyun kaç?',
                    style: textTheme.headlineLarge?.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cetveli sağa sola kaydırarak boyunu ayarla.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  _UnitToggle(
                    leftLabel: 'cm',
                    rightLabel: 'ft / in',
                    isLeft: _isCm,
                    onChanged: (isLeft) => setState(() => _isCm = isLeft),
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
                        if (_isCm) ...[
                          const SizedBox(width: 8),
                          Text('cm',
                              style: textTheme.bodyMedium
                                  ?.copyWith(fontSize: 20, fontWeight: FontWeight.w800)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _RulerPicker(
                    value: _heightCm,
                    onDrag: _onDrag,
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
                    AppState.instance.draft.heightCm = _heightCm;
                    Navigator.of(context).pushNamed(AppRoutes.setupWeight);
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
              color: selected ? scheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant,
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
