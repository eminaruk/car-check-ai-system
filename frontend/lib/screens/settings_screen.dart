import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          // Profil Bölümü
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(
                    Icons.person,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.user,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        l10n.accountSettingsHint,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
          const Divider(),

          // Ayarlar Listesi
          _SettingsSection(
            title: l10n.appSection,
            children: [
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: l10n.notifications,
                subtitle: l10n.notificationsSubtitle,
                onTap: () {
                  _showComingSoon(context);
                },
              ),
              _SettingsTile(
                icon: Icons.language,
                title: l10n.language,
                subtitle: _getLanguageName(context),
                onTap: () {
                  _showLanguageDialog(context);
                },
              ),
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: l10n.theme,
                subtitle: _getThemeSubtitle(context),
                onTap: () {
                  _showThemeDialog(context);
                },
              ),
            ],
          ),

          _SettingsSection(
            title: l10n.dataSection,
            children: [
              _SettingsTile(
                icon: Icons.cloud_upload_outlined,
                title: l10n.backup,
                subtitle: l10n.backupSubtitle,
                onTap: () {
                  _showComingSoon(context);
                },
              ),
              _SettingsTile(
                icon: Icons.delete_outline,
                title: l10n.deleteData,
                subtitle: l10n.deleteDataSubtitle,
                isDestructive: true,
                onTap: () {
                  _showDeleteConfirmation(context);
                },
              ),
            ],
          ),

          _SettingsSection(
            title: l10n.aboutSection,
            children: [
              _SettingsTile(
                icon: Icons.info_outline,
                title: l10n.aboutApp,
                subtitle: l10n.versionInfo,
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: l10n.privacyPolicy,
                onTap: () {
                  _showComingSoon(context);
                },
              ),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: l10n.termsOfService,
                onTap: () {
                  _showComingSoon(context);
                },
              ),
              _SettingsTile(
                icon: Icons.help_outline,
                title: l10n.helpSupport,
                onTap: () {
                  _showComingSoon(context);
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Çıkış Butonu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () {
                _showComingSoon(context);
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: Text(
                l10n.logout,
                style: const TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getLanguageName(BuildContext context) {
    final notifier = ThemeNotifier.of(context);
    if (notifier == null) return 'English';
    final code = notifier.locale.languageCode;
    final languages = {
      'en': 'English',
      'es': 'Español',
      'it': 'Italiano',
      'fr': 'Français',
      'de': 'Deutsch',
      'tr': 'Türkçe',
      'pt': 'Português',
      'nl': 'Nederlands',
      'ru': 'Русский',
      'pl': 'Polski',
      'zh': '中文',
      'ja': '日本語',
      'ko': '한국어',
      'sv': 'Svenska',
      'no': 'Norsk',
      'da': 'Dansk',
      'cs': 'Čeština',
      'hu': 'Magyar',
    };
    return languages[code] ?? 'English';
  }

  String _getThemeSubtitle(BuildContext context) {
    final notifier = ThemeNotifier.of(context);
    final l10n = AppLocalizations.of(context)!;
    if (notifier == null) return l10n.system;
    switch (notifier.themeMode) {
      case ThemeMode.dark:
        return l10n.dark;
      case ThemeMode.light:
        return l10n.light;
      case ThemeMode.system:
        return l10n.system;
    }
  }

  void _showLanguageDialog(BuildContext context) {
    final notifier = ThemeNotifier.of(context);
    if (notifier == null) {
      _showComingSoon(context);
      return;
    }

    final languages = [
      {'code': 'en', 'name': 'English'},
      {'code': 'es', 'name': 'Español'},
      {'code': 'it', 'name': 'Italiano'},
      {'code': 'fr', 'name': 'Français'},
      {'code': 'de', 'name': 'Deutsch'},
      {'code': 'tr', 'name': 'Türkçe'},
      {'code': 'pt', 'name': 'Português'},
      {'code': 'nl', 'name': 'Nederlands'},
      {'code': 'ru', 'name': 'Русский'},
      {'code': 'pl', 'name': 'Polski'},
      {'code': 'zh', 'name': '中文'},
      {'code': 'ja', 'name': '日本語'},
      {'code': 'ko', 'name': '한국어'},
      {'code': 'sv', 'name': 'Svenska'},
      {'code': 'no', 'name': 'Norsk'},
      {'code': 'da', 'name': 'Dansk'},
      {'code': 'cs', 'name': 'Čeština'},
      {'code': 'hu', 'name': 'Magyar'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.language),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: languages.map((lang) {
                return RadioListTile<String>(
                  title: Text(lang['name']!),
                  value: lang['code']!,
                  groupValue: notifier.locale.languageCode,
                  onChanged: (value) {
                    if (value != null) {
                      notifier.onLocaleChanged(Locale(value));
                      Navigator.pop(context);
                    }
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final notifier = ThemeNotifier.of(context);
    if (notifier == null) {
      _showComingSoon(context);
      return;
    }

    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectTheme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: Text(l10n.light),
              value: ThemeMode.light,
              groupValue: notifier.themeMode,
              onChanged: (value) {
                if (value != null) {
                  notifier.onThemeChanged(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(l10n.dark),
              value: ThemeMode.dark,
              groupValue: notifier.themeMode,
              onChanged: (value) {
                if (value != null) {
                  notifier.onThemeChanged(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(l10n.system),
              value: ThemeMode.system,
              groupValue: notifier.themeMode,
              onChanged: (value) {
                if (value != null) {
                  notifier.onThemeChanged(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.comingSoon)),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteDataTitle),
        content: Text(l10n.deleteDataConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.dataDeleted)),
              );
            },
            child: Text(
              l10n.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.directions_car, color: Colors.blue),
            const SizedBox(width: 8),
            Text(l10n.appTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.versionInfo),
            const SizedBox(height: 8),
            Text(l10n.appDescription),
            const SizedBox(height: 16),
            Text(
              l10n.copyright,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : null;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color),
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
