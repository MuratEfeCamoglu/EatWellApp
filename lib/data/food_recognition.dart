import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';

import 'mock_data.dart';
import 'models.dart';

/// Result of a photo-recognition attempt: either it failed outright (no
/// photo taken, camera denied, ML Kit error) or it produced zero-or-more
/// best-guess catalog matches for the user to confirm.
class FoodPhotoResult {
  const FoodPhotoResult({this.error, this.candidates = const [], this.cancelled = false});

  /// Null on success (even with zero candidates); set to a user-facing
  /// message when the photo couldn't be taken or processed at all.
  final String? error;
  final List<FoodItem> candidates;

  /// True when the user backed out of the camera without taking a photo —
  /// not an error, just nothing to do.
  final bool cancelled;
}

/// English ML Kit base-model labels (Google's generic image labeler isn't
/// food-specific) mapped to keywords matched against our catalog's Turkish
/// food names/brands. This is necessarily a best-effort heuristic, not a
/// dedicated food-recognition model — the UI must let the user confirm or
/// reject the guess rather than silently trusting it.
const _labelToKeywords = <String, List<String>>{
  'egg': ['yumurta', 'menemen'],
  'bread': ['ekmek', 'simit'],
  'baked goods': ['simit', 'ekmek'],
  'bakery': ['simit', 'ekmek'],
  'cheese': ['peynir'],
  'dairy': ['peynir', 'yoğurt', 'süt'],
  'yogurt': ['yoğurt'],
  'milk': ['süt'],
  'rice': ['pilav'],
  'soup': ['çorba'],
  'salad': ['salata'],
  'vegetable': ['domates', 'salatalık', 'salata'],
  'tomato': ['domates'],
  'cucumber': ['salatalık'],
  'pizza': ['lahmacun'],
  'flatbread': ['lahmacun'],
  'meat': ['köfte', 'sucuk', 'tavuk', 'kavurma'],
  'beef': ['köfte', 'sucuk'],
  'sausage': ['sucuk'],
  'hot dog': ['sucuk'],
  'chicken': ['tavuk'],
  'poultry': ['tavuk'],
  'fish': ['somon'],
  'seafood': ['somon'],
  'salmon': ['somon'],
  'fruit': ['kayısı'],
  'apricot': ['kayısı'],
  'honey': ['bal'],
  'jam': ['reçel'],
  'butter': ['tereyağı'],
  'noodle': ['mantı'],
  'dumpling': ['mantı'],
  'pasta': ['mantı'],
  'bean': ['fasulye'],
  'legume': ['fasulye'],
  'olive': ['zeytin'],
  'coffee': ['kahve'],
  'tea': ['çay'],
  'oatmeal': ['yulaf'],
  'porridge': ['yulaf'],
  'grilled food': ['ızgara', 'köfte', 'sucuk', 'tavuk'],
  'barbecue': ['ızgara', 'köfte'],
};

/// Scores every catalog item suitable for [meal] against the detected
/// [labels] and returns the best matches, highest confidence first.
List<FoodItem> matchFoodLabels(List<ImageLabel> labels, {required MealType meal}) {
  final catalog = MockData.searchResults.where((f) => f.meals.contains(meal));
  final scores = <FoodItem, double>{};

  for (final label in labels) {
    final text = label.label.toLowerCase();
    for (final entry in _labelToKeywords.entries) {
      if (!text.contains(entry.key)) continue;
      for (final keyword in entry.value) {
        for (final food in catalog) {
          if (food.name.toLowerCase().contains(keyword)) {
            final current = scores[food] ?? 0;
            if (label.confidence > current) scores[food] = label.confidence;
          }
        }
      }
    }
  }

  final ranked = scores.keys.toList()
    ..sort((a, b) => scores[b]!.compareTo(scores[a]!));
  return ranked.take(3).toList();
}

/// Takes a photo with the device camera and runs it through ML Kit's
/// on-device image labeler, then matches the labels against the food
/// catalog for [meal]. Returns null candidates with an [FoodPhotoResult]
/// error message if the camera or labeler failed; returns an empty
/// candidate list (no error) if recognition ran but found nothing usable.
Future<FoodPhotoResult> recognizeFoodPhoto({required MealType meal}) async {
  final XFile? photo;
  try {
    photo = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 85);
  } catch (_) {
    return const FoodPhotoResult(
        error: 'Kameraya erişilemedi. Kamera iznini kontrol edin.');
  }
  if (photo == null) return const FoodPhotoResult(cancelled: true);

  final labeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.6));
  try {
    final labels = await labeler.processImage(InputImage.fromFilePath(photo.path));
    return FoodPhotoResult(candidates: matchFoodLabels(labels, meal: meal));
  } catch (_) {
    return const FoodPhotoResult(error: 'Fotoğraf işlenemedi. Tekrar deneyin.');
  } finally {
    await labeler.close();
  }
}
