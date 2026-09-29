import 'package:flutter/material.dart';

import '../../router.dart';
import '../../theme/app_colors.dart';

/// Port of project/Onboarding1.dc.html, Onboarding2.dc.html and
/// Onboarding3.dc.html as the 3 pages of a [PageView].
///
/// Simplifications vs the design: the floating illustration cards use
/// Material icons instead of the exact inline food SVGs, and the calorie
/// ring uses [CircularProgressIndicator] instead of a hand-drawn arc.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToSignUp() => Navigator.of(context).pushNamed(AppRoutes.signUp);

  void _goToLogin() => Navigator.of(context).pushNamed(AppRoutes.login);

  void _next() {
    if (_page < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _goToSignUp();
    }
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
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
              child: SizedBox(
                height: 48,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.eco_rounded, size: 28, color: scheme.primary),
                        const SizedBox(width: 8),
                        Text('Denge', style: textTheme.titleMedium),
                      ],
                    ),
                    if (_page < 2)
                      TextButton(
                        onPressed: _goToSignUp,
                        style: TextButton.styleFrom(
                          foregroundColor: textTheme.bodyMedium?.color,
                        ),
                        child: const Text('Atla'),
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _OnboardingPage(
                    illustration: _Page1Illustration(scheme: scheme),
                    pageIndex: 0,
                    heading: 'Öğünlerini saniyeler içinde kaydet',
                    body:
                        'Binlerce Türk mutfağı yemeği, barkod tarama ve favorilerinle ne yediğini zahmetsizce not al.',
                  ),
                  _OnboardingPage(
                    illustration: _Page2Illustration(scheme: scheme),
                    pageIndex: 1,
                    heading: 'Hedefini net bir şekilde takip et',
                    body:
                        'Kalori, protein, karbonhidrat ve yağ dengeni tek bakışta gör; kilo değişimini grafiklerle izle.',
                  ),
                  _OnboardingPage(
                    illustration: _Page3Illustration(scheme: scheme),
                    pageIndex: 2,
                    heading: 'Sağlıklı alışkanlıklar edin',
                    body:
                        'Su hatırlatıcıları, günlük seriler ve rozetlerle küçük adımları kalıcı alışkanlıklara dönüştür.',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _next,
                      child: Text(_page == 2 ? 'Başla' : 'İleri'),
                    ),
                  ),
                  if (_page == 2)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: SizedBox(
                        height: 48,
                        child: TextButton(
                          onPressed: _goToLogin,
                          child: RichText(
                            text: TextSpan(
                              style: textTheme.bodyMedium
                                  ?.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                              children: [
                                const TextSpan(text: 'Zaten hesabın var mı? '),
                                TextSpan(
                                  text: 'Giriş yap',
                                  style: TextStyle(
                                    color: _primaryTextColor(context),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _primaryTextColor(BuildContext context) =>
    Theme.of(context).colorScheme.brightness == Brightness.dark
        ? const Color(0xFF6FD49B)
        : const Color(0xFF1D7445);

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.illustration,
    required this.pageIndex,
    required this.heading,
    required this.body,
  });

  final Widget illustration;
  final int pageIndex;
  final String heading;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final divider = context.dengeColors.divider;
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Center(
              child: SizedBox(width: 342, height: 360, child: illustration),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(3, (i) {
                    final active = i == pageIndex;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Container(
                        width: active ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active ? scheme.primary : divider,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Text(
                  heading,
                  style: textTheme.headlineLarge?.copyWith(fontSize: 28, height: 1.2),
                ),
                const SizedBox(height: 8),
                Text(body, style: textTheme.bodyMedium?.copyWith(fontSize: 16, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Page1Illustration extends StatelessWidget {
  const _Page1Illustration({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 51,
          top: 20,
          child: Container(
            width: 240,
            height: 240,
            decoration: const BoxDecoration(
              color: Color(0xFFE4F3EA),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: 12,
          top: 40,
          child: Transform.rotate(
            angle: -0.05,
            child: _foodCard(
              iconBg: const Color(0xFFFDEEDC),
              icon: Icons.ramen_dining_rounded,
              iconColor: const Color(0xFFEF9446),
              title: 'Mercimek çorbası',
              subtitle: '1 kase',
              calories: '180',
            ),
          ),
        ),
        Positioned(
          left: 86,
          top: 128,
          child: Transform.rotate(
            angle: 0.035,
            child: _foodCard(
              iconBg: const Color(0xFFFDE5DF),
              icon: Icons.egg_alt_rounded,
              iconColor: const Color(0xFFE0512F),
              title: 'Menemen',
              subtitle: '1 porsiyon',
              calories: '280',
            ),
          ),
        ),
        Positioned(
          left: 30,
          top: 216,
          child: Transform.rotate(
            angle: -0.026,
            child: _foodCard(
              iconBg: const Color(0xFFE2F1FA),
              icon: Icons.local_drink_rounded,
              iconColor: const Color(0xFF6FA8C6),
              title: 'Ayran',
              subtitle: '1 bardak',
              calories: '76',
            ),
          ),
        ),
        Positioned(
          right: 8,
          top: 16,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check_rounded, size: 18, color: Colors.white),
                SizedBox(width: 8),
                Text('Eklendi',
                    style: TextStyle(
                        color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _foodCard({
    required Color iconBg,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String calories,
  }) {
    return Container(
      width: 244,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                Text(subtitle, style: const TextStyle(fontSize: 14, color: Color(0xFF55655B))),
              ],
            ),
          ),
          Text(calories,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _Page2Illustration extends StatelessWidget {
  const _Page2Illustration({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    const progress = 1240 / 1850;
    return Center(
      child: SizedBox(
        width: 342,
        height: 360,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 280,
              height: 280,
              decoration: const BoxDecoration(color: Color(0xFFE4F3EA), shape: BoxShape.circle),
            ),
            Container(
              width: 232,
              height: 232,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
                  BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 24, offset: const Offset(0, 8)),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: 1,
                      strokeWidth: 18,
                      strokeCap: StrokeCap.round,
                      valueColor: const AlwaysStoppedAnimation(Color(0xFFEEF3EE)),
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 18,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF35A866)),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('1.240',
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800)),
                      Text('/ 1.850 kcal',
                          style: TextStyle(fontSize: 14, color: Color(0xFF55655B))),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              bottom: 36,
              child: _chip(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(color: Color(0xFF6A5FE0), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    const Text('Protein 68 g',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 40,
              child: _chip(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.trending_down_rounded, size: 20, color: Color(0xFF1D7445)),
                    SizedBox(width: 8),
                    Text('−2,3 kg',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1D7445))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: child,
    );
  }
}

class _Page3Illustration extends StatelessWidget {
  const _Page3Illustration({required this.scheme});
  final ColorScheme scheme;

  static const _days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 342,
        height: 360,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 12,
              child: Container(
                width: 280,
                height: 280,
                decoration: const BoxDecoration(color: Color(0xFFFDEBE3), shape: BoxShape.circle),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
                      BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 24, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.local_fire_department_rounded, size: 44, color: Color(0xFFF2744E)),
                      SizedBox(height: 4),
                      Text('5 gün',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 320,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
                      BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 24, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_days.length, (i) {
                      final done = i < 5;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_days[i],
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF55655B))),
                          const SizedBox(height: 8),
                          Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: done ? scheme.primary : null,
                              shape: BoxShape.circle,
                              border: done
                                  ? null
                                  : Border.all(color: const Color(0xFFE1E9E3), width: 2),
                            ),
                            child: done
                                ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                                : null,
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
