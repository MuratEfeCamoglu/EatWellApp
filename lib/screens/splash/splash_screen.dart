import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../router.dart';

/// Port of project/Main.dc.html — full-bleed green splash with the Denge
/// leaf mark. Advances to onboarding after a short delay or on tap.
///
/// Simplification: the two-tone leaf mark from the design is recreated with
/// a single [Icons.eco_rounded] glyph rather than a pixel-exact SVG redraw.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  bool _navigated = false;

  static const _green = Color(0xFF1F7A48);

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1200), _goNext);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goNext() {
    if (_navigated || !mounted) return;
    _navigated = true;
    final next =
        AppState.instance.setupComplete ? AppRoutes.main : AppRoutes.onboarding;
    Navigator.of(context).pushReplacementNamed(next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _green,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _goNext,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: 340 - 160,
              top: 120 - 160,
              child: _decorCircle(320, Colors.white.withValues(alpha: 0.06)),
            ),
            Positioned(
              left: 40 - 200,
              top: 760 - 200,
              child: _decorCircle(400, Colors.white.withValues(alpha: 0.05)),
            ),
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF062814).withValues(alpha: 0.25),
                            blurRadius: 40,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.eco_rounded, size: 64, color: _green),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Denge',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dengeli beslen, iyi hisset.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 72,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dot(1),
                  const SizedBox(width: 8),
                  _dot(0.55),
                  const SizedBox(width: 8),
                  _dot(0.3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _decorCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _dot(double opacity) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
