import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/app_colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _nameCtrl = TextEditingController(text: 'Super Admin');
  final _emailCtrl = TextEditingController(text: 'admin@foodrescue.id');
  final _currentPwdCtrl = TextEditingController();
  final _newPwdCtrl = TextEditingController();
  final _confirmPwdCtrl = TextEditingController();

  bool _twoFA = true;
  bool _emailNotif = true;
  bool _pushNotif = false;
  bool _maintenanceMode = false;
  bool _showPwd = false;

  static const _policy = [
    'Minimal 8 karakter',
    'Mengandung huruf besar & kecil',
    'Mengandung angka',
    'Mengandung simbol (!@#\$%)',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _currentPwdCtrl.dispose();
    _newPwdCtrl.dispose();
    _confirmPwdCtrl.dispose();
    super.dispose();
  }

  bool _isStrong(String p) =>
      p.length >= 8 &&
      p.contains(RegExp(r'[A-Z]')) &&
      p.contains(RegExp(r'[a-z]')) &&
      p.contains(RegExp(r'[0-9]')) &&
      p.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));

  Future<void> _changePassword() async {
    if (_newPwdCtrl.text != _confirmPwdCtrl.text) {
      _msg('Password baru dan konfirmasi tidak sama', danger: true);
      return;
    }
    if (!_isStrong(_newPwdCtrl.text)) {
      _msg('Password belum memenuhi kebijakan keamanan', danger: true);
      return;
    }
    final ok = await _confirmDialog('Ubah Password?',
        'Password akan diubah. Kamu harus login ulang setelah ini.');
    if (ok) {
      _msg('Password berhasil diubah');
      _currentPwdCtrl.clear();
      _newPwdCtrl.clear();
      _confirmPwdCtrl.clear();
      setState(() {});
    }
  }

  void _msg(String m, {bool danger = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(m),
      backgroundColor: danger ? AppColors.danger : AppColors.primary,
    ));
  }

  Future<bool> _confirmDialog(String title, String message) async {
    final r = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Konfirmasi')),
        ],
      ),
    );
    return r ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('Pengaturan',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        const Text('Kelola profil admin, keamanan, dan preferensi',
            style: TextStyle(color: AppColors.mutedText)),
        const SizedBox(height: 22),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(children: [
                _card(
                  title: 'Profil Admin',
                  icon: Icons.person_rounded,
                  child: Column(children: [
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Nama', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Email', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _msg('Profil berhasil diperbarui'),
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('Simpan Profil'),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),
                _card(
                  title: 'Keamanan',
                  icon: Icons.shield_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ganti Password',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 14)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _currentPwdCtrl,
                        obscureText: !_showPwd,
                        decoration: InputDecoration(
                          labelText: 'Password Saat Ini',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_showPwd
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () =>
                                setState(() => _showPwd = !_showPwd),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _newPwdCtrl,
                        obscureText: !_showPwd,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                            labelText: 'Password Baru',
                            border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _confirmPwdCtrl,
                        obscureText: !_showPwd,
                        decoration: const InputDecoration(
                            labelText: 'Konfirmasi Password Baru',
                            border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 14),
                      const Text('Kebijakan Password:',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 12)),
                      const SizedBox(height: 6),
                      ..._policy.map((p) {
                        final passed = _checkPolicy(p);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(children: [
                            Icon(
                              passed
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: passed
                                  ? AppColors.primary
                                  : AppColors.mutedText,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(p,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: passed
                                        ? AppColors.primary
                                        : AppColors.mutedText)),
                          ]),
                        );
                      }),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _changePassword,
                          icon: const Icon(Icons.lock_reset_rounded),
                          label: const Text('Ubah Password'),
                          style: FilledButton.styleFrom(
                              backgroundColor: AppColors.danger),
                        ),
                      ),
                      const Divider(height: 30),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _twoFA,
                        onChanged: (v) => setState(() => _twoFA = v),
                        title: const Text('Two-Factor Authentication',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13)),
                        subtitle: const Text('Tambahan keamanan login',
                            style: TextStyle(fontSize: 11)),
                        activeThumbColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(children: [
                _card(
                  title: 'Notifikasi',
                  icon: Icons.notifications_rounded,
                  child: Column(children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _emailNotif,
                      onChanged: (v) => setState(() => _emailNotif = v),
                      title: const Text('Email Notifikasi',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13)),
                      activeThumbColor: AppColors.primary,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _pushNotif,
                      onChanged: (v) => setState(() => _pushNotif = v),
                      title: const Text('Push Notifikasi',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13)),
                      activeThumbColor: AppColors.primary,
                    ),
                  ]),
                ),
                const SizedBox(height: 16),
                _card(
                  title: 'Sistem',
                  icon: Icons.settings_suggest_rounded,
                  child: Column(children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _maintenanceMode,
                      onChanged: (v) async {
                        final ok = await _confirmDialog(
                          'Mode Maintenance?',
                          v
                              ? 'Aplikasi akan offline untuk user. Lanjutkan?'
                              : 'Matikan mode maintenance?',
                        );
                        if (ok) setState(() => _maintenanceMode = v);
                      },
                      title: const Text('Mode Maintenance',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13)),
                      subtitle: Text(
                        _maintenanceMode
                            ? 'Aplikasi sedang offline'
                            : 'Aplikasi online normal',
                        style: const TextStyle(fontSize: 11),
                      ),
                      activeThumbColor: AppColors.danger,
                    ),
                    const Divider(height: 30),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.info_outline_rounded,
                          color: AppColors.primary),
                      title: const Text('Versi Aplikasi',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13)),
                      trailing: const Text('v1.0.0+1',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary)),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),
                _card(
                  title: 'Zona Bahaya',
                  icon: Icons.warning_amber_rounded,
                  danger: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Tindakan di bawah ini tidak dapat dibatalkan. Gunakan dengan hati-hati.',
                        style: TextStyle(fontSize: 12, color: AppColors.mutedText),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final ok = await _confirmDialog(
                              'Clear Audit Logs?',
                              'Semua log aktivitas akan dihapus permanen.');
                          if (ok) _msg('Audit logs dibersihkan');
                        },
                        icon: const Icon(Icons.delete_sweep_rounded),
                        label: const Text('Bersihkan Audit Logs'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.danger),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
      ],
    );
  }

  bool _checkPolicy(String p) {
    final v = _newPwdCtrl.text;
    if (p.contains('8')) return v.length >= 8;
    if (p.contains('besar')) return v.contains(RegExp(r'[A-Z]')) && v.contains(RegExp(r'[a-z]'));
    if (p.contains('angka')) return v.contains(RegExp(r'[0-9]'));
    if (p.contains('simbol')) return v.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    return false;
  }

  Widget _card({
    required String title,
    required IconData icon,
    required Widget child,
    bool danger = false,
  }) =>
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: danger ? AppColors.danger.withValues(alpha: 0.4) : const Color(0xFFE2E8E3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon,
                  color: danger ? AppColors.danger : AppColors.primary,
                  size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: danger ? AppColors.danger : AppColors.text)),
            ]),
            const SizedBox(height: 16),
            child,
          ],
        ),
      );
}