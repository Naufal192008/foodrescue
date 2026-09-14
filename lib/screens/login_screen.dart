import 'package:flutter/material.dart';

import '../services/api_service.dart';
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
<<<<<<< HEAD
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final username = _usernameController.text.trim().toLowerCase();
    final account = DemoAccounts.accounts[username];

    // Verifikasi password menggunakan hash
    final isValid = account != null &&
        SecurityUtils.verifyPassword(
            _passwordController.text, account['password']!);
=======

    final input = _usernameController.text.trim();
    final password = _passwordController.text;

    final demoAccount = DemoAccounts.accounts[input.toLowerCase()];

    Map<String, dynamic> result;
    if (demoAccount != null && demoAccount['password'] == password) {
      result = {
        'success': true,
        'data': {
          'role': demoAccount['role'],
          'name': demoAccount['name'],
          'email': demoAccount['email'],
        }
      };
    } else {
      result = await ApiService.login(input, password);
    }
>>>>>>> 8e12a9f9ec6abf94a5e703b3a39ba5c0400d9447

    if (!mounted) return;
    setState(() => _isLoading = false);

<<<<<<< HEAD
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username atau password salah.')),
=======
    if (result['success'] == true) {
      final data = result['data'] ?? {};
      final role = data['role'] ?? 'user';
      final name = data['name'] ?? input;
      final email = data['email'] ?? input;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => role == 'admin'
              ? const AdminDashboardScreen()
              : MainNavigation(
                  username: input,
                  name: name,
                  email: email,
                ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Login gagal.')),
>>>>>>> 8e12a9f9ec6abf94a5e703b3a39ba5c0400d9447
      );
    }
<<<<<<< HEAD

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => account['role'] == 'admin'
            ? const AdminDashboardScreen()
            : MainNavigation(
                username: username,
                name: account['name']!,
                email: account['email']!,
              ),
      ),
    );
=======
>>>>>>> 8e12a9f9ec6abf94a5e703b3a39ba5c0400d9447
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/logo.jpeg',
                      width: 230,
                      height: 170,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Selamat datang di FoodRescue',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Masuk untuk menyelamatkan makanan dan mengurangi sampah.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.mutedText),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _usernameController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Username wajib diisi'
                              : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Tampilkan password'
                              : 'Sembunyikan password',
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Password wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _isLoading ? null : _login,
                      icon: _isLoading
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.login_rounded),
                      label: Text(_isLoading ? 'Memeriksa...' : 'Masuk'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const RegisterScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: const Text('Daftar sebagai user'),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Akun demo: user / user123 atau admin / admin123',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: AppColors.mutedText, fontSize: 12),
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
}

class DemoAccounts {
  static final accounts = <String, Map<String, String>>{
    'user': {
      'password': SecurityUtils.hashPassword('user123'),
      'role': 'user',
      'name': 'Budi Santoso',
      'email': 'budi.santoso@email.com',
    },
    'admin': {
      'password': SecurityUtils.hashPassword('admin123'),
      'role': 'admin',
      'name': 'Admin FoodRescue',
      'email': 'admin@foodrescue.com',
    },
  };

  static bool contains(String username) => accounts.containsKey(username);

  static void addAccount({
    required String username,
    required String password,
    required String name,
    required String email,
  }) {
    accounts[username] = {
      'password': SecurityUtils.hashPassword(password),
      'role': 'user',
      'name': name,
      'email': email,
    };
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