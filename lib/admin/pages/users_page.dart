import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../utils/app_colors.dart';
import '../models/admin_user.dart';
import '../providers/admin_provider.dart';
import '../widgets/confirm_dialog.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final _searchCtrl = TextEditingController();
  String _roleFilter = 'Semua';
  String _statusFilter = 'Semua';
  int _page = 0;
  static const _perPage = 8;

  List<AdminUser> _filtered(List<AdminUser> users) => users.where((u) {
        final q = _searchCtrl.text.toLowerCase();
        final matchQ = u.name.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q) ||
            u.phone.contains(q);
        final matchR = _roleFilter == 'Semua' ||
            u.role.name.toLowerCase() == _roleFilter.toLowerCase();
        final matchS = _statusFilter == 'Semua' ||
            u.status.name.toLowerCase() == _statusFilter.toLowerCase();
        return matchQ && matchR && matchS;
      }).toList();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final filtered = _filtered(provider.users);
    final totalPages = (filtered.length / _perPage).ceil().clamp(1, 999);
    if (_page >= totalPages) _page = totalPages - 1;
    final paged = filtered.skip(_page * _perPage).take(_perPage).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(provider),
          const SizedBox(height: 16),
          _filters(),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8E3)),
              ),
              child: Column(
                children: [
                  _tableHeader(),
                  const Divider(height: 1),
                  Expanded(
                    child: paged.isEmpty
                        ? const Center(child: Text('Tidak ada pengguna'))
                        : ListView.separated(
                            itemCount: paged.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (_, i) => _userRow(paged[i]),
                          ),
                  ),
                  if (totalPages > 1) _pagination(totalPages),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(AdminProvider p) => Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Manajemen Pengguna',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                SizedBox(height: 4),
                Text('Kelola semua pengguna platform FoodRescue',
                    style: TextStyle(color: AppColors.mutedText)),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () => _showUserForm(),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            icon: const Icon(Icons.person_add_rounded),
            label: const Text('Tambah Pengguna',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      );

  Widget _filters() => Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() => _page = 0),
              decoration: InputDecoration(
                hintText: 'Cari nama, email, atau telepon...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8E3))),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _dropdown(
              'Role',
              _roleFilter,
              ['Semua', 'admin', 'superAdmin', 'storeOwner', 'customer'],
              (v) => setState(() {
                    _roleFilter = v!;
                    _page = 0;
                  })),
          const SizedBox(width: 12),
          _dropdown(
              'Status',
              _statusFilter,
              ['Semua', 'active', 'suspended', 'banned'],
              (v) => setState(() {
                    _statusFilter = v!;
                    _page = 0;
                  })),
        ],
      );

  Widget _dropdown(String label, String value, List<String> items,
          ValueChanged<String?> onChanged) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8E3)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            items: items
                .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e[0].toUpperCase() + e.substring(1),
                        style: const TextStyle(fontSize: 13))))
                .toList(),
          ),
        ),
      );

  Widget _tableHeader() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          color: Color(0xFFF8FAFC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: const Row(
          children: [
            Expanded(flex: 3, child: _H('PENGGUNA')),
            Expanded(flex: 2, child: _H('ROLE')),
            Expanded(flex: 2, child: _H('STATUS')),
            Expanded(flex: 2, child: _H('ORDER / SPENT')),
            Expanded(flex: 2, child: _H('AKSI')),
          ],
        ),
      );

  Widget _userRow(AdminUser u) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Text(u.name[0].toUpperCase(),
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u.name,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      Text(u.email,
                          style: const TextStyle(
                              color: AppColors.mutedText, fontSize: 12)),
                    ],
                  ),
                ),
              ]),
            ),
            Expanded(flex: 2, child: _RoleBadge(role: u.role)),
            Expanded(flex: 2, child: _StatusBadge(status: u.status)),
            Expanded(
              flex: 2,
              child: Text(
                  '${u.totalOrders} • Rp ${NumberFormat('#,###', 'id_ID').format(u.totalSpent)}',
                  style: const TextStyle(fontSize: 12)),
            ),
            Expanded(
              flex: 2,
              child: Row(children: [
                _iconBtn(Icons.visibility_rounded, Colors.blue, () {
                  _showUserDetail(u);
                }),
                _iconBtn(Icons.edit_rounded, AppColors.secondary, () {
                  _showUserForm(user: u);
                }),
                _iconBtn(
                  u.status == UserStatus.active
                      ? Icons.block_rounded
                      : Icons.check_circle_rounded,
                  u.status == UserStatus.active
                      ? Colors.orange
                      : AppColors.primary,
                  () {
                    context.read<AdminProvider>().toggleUserStatus(u.id);
                  },
                ),
                _iconBtn(Icons.delete_rounded, AppColors.danger, () async {
                  final ok = await ConfirmDialog.show(
                    context,
                    title: 'Hapus Pengguna?',
                    message:
                        '${u.name} akan dihapus permanen. Tindakan ini tidak bisa dibatalkan.',
                    confirmLabel: 'Hapus',
                    danger: true,
                  );
                  if (ok && context.mounted) {
                    context.read<AdminProvider>().deleteUser(u.id);
                  }
                }),
              ]),
            ),
          ],
        ),
      );

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) => IconButton(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: color),
        tooltip: icon.codePoint.toString(),
        style: IconButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

  void _showUserDetail(AdminUser u) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title:
            Text(u.name, style: const TextStyle(fontWeight: FontWeight.w900)),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detail('ID', u.id),
              _detail('Email', u.email),
              _detail('Telepon', u.phone),
              _detail('Role', u.role.name),
              _detail('Status', u.status.name),
              _detail(
                  'Bergabung', DateFormat('dd MMM yyyy').format(u.joinedAt)),
              _detail(
                  'Terakhir Login',
                  u.lastLogin == null
                      ? '-'
                      : DateFormat('dd MMM yyyy, HH:mm').format(u.lastLogin!)),
              _detail('Total Order', '${u.totalOrders}'),
              _detail('Total Spent',
                  'Rp ${NumberFormat('#,###', 'id_ID').format(u.totalSpent)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup')),
        ],
      ),
    );
  }

  Widget _detail(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 120,
              child: Text(label,
                  style: const TextStyle(
                      color: AppColors.mutedText, fontSize: 13))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w700))),
        ]),
      );

  Future<void> _showUserForm({AdminUser? user}) async {
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final emailCtrl = TextEditingController(text: user?.email ?? '');
    final phoneCtrl = TextEditingController(text: user?.phone ?? '');
    var role = user?.role ?? UserRole.customer;
    var status = user?.status ?? UserStatus.active;
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(user == null ? 'Tambah Pengguna' : 'Edit Pengguna',
              style: const TextStyle(fontWeight: FontWeight.w900)),
          content: SizedBox(
            width: 440,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Nama Lengkap',
                          border: OutlineInputBorder()),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Email', border: OutlineInputBorder()),
                      validator: (v) => v == null || !v.contains('@')
                          ? 'Email tidak valid'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: phoneCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Telepon', border: OutlineInputBorder()),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<UserRole>(
                      initialValue: role,
                      decoration: const InputDecoration(
                          labelText: 'Role', border: OutlineInputBorder()),
                      items: UserRole.values
                          .map((e) =>
                              DropdownMenuItem(value: e, child: Text(e.name)))
                          .toList(),
                      onChanged: (v) => setSt(() => role = v!),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<UserStatus>(
                        initialValue: status,
                        decoration: const InputDecoration(
                            labelText: 'Status', border: OutlineInputBorder()),
                        items: UserStatus.values
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e.name)))
                            .toList(),
                        onChanged: (v) => setSt(() => status = v!)),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal')),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final p = context.read<AdminProvider>();
                if (user == null) {
                  p.addUser(AdminUser(
                    id: 'U${DateTime.now().millisecondsSinceEpoch}',
                    name: nameCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    role: role,
                    status: status,
                    joinedAt: DateTime.now(),
                  ));
                } else {
                  user.name = nameCtrl.text.trim();
                  user.email = emailCtrl.text.trim();
                  user.phone = phoneCtrl.text.trim();
                  user.role = role;
                  user.status = status;
                  p.updateUser(user);
                }
                Navigator.pop(ctx);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pagination(int totalPages) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE2E8E3))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: _page > 0 ? () => setState(() => _page--) : null,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Text('Halaman ${_page + 1} dari $totalPages',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            IconButton(
              onPressed:
                  _page < totalPages - 1 ? () => setState(() => _page++) : null,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      );
}

class _H extends StatelessWidget {
  const _H(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: Color(0xFF667085),
          letterSpacing: 0.6));
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});
  final UserRole role;
  @override
  Widget build(BuildContext context) {
    final map = {
      UserRole.admin: (Colors.purple, 'Admin'),
      UserRole.superAdmin: (Colors.red, 'Super Admin'),
      UserRole.storeOwner: (Colors.blue, 'Store Owner'),
      UserRole.customer: (Colors.teal, 'Customer'),
    };
    final data = map[role]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: data.$1.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(data.$2,
          style: TextStyle(
              color: data.$1, fontWeight: FontWeight.w800, fontSize: 11)),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final UserStatus status;
  @override
  Widget build(BuildContext context) {
    final map = {
      UserStatus.active: (AppColors.primary, 'Aktif'),
      UserStatus.suspended: (Colors.orange, 'Suspended'),
      UserStatus.banned: (AppColors.danger, 'Banned'),
    };
    final data = map[status]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: data.$1.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: data.$1, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(data.$2,
            style: TextStyle(
                color: data.$1, fontWeight: FontWeight.w800, fontSize: 11)),
      ]),
    );
  }
}
