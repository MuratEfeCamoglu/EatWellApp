import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../data/models.dart';
import '../../data/product_lookup.dart';
import '../../router.dart';
import '../../widgets/app_back_button.dart';
import '../search/search_screen.dart' show defaultMealForNow;

/// Real camera + barcode scanning (via `mobile_scanner`). Detected codes are
/// resolved by [lookupBarcode]: the bundled sample catalog first, then the
/// Open Food Facts product database over the network.
class BarcodeScreen extends StatefulWidget {
  const BarcodeScreen({super.key, this.initialMeal});

  final MealType? initialMeal;

  @override
  State<BarcodeScreen> createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends State<BarcodeScreen> {
  late final MealType _meal = widget.initialMeal ?? defaultMealForNow();
  final MobileScannerController _controller = MobileScannerController(
    torchEnabled: false,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  StreamSubscription<BarcodeCapture>? _subscription;

  String? _scannedCode;

  /// Null while the lookup for [_scannedCode] is still in flight.
  ProductLookupResult? _result;
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _subscription = _controller.barcodes.listen(_onDetect);
    unawaited(_controller.start());
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    _subscription = null;
    unawaited(_controller.dispose());
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_locked) return;
    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue;
      if (code == null || code.isEmpty) continue;
      setState(() {
        _scannedCode = code;
        _locked = true;
      });
      unawaited(_controller.stop());
      unawaited(_lookup(code));
      return;
    }
  }

  Future<void> _lookup(String code) async {
    setState(() => _result = null);
    final result = await lookupBarcode(code);
    // Ignore a stale answer if the user already rescanned or left.
    if (!mounted || _scannedCode != code) return;
    setState(() => _result = result);
  }

  void _rescan() {
    setState(() {
      _scannedCode = null;
      _result = null;
      _locked = false;
    });
    unawaited(_controller.start());
  }

  /// Opens the regular food detail so the user picks how many grams they
  /// had (the product's values are per 100 g) and the meal to add it to.
  void _chooseAmount(FoodItem product) {
    Navigator.of(context)
        .pushReplacement(AppRoutes.pushFoodDetail(product, initialMeal: _meal));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: _controller,
              errorBuilder: (context, error) =>
                  _ScannerErrorView(error: error, meal: _meal),
            ),

            // Dimmed regions above/below/around the scan frame.
            IgnorePointer(
              child: Column(
                children: [
                  const Expanded(flex: 5, child: ColoredBox(color: Color(0xB30A100C))),
                  SizedBox(
                    height: 240,
                    child: Row(
                      children: [
                        const SizedBox(width: 24, child: ColoredBox(color: Color(0xB30A100C))),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: CustomPaint(painter: _ScanFramePainter()),
                          ),
                        ),
                        const SizedBox(width: 24, child: ColoredBox(color: Color(0xB30A100C))),
                      ],
                    ),
                  ),
                  const Expanded(flex: 4, child: ColoredBox(color: Color(0xB30A100C))),
                ],
              ),
            ),

            // Top bar.
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Row(
                children: [
                  AppBackButton(
                    icon: Icons.close_rounded,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Barkod tara',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  ValueListenableBuilder<MobileScannerState>(
                    valueListenable: _controller,
                    builder: (context, state, _) {
                      final torchOn = state.torchState == TorchState.on;
                      return _RoundIconButton(
                        icon: torchOn ? Icons.flash_off_rounded : Icons.flash_on_rounded,
                        label: torchOn ? 'Flaşı kapat' : 'Flaşı aç',
                        onTap: () => unawaited(_controller.toggleTorch()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Instruction caption.
            if (!_locked)
              const Positioned(
                left: 24,
                right: 24,
                top: 300,
                child: Text(
                  'Barkodu çerçevenin içine hizala',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

            // Bottom "found"/"not found" sheet, once a code was scanned.
            if (_locked)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: switch (_result) {
                    null => _LookingUpSheet(code: _scannedCode!),
                    ProductFound(:final food, :final imageUrl) => _ProductFoundSheet(
                        product: food,
                        imageUrl: imageUrl,
                        onChooseAmount: () => _chooseAmount(food),
                        onRescan: _rescan,
                      ),
                    ProductNotFound() =>
                      _ProductNotFoundSheet(code: _scannedCode!, onRescan: _rescan),
                    ProductLookupFailed(:final message) => _LookupFailedSheet(
                        message: message,
                        onRetry: () => _lookup(_scannedCode!),
                        onRescan: _rescan,
                      ),
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: Colors.white, size: 22, semanticLabel: label),
        ),
      ),
    );
  }
}

/// Shown by [MobileScanner]'s `errorBuilder` when the camera can't start —
/// most commonly because the camera permission was denied.
class _ScannerErrorView extends StatelessWidget {
  const _ScannerErrorView({required this.error, required this.meal});

  final MobileScannerException error;
  final MealType meal;

  @override
  Widget build(BuildContext context) {
    final isPermission = error.errorCode == MobileScannerErrorCode.permissionDenied;
    return ColoredBox(
      color: const Color(0xFF2B2F2C),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPermission ? Icons.no_photography_rounded : Icons.error_outline_rounded,
                color: Colors.white,
                size: 56,
              ),
              const SizedBox(height: 16),
              Text(
                isPermission
                    ? 'Barkod taramak için kamera izni gerekiyor'
                    : 'Kamera başlatılamadı',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                isPermission
                    ? 'Ayarlar > Uygulamalar > Denge > İzinler bölümünden kamera iznini açtıktan sonra tekrar dene.'
                    : error.errorCode.message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 14),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context)
                    .pushReplacement(AppRoutes.pushSearch(initialMeal: meal)),
                icon: const Icon(Icons.keyboard_rounded),
                label: const Text('Elle ara'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws the four rounded corner brackets of the scan frame plus a thin
/// center "laser" line, matching the design's overlay SVG.
class _ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bracket = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    const len = 28.0;
    const r = 16.0;

    void corner(Offset origin, double dx, double dy) {
      final path = Path()
        ..moveTo(origin.dx, origin.dy + dy * len)
        ..lineTo(origin.dx, origin.dy + dy * r)
        ..arcToPoint(Offset(origin.dx + dx * r, origin.dy), radius: const Radius.circular(r))
        ..lineTo(origin.dx + dx * len, origin.dy);
      canvas.drawPath(path, bracket);
    }

    corner(const Offset(0, 0), 1, 1);
    corner(Offset(size.width, 0), -1, 1);
    corner(Offset(size.width, size.height), -1, -1);
    corner(Offset(0, size.height), 1, -1);

    final line = Paint()..color = const Color(0xFF4CC27F);
    final center = size.height / 2;
    canvas.drawRect(
      Rect.fromLTWH(20, center - 7, size.width - 40, 15),
      line..color = const Color(0x404CC27F),
    );
    canvas.drawRect(
      Rect.fromLTWH(20, center - 1.5, size.width - 40, 3),
      Paint()..color = const Color(0xFF4CC27F),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// White rounded card that all bottom result sheets share.
class _SheetCard extends StatelessWidget {
  const _SheetCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0x4D000000), blurRadius: 40, offset: Offset(0, 16)),
        ],
      ),
      child: child,
    );
  }
}

/// Icon tile + title/subtitle header used by the non-product sheets.
class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.leading,
    required this.leadingBg,
    required this.title,
    required this.subtitle,
  });

  final Widget leading;
  final Color leadingBg;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: leadingBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: leading,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF14201A))),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF55655B))),
            ],
          ),
        ),
      ],
    );
  }
}

class _LookingUpSheet extends StatelessWidget {
  const _LookingUpSheet({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return _SheetCard(
      child: _SheetHeader(
        leading: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF1D7445)),
        ),
        leadingBg: const Color(0xFFE4F3EA),
        title: 'Ürün aranıyor…',
        subtitle: 'Barkod: $code',
      ),
    );
  }
}

class _ProductFoundSheet extends StatelessWidget {
  const _ProductFoundSheet({
    required this.product,
    required this.imageUrl,
    required this.onChooseAmount,
    required this.onRescan,
  });

  final FoodItem product;
  final String? imageUrl;
  final VoidCallback onChooseAmount;
  final VoidCallback onRescan;

  @override
  Widget build(BuildContext context) {
    const placeholder = ColoredBox(
      color: Color(0xFFE2F1FA),
      child: Center(child: Icon(Icons.inventory_2_rounded, color: Color(0xFF2B97D6))),
    );
    const muted = TextStyle(fontSize: 13, color: Color(0xFF55655B));
    return _SheetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: imageUrl == null
                      ? placeholder
                      : Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => placeholder,
                          loadingBuilder: (context, child, progress) =>
                              progress == null ? child : placeholder,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF1D7445)),
                        SizedBox(width: 4),
                        Text('Ürün bulundu',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1D7445),
                            )),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF14201A)),
                    ),
                    Text(product.brand, style: muted),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F6F4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _Nutrient(value: '${product.caloriesPer100g}', label: 'kcal'),
                _Nutrient(value: _g(product.proteinG), label: 'protein'),
                _Nutrient(value: _g(product.carbsG), label: 'karb.'),
                _Nutrient(value: _g(product.fatG), label: 'yağ'),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Text('Değerler 100 g içindir', style: muted, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRescan,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFE4F3EA),
                    foregroundColor: const Color(0xFF1D7445),
                    side: BorderSide.none,
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: const Text('Tekrar tara'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: onChooseAmount,
                  icon: const Icon(Icons.scale_rounded),
                  label: const Text('Miktar seç'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _g(double v) =>
      '${v == v.roundToDouble() ? v.round() : v.toStringAsFixed(1).replaceAll('.', ',')} g';
}

class _Nutrient extends StatelessWidget {
  const _Nutrient({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF14201A))),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF55655B))),
        ],
      ),
    );
  }
}

class _ProductNotFoundSheet extends StatelessWidget {
  const _ProductNotFoundSheet({required this.code, required this.onRescan});

  final String code;
  final VoidCallback onRescan;

  @override
  Widget build(BuildContext context) {
    return _SheetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHeader(
            leading: const Icon(Icons.search_off_rounded, color: Color(0xFFB5651D)),
            leadingBg: const Color(0xFFFDEBE3),
            title: 'Ürün bulunamadı',
            subtitle: 'Barkod: $code\nBu ürün veritabanında kayıtlı değil.',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRescan,
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                  child: const Text('Tekrar tara'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                  child: const Text('Elle ara'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LookupFailedSheet extends StatelessWidget {
  const _LookupFailedSheet({
    required this.message,
    required this.onRetry,
    required this.onRescan,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onRescan;

  @override
  Widget build(BuildContext context) {
    return _SheetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetHeader(
            leading: const Icon(Icons.wifi_off_rounded, color: Color(0xFFB5651D)),
            leadingBg: const Color(0xFFFDEBE3),
            title: 'Ürün bilgisi alınamadı',
            subtitle: message,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRescan,
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                  child: const Text('Tekrar tara'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                  label: const Text('Tekrar dene'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
