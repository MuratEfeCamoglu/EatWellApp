import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/app_state.dart';
import '../../router.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/section_card.dart';

/// Denge's Settings screen (project/Settings.dc.html / Settings-dark.dc.html):
/// grouped reminder/appearance/account rows (reminders open the shared
/// [NotificationsScreen]), "Tüm verilerimi
/// sil" (KVKK: erase everything stored on the device) and a log-out button.
/// Reached from the Profile tab's gear icon / "Ayarlar" row.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış yapılsın mı?'),
        content: const Text(
          'Hesabından çıkış yapılacak. Bu telefondaki kayıtların silinmez.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Çıkış yap'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    await context.read<AppState>().signOut();
    messenger.showSnackBar(const SnackBar(content: Text('Çıkış yapıldı')));
  }

  Future<void> _confirmDeleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tüm verilerin silinsin mi?'),
        content: const Text(
          'Günlük kayıtların, su ve kilo geçmişin, kendi eklediğin '
          'yiyecekler, profilin ve ayarların bu cihazdan kalıcı olarak '
          'silinecek. Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await context.read<AppState>().deleteAllData();
    } catch (_) {
      messenger.showSnackBar(const SnackBar(
          content: Text('Veriler silinemedi, lütfen tekrar dene.')));
      return;
    }
    navigator.pushNamedAndRemoveUntil(AppRoutes.onboarding, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Row(
                  children: [
                    const AppBackButton(),
                    Expanded(
                      child: Text(
                        'Ayarlar',
                        textAlign: TextAlign.center,
                        style: textTheme.titleSmall?.copyWith(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader('BİLDİRİMLER'),
                    const SizedBox(height: 8),
                    SectionCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Consumer<AppState>(
                        builder: (context, state, _) => _NavRow(
                          icon: Icons.notifications_none_rounded,
                          title: 'Hatırlatıcılar',
                          trailingText: state.notificationSettings.anyEnabled
                              ? 'Açık'
                              : 'Kapalı',
                          onTap: () => Navigator.of(context)
                              .push(AppRoutes.pushNotifications()),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _SectionHeader('GÖRÜNÜM'),
                    const SizedBox(height: 8),
                    SectionCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Consumer<AppState>(
                        builder: (context, state, _) => Column(
                          children: [
                            _SwitchRow(
                              icon: Icons.dark_mode_rounded,
                              title: 'Karanlık mod',
                              subtitle: 'Göz yormayan koyu tema',
                              value: state.themeMode == ThemeMode.dark,
                              onChanged: (v) => context.read<AppState>().setThemeMode(
                                  v ? ThemeMode.dark : ThemeMode.light),
                            ),
                            _NavRow(
                              icon: Icons.language_rounded,
                              title: 'Dil ve erişilebilirlik',
                              trailingText: 'Türkçe',
                              showTopDivider: true,
                              onTap: () => Navigator.of(context)
                                  .push(AppRoutes.pushLanguageAccessibility()),
                            ),
                            _NavRow(
                              icon: Icons.straighten_rounded,
                              title: 'Birimler',
                              trailingText: 'kg, cm',
                              showTopDivider: true,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _SectionHeader('HESAP'),
                    const SizedBox(height: 8),
                    SectionCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          _NavRow(
                            icon: Icons.lock_outline_rounded,
                            title: 'Şifreyi değiştir',
                            onTap: () {},
                          ),
                          _NavRow(
                            icon: Icons.shield_outlined,
                            title: 'Gizlilik ve veriler',
                            showTopDivider: true,
                            onTap: () {},
                          ),
                          _NavRow(
                            icon: Icons.delete_forever_rounded,
                            title: 'Tüm verilerimi sil',
                            showTopDivider: true,
                            onTap: _confirmDeleteAll,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Consumer<AppState>(
                      builder: (context, state, _) {
                        final account = state.account;
                        if (account != null) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SectionCard(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: _NavRow(
                                  icon: Icons.cloud_outlined,
                                  title: 'Bulut yedekleme',
                                  trailingText:
                                      state.hasCloudConsent ? 'Açık' : 'Kapalı',
                                  onTap: () => Navigator.of(context)
                                      .push(AppRoutes.pushCloudConsent()),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Giriş yapıldı: ${account.email}',
                                textAlign: TextAlign.center,
                                style: textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 56,
                                child: ElevatedButton.icon(
                                  onPressed: _confirmSignOut,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        scheme.error.withValues(alpha: 0.12),
                                    foregroundColor: scheme.error,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  icon: const Icon(Icons.logout_rounded, size: 20),
                                  label: const Text('Çıkış yap'),
                                ),
                              ),
                            ],
                          );
                        }
                        // Local-only builds have no accounts to sign in to.
                        if (!state.accountsAvailable) return const SizedBox.shrink();
                        return SizedBox(
                          height: 56,
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.of(context)
                                .pushNamed(AppRoutes.login),
                            icon: const Icon(Icons.login_rounded, size: 20),
                            label: const Text('Giriş yap veya hesap oluştur'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Denge · Sürüm 1.0.0',
                        style: textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 32),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
      ),
    );
  }
}

class _RowIcon extends StatelessWidget {
  const _RowIcon(this.icon);
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: context.dengeColors.trackBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 20),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      child: Row(
        children: [
          _RowIcon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailingText,
    this.showTopDivider = false,
  });

  final IconData icon;
  final String title;
  final String? trailingText;
  final bool showTopDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: showTopDivider
              ? BoxDecoration(
                  border: Border(
                      top: BorderSide(color: context.dengeColors.divider)))
              : null,
          constraints: const BoxConstraints(minHeight: 64),
          child: Row(
            children: [
              _RowIcon(icon),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title,
                    style: textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
              if (trailingText != null) ...[
                Text(trailingText!,
                    style: textTheme.bodySmall?.copyWith(fontSize: 14)),
                const SizedBox(width: 4),
              ],
              Icon(Icons.chevron_right_rounded,
                  color: textTheme.bodyMedium?.color),
            ],
          ),
        ),
      ),
    );
  }
}
