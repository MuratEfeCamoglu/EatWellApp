import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'mock_data.dart';
import 'models.dart';

/// Outcome of resolving a scanned barcode to a product.
sealed class ProductLookupResult {
  const ProductLookupResult();
}

class ProductFound extends ProductLookupResult {
  const ProductFound(this.food, {this.imageUrl});

  /// Nutrition is per 100 g, so [FoodItem.servingLabel] is '100 g' and an
  /// amount of 1.5 means 150 g.
  final FoodItem food;
  final String? imageUrl;
}

class ProductNotFound extends ProductLookupResult {
  const ProductNotFound();
}

class ProductLookupFailed extends ProductLookupResult {
  const ProductLookupFailed(this.message);
  final String message;
}

const _fields = 'product_name,product_name_tr,generic_name_tr,brands,'
    'nutriments,image_front_small_url,image_front_url';

/// Resolves [barcode] against the bundled sample catalog first, then the
/// Open Food Facts public database (no API key; read-only lookups).
Future<ProductLookupResult> lookupBarcode(String barcode, {http.Client? client}) async {
  final local = MockData.barcodeCatalog[barcode];
  if (local != null) return ProductFound(local);

  final uri = Uri.https(
    'world.openfoodfacts.org',
    '/api/v2/product/$barcode.json',
    {'fields': _fields, 'lc': 'tr'},
  );
  final c = client ?? http.Client();
  try {
    final response = await c
        .get(uri, headers: {'User-Agent': 'Denge/1.0 (Android; Flutter)'})
        .timeout(const Duration(seconds: 12));
    // Open Food Facts answers 404 with {"status":0} for unknown barcodes.
    if (response.statusCode == 404) return const ProductNotFound();
    if (response.statusCode != 200) {
      return ProductLookupFailed('Ürün veritabanına ulaşılamadı (${response.statusCode}).');
    }
    final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return parseOpenFoodFactsResponse(json);
  } on TimeoutException {
    return const ProductLookupFailed('Bağlantı zaman aşımına uğradı. Tekrar dene.');
  } on SocketException {
    return const ProductLookupFailed('İnternet bağlantısı yok. Bağlanıp tekrar dene.');
  } on http.ClientException {
    return const ProductLookupFailed('İnternet bağlantısı yok. Bağlanıp tekrar dene.');
  } on FormatException {
    return const ProductLookupFailed('Ürün bilgisi okunamadı.');
  } finally {
    if (client == null) c.close();
  }
}

/// Turns an Open Food Facts `/api/v2/product` response into a result.
/// A product without a name or without energy data isn't usable for
/// calorie tracking, so it's reported as not found.
ProductLookupResult parseOpenFoodFactsResponse(Map<String, dynamic> json) {
  if (json['status'] != 1) return const ProductNotFound();
  final product = json['product'];
  if (product is! Map<String, dynamic>) return const ProductNotFound();

  String? text(String key) {
    final v = product[key];
    return v is String && v.trim().isNotEmpty ? v.trim() : null;
  }

  final name = text('product_name_tr') ?? text('product_name') ?? text('generic_name_tr');
  if (name == null) return const ProductNotFound();

  final nutriments = product['nutriments'];
  final n = nutriments is Map<String, dynamic> ? nutriments : const <String, dynamic>{};
  double? num100(String key) {
    final v = n['${key}_100g'];
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.replaceAll(',', '.'));
    return null;
  }

  // Prefer the kcal field; fall back to kJ energy converted to kcal.
  final kcal = num100('energy-kcal') ??
      (num100('energy') != null ? num100('energy')! / 4.184 : null);
  if (kcal == null) return const ProductNotFound();

  final brand = text('brands')?.split(',').first.trim();
  return ProductFound(
    FoodItem(
      name: name,
      brand: brand ?? 'Paketli ürün',
      caloriesPer100g: kcal.round(),
      proteinG: _round1(num100('proteins') ?? 0),
      carbsG: _round1(num100('carbohydrates') ?? 0),
      fatG: _round1(num100('fat') ?? 0),
      servingLabel: '100 g',
    ),
    imageUrl: text('image_front_small_url') ?? text('image_front_url'),
  );
}

double _round1(double v) => (v * 10).round() / 10;
