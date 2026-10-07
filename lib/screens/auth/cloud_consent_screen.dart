import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_state.dart';
import '../../widgets/form_parts.dart';
import '../../widgets/section_card.dart';

const _months = [
  'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
  'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
];

/// Explicit consent for storing data in the cloud (CLAUDE.md §13.5). Shown
/// after sign-in / sign-up while it hasn't been given, and from Settings to
/// review or withdraw it. Separate from the health-data consent: saying no
/// keeps the app fully working, local-only. Pops `true` when consent was
/// given, `false` otherwise.
class CloudConsentScreen extends StatefulWidget {
  const CloudConsentScreen({super.key});

  @override
  State<CloudConsentScreen> createState() => _CloudConsentScreenState();
}

class _CloudConsentScreenState extends State<CloudConsentScreen> {
  bool _ticked = false;
  bool _busy = false;

  Future<void> _accept() async {
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    await context.read<AppState>().giveCloudConsent();
    if (mounted) navigator.pop(true);
  }

  Future<void> _revoke() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await context.read<AppState>().revokeCloudConsent();
    messenger.showSnackBar(const SnackBar(
        content: Text('Bulut yedekleme kapatıldı. Yeni değişiklikler '
            'yalnızca bu telefonda kalacak.')));
    navigator.pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final consentAt = state.cloudConsentAt;
    final given = state.hasCloudConsent;

    Widget point(IconData icon, String title, String body) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(body, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        );

    return PopScope(
      // Backing out counts as "not now".
      canPop: true,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const FormScreenHeader('Bulut yedekleme'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (given && consentAt != null) ...[
                        SectionCard(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Bulut yedekleme açık · ${consentAt.day} '
                            '${_months[consentAt.month - 1]} ${consentAt.year} '
                            'tarihinde onay verdin.',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ] else ...[
                        Text('Verilerini buluta yedekleyelim mi?',
                            style: theme.textTheme.headlineSmall),
                        const SizedBox(height: 8),
                        Text(
                          'Yedekleme isteğe bağlıdır. Onay vermesen de Denge '
                          'aynen çalışır; verilerin yalnızca bu telefonda kalır.',
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),
                      ],
                      point(
                        Icons.inventory_2_outlined,
                        'Ne yedeklenir?',
                        'Profilin, hedeflerin ve alerjilerin; sonraki '
                            'güncellemelerle günlük, su ve kilo kayıtların ile '
                            'kendi eklediğin yiyecekler. Bunların bir kısmı '
                            'sağlık verisi sayılır.',
                      ),
                      point(
                        Icons.public_rounded,
                        'Nerede saklanır?',
                        'Supabase altyapısında, Avrupa Birliği\'nde (Almanya, '
                            'Frankfurt) bulunan sunucularda. Bu, verilerinin '
                            'yurt dışına aktarılması anlamına gelir.',
                      ),
                      point(
                        Icons.devices_rounded,
                        'Neden?',
                        'Başka bir telefonda aynı hesapla girdiğinde verilerin '
                            'gelsin; telefonun kaybolursa verilerin kaybolmasın.',
                      ),
                      point(
                        Icons.lock_outline_rounded,
                        'Kim görebilir?',
                        'Yalnızca sen. Veriler hesabına kilitlidir; başka '
                            'kullanıcılar erişemez.',
                      ),
                      point(
                        Icons.delete_outline_rounded,
                        'Nasıl geri alırım?',
                        'Onayını istediğin an buradan geri alabilirsin. '
                            'Hesabını sildiğinde buluttaki verilerin de '
                            'tamamen silinir.',
                      ),
                      if (!given)
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          value: _ticked,
                          onChanged: (v) => setState(() => _ticked = v ?? false),
                          title: Text(
                            'Sağlık verilerim dahil yukarıdaki verilerin '
                            'yurt dışında (AB) saklanmasına açık rıza veriyorum.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: given
                    ? OutlinedButton(
                        onPressed: _revoke,
                        style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(56)),
                        child: const Text('Yedeklemeyi kapat'),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton(
                            onPressed: _ticked && !_busy ? _accept : null,
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(56)),
                            child: const Text('Kabul et ve yedekle'),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _busy
                                ? null
                                : () => Navigator.of(context).pop(false),
                            child: const Text('Şimdilik hayır'),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
