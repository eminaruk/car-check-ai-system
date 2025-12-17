import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
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
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kullanıcı',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Hesap ayarları için tıklayın',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
          const Divider(),

          // Ayarlar Listesi
          _SettingsSection(
            title: 'Uygulama',
            children: [
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Bildirimler',
                subtitle: 'Bildirim ayarlarını yönetin',
                onTap: () {
                  _showComingSoon(context);
                },
              ),
              _SettingsTile(
                icon: Icons.language,
                title: 'Dil',
                subtitle: 'Türkçe',
                onTap: () {
                  _showComingSoon(context);
                },
              ),
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'Tema',
                subtitle: 'Açık',
                onTap: () {
                  _showComingSoon(context);
                },
              ),
            ],
          ),

          _SettingsSection(
            title: 'Veri',
            children: [
              _SettingsTile(
                icon: Icons.cloud_upload_outlined,
                title: 'Yedekleme',
                subtitle: 'Verilerinizi yedekleyin',
                onTap: () {
                  _showComingSoon(context);
                },
              ),
              _SettingsTile(
                icon: Icons.delete_outline,
                title: 'Verileri Sil',
                subtitle: 'Tüm verileri temizle',
                isDestructive: true,
                onTap: () {
                  _showDeleteConfirmation(context);
                },
              ),
            ],
          ),

          _SettingsSection(
            title: 'Hakkında',
            children: [
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'Uygulama Hakkında',
                subtitle: 'Versiyon 1.0.0',
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Gizlilik Politikası',
                onTap: () {
                  _showComingSoon(context);
                },
              ),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: 'Kullanım Koşulları',
                onTap: () {
                  _showComingSoon(context);
                },
              ),
              _SettingsTile(
                icon: Icons.help_outline,
                title: 'Yardım & Destek',
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
              label: const Text(
                'Çıkış Yap',
                style: TextStyle(color: Colors.red),
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

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bu özellik yakında eklenecek')),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verileri Sil'),
        content: const Text(
          'Tüm verileriniz silinecek. Bu işlem geri alınamaz. Emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Veriler silindi')),
              );
            },
            child: const Text(
              'Sil',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.directions_car, color: Colors.blue),
            SizedBox(width: 8),
            Text('Car Check AI'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Versiyon: 1.0.0'),
            SizedBox(height: 8),
            Text(
              'AI destekli araç bakım analiz uygulaması. '
              'Aracınızın durumunu fotoğraflarla analiz edin.',
            ),
            SizedBox(height: 16),
            Text(
              '© 2025 Car Check AI',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
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

