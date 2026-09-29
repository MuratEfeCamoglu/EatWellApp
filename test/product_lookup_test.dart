import 'dart:convert';

import 'package:denge/data/product_lookup.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response _json(Object body, [int status = 200]) => http.Response.bytes(
      utf8.encode(jsonEncode(body)),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

void main() {
  group('parseOpenFoodFactsResponse', () {
    test('maps name, brand, image and per-100 g nutriments', () {
      final result = parseOpenFoodFactsResponse({
        'status': 1,
        'product': {
          'product_name': 'Chocolate Wafer',
          'product_name_tr': 'Çikolatalı Gofret',
          'brands': 'Ülker, Yıldız',
          'image_front_small_url': 'https://img/x.jpg',
          'nutriments': {
            'energy-kcal_100g': 531.4,
            'proteins_100g': 6.25,
            'carbohydrates_100g': 61,
            'fat_100g': '28,4',
          },
        },
      });

      expect(result, isA<ProductFound>());
      final found = result as ProductFound;
      expect(found.food.name, 'Çikolatalı Gofret');
      expect(found.food.brand, 'Ülker');
      expect(found.food.caloriesPer100g, 531);
      expect(found.food.proteinG, 6.3);
      expect(found.food.carbsG, 61);
      expect(found.food.fatG, 28.4);
      expect(found.food.servingLabel, '100 g');
      expect(found.imageUrl, 'https://img/x.jpg');
    });

    test('converts kJ energy when kcal is missing', () {
      final result = parseOpenFoodFactsResponse({
        'status': 1,
        'product': {
          'product_name': 'Ayran',
          'nutriments': {'energy_100g': 159},
        },
      }) as ProductFound;
      expect(result.food.caloriesPer100g, 38);
      expect(result.food.brand, 'Paketli ürün');
    });

    test('unknown barcode is not found', () {
      expect(parseOpenFoodFactsResponse({'status': 0}), isA<ProductNotFound>());
    });

    test('product without name or energy is not found', () {
      expect(
        parseOpenFoodFactsResponse({
          'status': 1,
          'product': {'nutriments': {'energy-kcal_100g': 100}},
        }),
        isA<ProductNotFound>(),
      );
      expect(
        parseOpenFoodFactsResponse({
          'status': 1,
          'product': {'product_name': 'Su', 'nutriments': {}},
        }),
        isA<ProductNotFound>(),
      );
    });
  });

  group('lookupBarcode', () {
    test('uses the bundled catalog without a network call', () async {
      final client = MockClient((_) async => fail('should not hit the network'));
      final result = await lookupBarcode('8690504041218', client: client);
      expect(result, isA<ProductFound>());
    });

    test('queries Open Food Facts for the scanned code', () async {
      late Uri requested;
      final client = MockClient((request) async {
        requested = request.url;
        return _json({
          'status': 1,
          'product': {
            'product_name': 'Süzme Peynir',
            'nutriments': {'energy-kcal_100g': 250},
          },
        });
      });

      final result = await lookupBarcode('8690000000001', client: client);

      expect(requested.host, 'world.openfoodfacts.org');
      expect(requested.path, '/api/v2/product/8690000000001.json');
      expect((result as ProductFound).food.name, 'Süzme Peynir');
    });

    test('404 means not found', () async {
      final client = MockClient((_) async => _json({'status': 0}, 404));
      expect(await lookupBarcode('123', client: client), isA<ProductNotFound>());
    });

    test('server error is reported as a failure', () async {
      final client = MockClient((_) async => http.Response('oops', 503));
      expect(await lookupBarcode('123', client: client), isA<ProductLookupFailed>());
    });

    test('network error is reported as a failure', () async {
      final client = MockClient((_) async => throw http.ClientException('offline'));
      final result = await lookupBarcode('123', client: client);
      expect(result, isA<ProductLookupFailed>());
      expect((result as ProductLookupFailed).message, contains('İnternet'));
    });
  });
}
