import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../admin/admin_layout.dart';
import '../admin/models/admin_user.dart';
import '../admin/services/admin_data_service.dart';
import '../utils/app_colors.dart';
import '../utils/security_utils.dart';
import 'main_navigation.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.initialUsername});

  final String? initialUsername;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = true;
  String _selectedRole = 'Rescuer (Konsumen)';

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.initialUsername ?? '';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final username = _usernameController.text.trim().toLowerCase();
    final password = _passwordController.text;

    // SECURITY: local accounts are debug fixtures only and never an admin path.
    final demoAccount = kDebugMode ? DemoAccounts.accounts[username] : null;
    final isValidLocal = demoAccount != null &&
        demoAccount['role'] == 'user' &&
        SecurityUtils.verifyPassword(password, demoAccount['password']!);

    if (!mounted) return;

    if (isValidLocal) {
      // Login berhasil via akun demo lokal
      setState(() => _isLoading = false);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => demoAccount['role'] == 'admin'
              ? const AdminLayout()
              : MainNavigation(
                  username: username,
                  name: demoAccount['name']!,
                  email: demoAccount['email']!,
                ),
        ),
      );
      return;
    }

    // Fallback: coba login via API server
    final result = await ApiService.login(username, password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      final data = result['data'] ?? {};
      final role = data['role'] ?? 'user';
      final name = data['name'] ?? username;
      final email = data['email'] ?? username;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => role == 'admin'
              ? const AdminLayout()
              : MainNavigation(
                  username: username,
                  name: name,
                  email: email,
                ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(result['message'] ?? 'Username atau password salah.')),
      );
    }
  }

  Future<void> _forgotPassword() async {
    final emailController = TextEditingController(
      text: _usernameController.text.contains('@')
          ? _usernameController.text.trim()
          : '',
    );
    final newPasswordController = TextEditingController();
    final confirmationController = TextEditingController();

    final values = await showDialog<List<String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Atur Ulang Kata Sandi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Alamat email',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password baru',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmationController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Konfirmasi password baru',
                  prefixIcon: Icon(Icons.lock_reset_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop([
              emailController.text.trim().toLowerCase(),
              newPasswordController.text,
              confirmationController.text,
            ]),
            child: const Text('Simpan Password'),
          ),
        ],
      ),
    );

    emailController.dispose();
    newPasswordController.dispose();
    confirmationController.dispose();

    if (!mounted || values == null) return;
    final email = values[0];
    final newPassword = values[1];
    final confirmation = values[2];
    final account = DemoAccounts.findByEmail(email);

    if (account == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email belum terdaftar.')),
      );
      return;
    }
    if (newPassword.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password minimal 8 karakter.')),
      );
      return;
    }
    if (newPassword != confirmation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi password tidak cocok.')),
      );
      return;
    }

    DemoAccounts.resetPassword(email, newPassword);
    _usernameController.text = email;
    _passwordController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password berhasil diperbarui.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(30, 26, 30, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 530),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x12000000),
                                blurRadius: 14,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Image.asset('assets/logo.jpeg'),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: textTheme.headlineSmall?.copyWith(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                                children: const [
                                  TextSpan(text: 'FOOD RESCUE '),
                                  TextSpan(
                                    text: '•',
                                    style:
                                        TextStyle(color: AppColors.secondary),
                                  ),
                                ],
                              ),
                            ),
                            const Text(
                              'Taste Without Waste',
                              style: TextStyle(
                                color: AppColors.mutedText,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),
                    Text('Masuk ke Akun',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        )),
                    const SizedBox(height: 8),
                    const Text(
                      'Selamat datang kembali! Selamatkan makanan lezat\nbernutrisi dan kurangi surplus pangan harian.',
                      style: TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 18,
                        height: 1.8,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildAuthTabs(context),
                    const SizedBox(height: 32),
                    _buildGoogleButton(),
                    const SizedBox(height: 24),
                    const _DividerLabel(label: 'ATAU MASUK DENGAN EMAIL'),
                    const SizedBox(height: 24),
                    const _FieldLabel(label: 'Alamat Email'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _usernameController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'nama@email.com',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Alamat email wajib diisi'
                              : null,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Akun demo: budi.santoso@email.com / user123',
                      style: TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const _FieldLabel(label: 'Kata Sandi'),
                        TextButton(
                          onPressed: _forgotPassword,
                          child: const Text('Lupa Kata Sandi?'),
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                      decoration: InputDecoration(
                        hintText: '••••••••••••',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Tampilkan password'
                              : 'Sembunyikan password',
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Kata sandi wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      value: _rememberMe,
                      onChanged: (value) =>
                          setState(() => _rememberMe = value ?? false),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text('Ingat Saya di Perangkat Ini'),
                      activeColor: AppColors.primary,
                    ),
                    const SizedBox(height: 14),
                    const _FieldLabel(label: 'Pilih Peran Ekosistem'),
                    const SizedBox(height: 10),
                    _RoleCard(
                      icon: Icons.eco_rounded,
                      title: 'Rescuer (Konsumen)',
                      subtitle: 'Beli & selamatkan surplus makanan lezat...',
                      color: const Color(0xFF8BF5A3),
                      selected: _selectedRole == 'Rescuer (Konsumen)',
                      onTap: () =>
                          setState(() => _selectedRole = 'Rescuer (Konsumen)'),
                    ),
                    _RoleCard(
                      icon: Icons.storefront_rounded,
                      title: 'Mitra Toko & Resto',
                      subtitle: 'Jual kelebihan stok harian & tingkatkan...',
                      color: const Color(0xFFFFD7C9),
                      selected: _selectedRole == 'Mitra Toko & Resto',
                      onTap: () =>
                          setState(() => _selectedRole = 'Mitra Toko & Resto'),
                    ),
                    _RoleCard(
                      icon: Icons.pedal_bike_rounded,
                      title: 'Kurir Penyelamat',
                      subtitle: 'Antar logistik bersinulasi dengan rute...',
                      color: const Color(0xFFB8F3C2),
                      selected: _selectedRole == 'Kurir Penyelamat',
                      onTap: () =>
                          setState(() => _selectedRole = 'Kurir Penyelamat'),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 58,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const SizedBox.square(
                                dimension: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('MASUK KE AKUN'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthTabs(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF1EF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: FilledButton(
              onPressed: _isLoading ? null : _login,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13)),
              ),
              child: const Text('Masuk'),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const RegisterScreen()),
              ),
              child: const Text('Daftar Akun Baru'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleButton() {
    return OutlinedButton(
      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Google segera hadir.'))),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(68),
        backgroundColor: Colors.white,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('G',
              style: TextStyle(
                  color: Color(0xFF4285F4),
                  fontSize: 26,
                  fontWeight: FontWeight.w800)),
          SizedBox(width: 18),
          Text('Lanjutkan dengan Google',
              style: TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(
          color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w700));
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Row(children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(label,
              style: const TextStyle(
                  color: AppColors.mutedText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1)),
        ),
        const Expanded(child: Divider()),
      ]);
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: selected ? 3 : 1,
          ),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: AppColors.primaryDark, size: 30),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppColors.mutedText, fontSize: 15)),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle,
              color: selected ? AppColors.primary : const Color(0xFFE6E8E6),
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}

class DemoAccounts {
  static final accounts = <String, Map<String, String>>{
    'user': {
      'password': SecurityUtils.hashPassword('user123'),
      'role': 'user',
      'name': 'Budi Santoso',
      'email': 'budi.santoso@email.com',
      'phone': '081234567890',
      'ecosystemRole': 'Rescuer (Konsumen)',
    },
    'budi.santoso@email.com': {
      'password': SecurityUtils.hashPassword('user123'),
      'role': 'user',
      'name': 'Budi Santoso',
      'email': 'budi.santoso@email.com',
      'phone': '081234567890',
      'ecosystemRole': 'Rescuer (Konsumen)',
    },
  };

  static bool contains(String username) => accounts.containsKey(username);

  static Map<String, String>? findByEmail(String email) {
    for (final account in accounts.values) {
      if (account['email']?.toLowerCase() == email.toLowerCase()) {
        return account;
      }
    }
    return null;
  }

  static void resetPassword(String email, String password) {
    for (final account in accounts.values) {
      if (account['email']?.toLowerCase() == email.toLowerCase()) {
        account['password'] = SecurityUtils.hashPassword(password);
      }
    }
  }

  static void addAccount({
    required String username,
    required String password,
    required String name,
    required String email,
    required String phone,
    required String ecosystemRole,
  }) {
    accounts[username] = {
      'password': SecurityUtils.hashPassword(password),
      'role': 'user',
      'name': name,
      'email': email,
      'phone': phone,
      'ecosystemRole': ecosystemRole,
    };
    AdminDataService().addUser(AdminUser(
      id: 'U${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      role: UserRole.customer,
      status: UserStatus.active,
      joinedAt: DateTime.now(),
    ));
  }

  static void updateProfile({
    required String username,
    required String name,
    required String email,
  }) {
    final account = accounts[username];
    if (account == null) return;
    account['name'] = name;
    account['email'] = email;
  }
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
            ),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Ringkasan hari ini',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          const _AdminStatTile(
              icon: Icons.people_alt_outlined,
              label: 'Pengguna aktif',
              value: '128'),
          const _AdminStatTile(
              icon: Icons.storefront_outlined,
              label: 'Toko terdaftar',
              value: '24'),
          const _AdminStatTile(
              icon: Icons.shopping_bag_outlined,
              label: 'Pesanan hari ini',
              value: '56'),
        ],
      ),
    );
  }
}

class _AdminStatTile extends StatelessWidget {
  const _AdminStatTile(
      {required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.successLight,
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(label),
        trailing: Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
        ),
      ),
    );
  }
}
