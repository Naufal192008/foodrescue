import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../utils/app_colors.dart';
import '../providers/admin_provider.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});
  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  final _searchCtrl = TextEditingController();
  String _filter = 'Semua';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logs = context.watch<AdminProvider>().logs;
    final q = _searchCtrl.text.toLowerCase();
    final list = logs.where((l) {
      final mQ = l.action.toLowerCase().contains(q) ||
          l.target.toLowerCase().contains(q) ||
          l.adminName.toLowerCase().contains(q);
      final mF = _filter == 'Semua' || l.action.contains(_filter);
      return mQ && mF;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Audit Logs',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text('Rekam jejak semua aktivitas admin',
              style: TextStyle(color: AppColors.mutedText)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Cari log...',
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8E3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _filter,
                  onChanged: (v) => setState(() => _filter = v!),
                  items: ['Semua', 'CREATE', 'UPDATE', 'DELETE', 'VERIFY', 'LOGIN', 'TOGGLE']
                      .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e, style: const TextStyle(fontSize: 13))))
                      .toList(),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8E3)),
              ),
              child: list.isEmpty
                  ? const Center(child: Text('Tidak ada log'))
                  : ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final l = list[i];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          leading: _icon(l.action),
                          title: Row(children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _color(l.action).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(l.action,
                                  style: TextStyle(
                                      color: _color(l.action),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                      letterSpacing: 0.5)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('${l.adminName} → ${l.target}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                            ),
                          ]),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(l.details ?? '-',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.mutedText)),
                          ),
                          trailing: Text(
                            DateFormat('dd MMM, HH:mm').format(l.timestamp),
                            style: const TextStyle(
                                color: AppColors.mutedText, fontSize: 12),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Icon _icon(String action) => Icon(
        _iconData(action),
        color: _color(action),
        size: 22,
      );

  IconData _iconData(String a) {
    if (a.contains('DELETE')) return Icons.delete_rounded;
    if (a.contains('CREATE')) return Icons.add_circle_rounded;
    if (a.contains('UPDATE')) return Icons.edit_rounded;
    if (a.contains('VERIFY')) return Icons.verified_rounded;
    if (a.contains('LOGIN')) return Icons.login_rounded;
    if (a.contains('TOGGLE')) return Icons.toggle_on_rounded;
    return Icons.info_rounded;
  }

  Color _color(String a) {
    if (a.contains('DELETE')) return AppColors.danger;
    if (a.contains('CREATE')) return Colors.blue;
    if (a.contains('UPDATE')) return AppColors.secondary;
    if (a.contains('VERIFY')) return AppColors.primary;
    if (a.contains('LOGIN')) return Colors.purple;
    return Colors.grey;
  }
}