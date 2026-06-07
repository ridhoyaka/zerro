import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'pin_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pengaturan'),
      ),
      body: Column(
        children: [
          // ── Konten yang bisa di-scroll ─────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Keamanan ────────────────────────────────────────
                  _sectionLabel('Keamanan'),
                  const SizedBox(height: 8),
                  _SettingsTile(
                    icon: Icons.pin_rounded,
                    iconColor: AppTheme.primary,
                    title: 'Ubah PIN',
                    subtitle: 'Ganti PIN 6 digit untuk membuka aplikasi',
                    onTap: () => _changePin(context),
                  ),

                  const SizedBox(height: 20),

                  // ── Bantuan ─────────────────────────────────────────
                  _sectionLabel('Bantuan'),
                  const SizedBox(height: 8),
                  _SettingsTile(
                    icon: Icons.help_outline_rounded,
                    iconColor: AppTheme.accent,
                    title: 'Help & Support',
                    subtitle: 'Panduan penggunaan aplikasi',
                    onTap: () => _showInfoSheet(
                      context,
                      title: 'Help & Support',
                      icon: Icons.help_outline_rounded,
                      iconColor: AppTheme.accent,
                      content: _helpContent,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Tentang ─────────────────────────────────────────
                  _sectionLabel('Tentang'),
                  const SizedBox(height: 8),
                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    iconColor: AppTheme.accentGreen,
                    title: 'About',
                    subtitle: 'Informasi versi aplikasi',
                    onTap: () => _showInfoSheet(
                      context,
                      title: 'About Zerro',
                      icon: Icons.shield_rounded,
                      iconColor: AppTheme.primary,
                      content: _aboutContent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _SettingsTile(
                    icon: Icons.people_outline_rounded,
                    iconColor: AppTheme.warning,
                    title: 'Credits',
                    subtitle: 'Tim pengembang',
                    onTap: () => _showInfoSheet(
                      context,
                      title: 'Credits',
                      icon: Icons.people_outline_rounded,
                      iconColor: AppTheme.warning,
                      content: _creditsContent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _SettingsTile(
                    icon: Icons.gavel_rounded,
                    iconColor: AppTheme.textSecondary,
                    title: 'Legal',
                    subtitle: 'Kebijakan privasi & ketentuan penggunaan',
                    onTap: () => _showInfoSheet(
                      context,
                      title: 'Legal',
                      icon: Icons.gavel_rounded,
                      iconColor: AppTheme.textSecondary,
                      content: _legalContent,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Footer — selalu nempel di bawah ───────────────────────
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primary, AppTheme.accent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Icon(
                            Icons.shield_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Zerro',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'YakaLabs Technologies',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '© 2026 All rights reserved.',
                      style: TextStyle(color: AppTheme.textHint, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Change PIN flow ───────────────────────────────────────────────────────

  Future<void> _changePin(BuildContext context) async {
    // Verifikasi PIN lama dulu
    final verified = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const PinScreen(
          mode: PinMode.unlock,
          title: 'Verifikasi PIN',
          subtitle: 'Masukkan PIN saat ini untuk melanjutkan',
        ),
      ),
    );
    if (verified != true || !context.mounted) return;

    // Setup PIN baru
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const PinScreen(
          mode: PinMode.setup,
          title: 'PIN Baru',
          subtitle: 'Masukkan PIN 6 digit yang baru',
        ),
      ),
    );
    if (!context.mounted) return;
    if (changed == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('PIN berhasil diubah')));
    }
  }

  // ── Info bottom sheet ─────────────────────────────────────────────────────

  void _showInfoSheet(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<_InfoItem> content,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (_, scrollCtrl) => Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textHint,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: content.map((item) {
                  if (item.isHeading) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 6),
                      child: Text(
                        item.text,
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      item.text,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Content ───────────────────────────────────────────────────────────────

  static const List<_InfoItem> _helpContent = [
    _InfoItem('MEMULAI', isHeading: true),
    _InfoItem(
      'Zerro menggunakan PIN 6 digit untuk melindungi data Anda. PIN default adalah 000000. Segera ubah PIN setelah pertama kali masuk.',
    ),
    _InfoItem('MENAMBAH ITEM', isHeading: true),
    _InfoItem(
      'Tap tombol + di halaman utama, lalu pilih kategori yang sesuai: Login, Kartu, Identitas, atau Catatan Aman.',
    ),
    _InfoItem('KATEGORI', isHeading: true),
    _InfoItem(
      '• Login — Simpan username dan password akun online.\n• Kartu — Simpan informasi kartu debit/kredit.\n• Identitas — Simpan data dokumen identitas (KTP, SIM, dll).\n• Catatan Aman — Simpan catatan rahasia terenkripsi.',
    ),
    _InfoItem('MENCARI ITEM', isHeading: true),
    _InfoItem(
      'Gunakan ikon 🔍 di pojok kanan atas untuk mencari item berdasarkan nama.',
    ),
    _InfoItem('MENGUBAH PIN', isHeading: true),
    _InfoItem(
      'Buka Pengaturan → Ubah PIN. Anda akan diminta memasukkan PIN lama terlebih dahulu.',
    ),
  ];

  static const List<_InfoItem> _aboutContent = [
    _InfoItem('ZERRO', isHeading: true),
    _InfoItem(
      'Zerro adalah aplikasi pengelola password lokal yang aman. Semua data disimpan di perangkat Anda dan tidak pernah dikirim ke server manapun.',
    ),
    _InfoItem('VERSI', isHeading: true),
    _InfoItem('Versi 1.0.0'),
    _InfoItem('PLATFORM', isHeading: true),
    _InfoItem('Android · Flutter'),
    _InfoItem('FITUR', isHeading: true),
    _InfoItem(
      '• Perlindungan PIN 6 digit\n• 4 kategori penyimpanan\n• Generator password otomatis\n• Indikator kekuatan password\n• Pencarian cepat\n• Penyimpanan lokal terenkripsi',
    ),
  ];

  static const List<_InfoItem> _creditsContent = [
    _InfoItem('PENGEMBANG', isHeading: true),
    _InfoItem(
      'Zerro dikembangkan oleh YakaLabs sebagai aplikasi pengelola password yang aman, modern, dan mudah digunakan untuk membantu pengguna menyimpan informasi penting dengan lebih praktis dan terlindungi.',
    ),
    _InfoItem('TEKNOLOGI', isHeading: true),
    _InfoItem(
      'Aplikasi ini dibangun menggunakan Flutter dan Dart dengan dukungan teknologi modern untuk menghadirkan performa yang cepat, tampilan yang responsif, dan pengalaman pengguna yang nyaman.',
    ),
    _InfoItem('TERIMA KASIH', isHeading: true),
    _InfoItem(
      'Terima kasih kepada semua pihak, komunitas open-source, serta para pengguna yang telah mendukung pengembangan Zerro hingga menjadi aplikasi yang terus berkembang dan lebih baik.',
    ),
  ];

  static const List<_InfoItem> _legalContent = [
    _InfoItem('KEBIJAKAN PRIVASI', isHeading: true),
    _InfoItem(
      'Zerro tidak mengumpulkan, menyimpan, atau mengirimkan data pribadi Anda ke server manapun. Semua data tersimpan secara lokal di perangkat Anda.',
    ),
    _InfoItem('KEAMANAN DATA', isHeading: true),
    _InfoItem(
      'Data Anda dilindungi oleh PIN yang hanya Anda ketahui. Jika PIN lupa, data tidak dapat dipulihkan. Pastikan Anda mengingat PIN Anda.',
    ),
    _InfoItem('KETENTUAN PENGGUNAAN', isHeading: true),
    _InfoItem(
      'Aplikasi ini disediakan "sebagaimana adanya" tanpa jaminan apapun. Pengembang tidak bertanggung jawab atas kehilangan data akibat lupa PIN atau kerusakan perangkat.',
    ),
    _InfoItem('HAK CIPTA', isHeading: true),
    _InfoItem('© 2026 YakaLabs Technologies. All rights reserved.'),
  ];

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 0),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppTheme.textHint,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
    ),
  );
}

// ── Reusable tile ─────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.textHint,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textHint,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────

class _InfoItem {
  final String text;
  final bool isHeading;
  const _InfoItem(this.text, {this.isHeading = false});
}
