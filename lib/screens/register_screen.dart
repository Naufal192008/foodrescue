import 'package:flutter/material.dart';

<<<<<<< HEAD
import '../utils/app_colors.dart';
import '../utils/security_utils.dart';
=======
>>>>>>> 8e12a9f9ec6abf94a5e703b3a39ba5c0400d9447
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
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;

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
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar User')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            children: [
              Image.asset(
                'assets/logo.jpeg',
                width: 200,
                height: 145,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 12),
              Text(
                'Buat akun FoodRescue',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama lengkap',
                  prefixIcon: Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => _required(value, 'Nama lengkap'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
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
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final error = _required(value, 'Email');
                  if (error != null) return error;
                  return value!.contains('@') ? null : 'Email tidak valid';
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    onPressed: () => setState(
                      () => _obscurePassword = !_obscurePassword,
                    ),
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  final error = _required(value, 'Password');
                  if (error != null) return error;
                  return value!.length < 6
                      ? 'Password minimal 6 karakter'
                      : null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _confirmationController,
                obscureText: _obscureConfirmation,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi password',
                  prefixIcon: const Icon(Icons.lock_reset_outlined),
                  suffixIcon: IconButton(
                    onPressed: () => setState(
                      () => _obscureConfirmation = !_obscureConfirmation,
                    ),
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
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _register,
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('Buat akun'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}