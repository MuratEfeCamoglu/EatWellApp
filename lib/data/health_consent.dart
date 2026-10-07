/// Allergy answers and KVKK explicit-consent record collected right after
/// sign-up (ISKELET F20, F21). Pure Dart so the (de)serialisation used for
/// persistence can be unit tested without Flutter.
library;

/// Version of the consent wording the user agreed to. Bump it whenever the
/// consent text or privacy notice changes, so we can tell which text a stored
/// consent refers to (F20: "onay tarihi ve metin sürümü").
const String kConsentVersion = '2026-10-placeholder';

/// Exact wording of the explicit-consent checkbox, as specified in ISKELET
/// F20. Legal wording — do not edit without the user's approval.
const String kConsentCheckboxText =
    'Sağlık verilerimin (kilo, beslenme) işlenmesine ve yurt dışındaki '
    'sunucularda saklanmasına açık rıza veriyorum';

/// Placeholder shown where the privacy notice (aydınlatma metni) will go.
/// The legal text itself is supplied by the user / a lawyer (ISKELET F20).
const String kPrivacyNoticePlaceholder =
    'Aydınlatma metni henüz eklenmedi.\n\n'
    '[YER TUTUCU] Bu alana KVKK kapsamındaki aydınlatma metni gelecek: '
    'veri sorumlusu, işlenen veriler, işleme amaçları, aktarım ve '
    'saklama süresi, ilgili kişinin hakları.';

/// The most common food allergens (based on the EU's 14 regulated
/// allergens, trimmed to those relevant to the Turkish catalogue).
enum Allergen {
  gluten,
  milk,
  egg,
  peanut,
  treeNut,
  soy,
  fish,
  shellfish,
  sesame;

  String get label => switch (this) {
    Allergen.gluten => 'Gluten',
    Allergen.milk => 'Süt / laktoz',
    Allergen.egg => 'Yumurta',
    Allergen.peanut => 'Yer fıstığı',
    Allergen.treeNut => 'Sert kabuklu yemiş',
    Allergen.soy => 'Soya',
    Allergen.fish => 'Balık',
    Allergen.shellfish => 'Kabuklu deniz ürünü',
    Allergen.sesame => 'Susam',
  };
}

/// What the user told us about their allergies. An empty profile means
/// "no known allergy".
class AllergyProfile {
  AllergyProfile({Set<Allergen> allergens = const {}, String otherNote = ''})
    : allergens = Set.unmodifiable(allergens),
      otherNote = otherNote.trim();

  static final AllergyProfile none = AllergyProfile();

  final Set<Allergen> allergens;

  /// Free-text allergies not covered by [Allergen] (e.g. "çilek").
  final String otherNote;

  bool get hasAllergies => allergens.isNotEmpty || otherNote.isNotEmpty;

  /// Serialises [allergens] by enum name; storing names (not indices) keeps
  /// stored data valid if the enum is reordered.
  List<String> encodeAllergens() =>
      Allergen.values.where(allergens.contains).map((a) => a.name).toList();

  /// Inverse of [encodeAllergens]. Unknown names (e.g. written by a newer
  /// app version) are skipped instead of throwing.
  static AllergyProfile decode(List<String> names, String otherNote) {
    final byName = {for (final a in Allergen.values) a.name: a};
    return AllergyProfile(
      allergens: {
        for (final n in names)
          if (byName[n] != null) byName[n]!,
      },
      otherNote: otherNote,
    );
  }
}

/// A recorded explicit consent: which text version and when.
class ConsentRecord {
  const ConsentRecord({required this.version, required this.acceptedAt});

  final String version;
  final DateTime acceptedAt;

  /// Returns null when either part is missing or unparsable — treated as
  /// "consent not given" so the consent page is shown again.
  static ConsentRecord? tryParse(String? version, String? acceptedAtIso) {
    if (version == null || version.isEmpty || acceptedAtIso == null) {
      return null;
    }
    final at = DateTime.tryParse(acceptedAtIso);
    return at == null ? null : ConsentRecord(version: version, acceptedAt: at);
  }
}
