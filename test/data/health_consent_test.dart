import 'package:denge/data/health_consent.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AllergyProfile', () {
    test('round-trips allergens and note through encode/decode', () {
      final profile = AllergyProfile(
        allergens: {Allergen.sesame, Allergen.gluten},
        otherNote: '  çilek ',
      );
      final decoded = AllergyProfile.decode(
        profile.encodeAllergens(),
        profile.otherNote,
      );
      expect(decoded.allergens, {Allergen.gluten, Allergen.sesame});
      expect(decoded.otherNote, 'çilek');
      expect(decoded.hasAllergies, isTrue);
    });

    test('encodes in enum order regardless of selection order', () {
      final profile = AllergyProfile(allergens: {Allergen.fish, Allergen.milk});
      expect(profile.encodeAllergens(), ['milk', 'fish']);
    });

    test('empty profile has no allergies', () {
      expect(AllergyProfile.none.hasAllergies, isFalse);
      expect(AllergyProfile(otherNote: '   ').hasAllergies, isFalse);
      expect(AllergyProfile(otherNote: 'kivi').hasAllergies, isTrue);
    });

    test('decode skips unknown allergen names', () {
      final decoded = AllergyProfile.decode(['egg', 'lupin'], '');
      expect(decoded.allergens, {Allergen.egg});
    });

    test('every allergen has a non-empty Turkish label', () {
      for (final a in Allergen.values) {
        expect(a.label, isNotEmpty);
      }
    });
  });

  group('ConsentRecord.tryParse', () {
    test('parses a stored version and timestamp', () {
      final record = ConsentRecord.tryParse('v1', '2026-10-07T09:30:00.000');
      expect(record, isNotNull);
      expect(record!.version, 'v1');
      expect(record.acceptedAt, DateTime(2026, 10, 7, 9, 30));
    });

    test('returns null when anything is missing or invalid', () {
      expect(ConsentRecord.tryParse(null, '2026-10-07T09:30:00.000'), isNull);
      expect(ConsentRecord.tryParse('', '2026-10-07T09:30:00.000'), isNull);
      expect(ConsentRecord.tryParse('v1', null), isNull);
      expect(ConsentRecord.tryParse('v1', 'not a date'), isNull);
    });
  });
}
