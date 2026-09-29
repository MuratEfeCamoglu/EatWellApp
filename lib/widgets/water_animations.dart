import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A rounded "tank" whose water level eases to [progress] (0–1) while two
/// sine waves roll continuously across its surface.
class WaterWaveBar extends StatefulWidget {
  const WaterWaveBar({super.key, required this.progress, required this.label});

  final double progress;
  final String label;

  @override
  State<WaterWaveBar> createState() => _WaterWaveBarState();
}

class _WaterWaveBarState extends State<WaterWaveBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wave = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void initState() {
    super.initState();
    _syncWave();
  }

  @override
  void didUpdateWidget(WaterWaveBar old) {
    super.didUpdateWidget(old);
    _syncWave();
  }

  /// Only roll the waves while there is a partial fill to animate — an
  /// empty or full tank has no visible water front, so the ticker would
  /// just burn frames.
  void _syncWave() {
    final partial = widget.progress > 0 && widget.progress < 1;
    if (partial && !_wave.isAnimating) {
      _wave.repeat();
    } else if (!partial && _wave.isAnimating) {
      _wave.stop();
    }
  }

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.dengeColors;
    final theme = Theme.of(context);
    // Isolate the per-frame wave repaint from the rest of the home page.
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 48,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: widget.progress.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, level, _) => AnimatedBuilder(
              animation: _wave,
              builder: (context, _) => CustomPaint(
                painter: _HorizontalWavePainter(
                  level: level,
                  phase: _wave.value * 2 * math.pi,
                  background: colors.waterContainer,
                  color: colors.water,
                ),
                child: Center(
                  child: Text(
                    widget.label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: level > 0.5 ? Colors.white : colors.water,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fills the tank from the left up to [level], with a wavy vertical front
/// so the water edge looks like it's sloshing.
class _HorizontalWavePainter extends CustomPainter {
  _HorizontalWavePainter({
    required this.level,
    required this.phase,
    required this.background,
    required this.color,
  });

  final double level;
  final double phase;
  final Color background;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    if (level <= 0) return;

    void wave(double amplitude, double shift, Color c) {
      final front = size.width * level;
      final path = Path()..moveTo(0, 0);
      for (double y = 0; y <= size.height; y += 2) {
        final x = front +
            (level >= 1 ? 0 : amplitude * math.sin(y / size.height * 2 * math.pi + phase + shift));
        path.lineTo(x, y);
      }
      path
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(path, Paint()..color = c);
    }

    wave(6, math.pi, color.withValues(alpha: 0.45));
    wave(4, 0, color);
  }

  @override
  bool shouldRepaint(_HorizontalWavePainter old) =>
      old.level != level || old.phase != phase || old.color != color;
}

/// One tappable glass. When it becomes [full] the water rises from the
/// bottom with a wobbling surface and a "+250 ml" tag floats up; when it
/// is emptied the water drains back down.
class WaterGlass extends StatefulWidget {
  const WaterGlass({
    super.key,
    required this.full,
    required this.next,
    required this.onTap,
  });

  final bool full;
  final bool next;
  final VoidCallback onTap;

  @override
  State<WaterGlass> createState() => _WaterGlassState();
}

class _WaterGlassState extends State<WaterGlass> with TickerProviderStateMixin {
  late final AnimationController _fill = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
    value: widget.full ? 1 : 0,
  );
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didUpdateWidget(WaterGlass old) {
    super.didUpdateWidget(old);
    if (widget.full && !old.full) {
      _fill.animateTo(1, curve: Curves.easeOutCubic);
      _float.forward(from: 0);
    } else if (!widget.full && old.full) {
      _fill.animateTo(0, curve: Curves.easeInCubic);
    }
  }

  @override
  void dispose() {
    _fill.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.dengeColors;
    final outline = widget.full || widget.next ? colors.water : colors.divider;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: widget.onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _fill,
              builder: (context, _) {
                // The "pop" peaks mid-fill, then settles back to 1.
                final pop = 1 + 0.12 * math.sin(_fill.value * math.pi);
                return Transform.scale(
                  scale: pop,
                  child: CustomPaint(
                    size: const Size(28, 34),
                    painter: _GlassPainter(
                      fill: _fill.value,
                      outline: outline,
                      water: colors.water,
                      dashed: widget.next,
                    ),
                  ),
                );
              },
            ),
            if (widget.next)
              Icon(Icons.add_rounded, size: 16, color: colors.water),
            AnimatedBuilder(
              animation: _float,
              builder: (context, _) {
                final t = _float.value;
                if (t == 0 || t == 1) return const SizedBox.shrink();
                return Transform.translate(
                  offset: Offset(0, -22 * Curves.easeOut.transform(t)),
                  child: Opacity(
                    opacity: (1 - t).clamp(0.0, 1.0),
                    child: Text(
                      '+250 ml',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: colors.water,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// A tapered tumbler outline with water filled to [fill] (0–1). The
/// surface wobbles while filling and flattens once the glass is full.
class _GlassPainter extends CustomPainter {
  _GlassPainter({
    required this.fill,
    required this.outline,
    required this.water,
    required this.dashed,
  });

  final double fill;
  final Color outline;
  final Color water;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    const inset = 4.0;
    final glass = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width - inset, size.height)
      ..lineTo(inset, size.height)
      ..close();

    if (fill > 0) {
      canvas.save();
      canvas.clipPath(glass);
      final top = size.height * (1 - fill * 0.85);
      final wobble = 3 * math.sin(fill * math.pi) ;
      final path = Path()..moveTo(0, top);
      for (double x = 0; x <= size.width; x += 1) {
        path.lineTo(x, top + wobble * math.sin(x / size.width * 2 * math.pi + fill * 6));
      }
      path
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(path, Paint()..color = water);
      canvas.restore();
    }

    final stroke = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.round;
    if (!dashed) {
      canvas.drawPath(glass, stroke);
      return;
    }
    for (final metric in glass.computeMetrics()) {
      for (double d = 0; d < metric.length; d += 6) {
        canvas.drawPath(metric.extractPath(d, math.min(d + 3.5, metric.length)), stroke);
      }
    }
  }

  @override
  bool shouldRepaint(_GlassPainter old) =>
      old.fill != fill || old.outline != outline || old.dashed != dashed || old.water != water;
}
