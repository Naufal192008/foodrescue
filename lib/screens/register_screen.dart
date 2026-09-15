import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../utils/security_utils.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  bool _agreedToTerms = false;
  String _selectedRole = 'Rescuer (Konsumen)';

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  void _register() {
    // SECURITY: local registration is a debug-only fixture; production must use
    // a backend registration endpoint with verification and rate limiting.
    if (!kDebugMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pendaftaran belum tersedia.')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kamu harus menyetujui syarat dan ketentuan.'),
        ),
      );
      return;
    }

    final username = _usernameController.text.trim().toLowerCase();
    if (DemoAccounts.contains(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username sudah digunakan.')),
      );
      return;
    }

    DemoAccounts.addAccount(
      username: username,
      password: _passwordController.text,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      ecosystemRole: _selectedRole,
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => LoginScreen(initialUsername: username),
      ),
      (route) => false,
    );
  }

  String? _required(String? value, String label) {
    return value == null || value.trim().isEmpty ? '$label wajib diisi' : null;
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
                                  color: const Color(0xFF1F2933),
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                                children: const [
                                  TextSpan(text: 'FOOD RESCUE '),
                                  TextSpan(
                                    text: '•',
                                    style: TextStyle(color: Color(0xFFFF9800)),
                                  ),
                                ],
                              ),
                            ),
                            const Text(
                              'Taste Without Waste',
                              style: TextStyle(
                                color: Color(0xFF667085),
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),
                    Text('Daftar Akun Baru',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1F2933),
                        )),
                    const SizedBox(height: 8),
                    const Text(
                      'Bergabunglah dengan FoodRescue dan bantu\nselamatkan lebih banyak makanan setiap hari.',
                      style: TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 18,
                        height: 1.8,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildAuthTabs(context),
                    const SizedBox(height: 28),
                    const _RegisterLabel(label: 'Nama Lengkap'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'Nama lengkap kamu',
                        prefixIcon: Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => _required(value, 'Nama lengkap'),
                    ),
                    const SizedBox(height: 18),
                    const _RegisterLabel(label: 'Username'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _usernameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'username kamu',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final error = _required(value, 'Username');
                        if (error != null) return error;
                        if (value!.trim().contains(' ')) {
                          return 'Username tidak boleh mengandung spasi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    const _RegisterLabel(label: 'Alamat Email'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'nama@email.com',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final error = _required(value, 'Email');
                        if (error != null) return error;
                        return SecurityUtils.isValidEmail(value!.trim())
                            ? null
                            : 'Email tidak valid';
                      },
                    ),
                    const SizedBox(height: 18),
                    const _RegisterLabel(label: 'Nomor HP'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: '08xxxxxxxxxx',
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final error = _required(value, 'Nomor HP');
                        if (error != null) return error;
                        final phone = value!.replaceAll(RegExp(r'[^0-9+]'), '');
                        return phone.length < 10
                            ? 'Nomor HP minimal 10 digit'
                            : null;
                      },
                    ),
                    const _RegisterLabel(label: 'Kata Sandi'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: 'Buat kata sandi yang kuat',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final error = _required(value, 'Password');
                        if (error != null) return error;
                        return value!.length < 8
                            ? 'Password minimal 8 karakter'
                            : null;
                      },
                    ),
                    const SizedBox(height: 18),
                    const _RegisterLabel(label: 'Konfirmasi Kata Sandi'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmationController,
                      obscureText: _obscureConfirmation,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _register(),
                      decoration: InputDecoration(
                        hintText: 'Ulangi kata sandi kamu',
                        prefixIcon: const Icon(Icons.lock_reset_outlined),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() =>
                              _obscureConfirmation = !_obscureConfirmation),
                          icon: Icon(_obscureConfirmation
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) => value != _passwordController.text
                          ? 'Konfirmasi password tidak cocok'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    const _RegisterLabel(label: 'Pilih Peran Ekosistem'),
                    const SizedBox(height: 10),
                    _RegisterRoleCard(
                      icon: Icons.eco_rounded,
                      title: 'Rescuer (Konsumen)',
                      subtitle: 'Beli & selamatkan surplus makanan lezat...',
                      color: const Color(0xFF8BF5A3),
                      selected: _selectedRole == 'Rescuer (Konsumen)',
                      onTap: () =>
                          setState(() => _selectedRole = 'Rescuer (Konsumen)'),
                    ),
                    _RegisterRoleCard(
                      icon: Icons.storefront_rounded,
                      title: 'Mitra Toko & Resto',
                      subtitle: 'Jual kelebihan stok harian & tingkatkan...',
                      color: const Color(0xFFFFD7C9),
                      selected: _selectedRole == 'Mitra Toko & Resto',
                      onTap: () =>
                          setState(() => _selectedRole = 'Mitra Toko & Resto'),
                    ),
                    _RegisterRoleCard(
                      icon: Icons.pedal_bike_rounded,
                      title: 'Kurir Penyelamat',
                      subtitle: 'Antar logistik dengan rute yang efisien...',
                      color: const Color(0xFFB8F3C2),
                      selected: _selectedRole == 'Kurir Penyelamat',
                      onTap: () =>
                          setState(() => _selectedRole = 'Kurir Penyelamat'),
                    ),
                    CheckboxListTile(
                      value: _agreedToTerms,
                      onChanged: (value) => setState(
                        () => _agreedToTerms = value ?? false,
                      ),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: const Color(0xFF2E7D32),
                      title: const Text(
                        'Saya setuju dengan syarat dan ketentuan FoodRescue',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 58,
                      child: FilledButton(
                        onPressed: _register,
                        child: const Text('BUAT AKUN'),
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
            child: TextButton(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
              ),
              child: const Text('Masuk'),
            ),
          ),
          Expanded(
            child: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2E7D32),
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13)),
              ),
              child: const Text('Daftar Akun Baru'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterLabel extends StatelessWidget {
  const _RegisterLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(
          color: Color(0xFF1F2933), fontSize: 16, fontWeight: FontWeight.w700));
}

class _RegisterRoleCard extends StatelessWidget {
  const _RegisterRoleCard({
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
            color: selected ? const Color(0xFF2E7D32) : Colors.transparent,
            width: selected ? 3 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: const Color(0xFF1B5E20), size: 30),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        color: Color(0xFF1F2933),
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      )),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 15,
                      )),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle,
              color:
                  selected ? const Color(0xFF2E7D32) : const Color(0xFFE6E8E6),
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}
