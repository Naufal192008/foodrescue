import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key, required this.title, required this.message,
    this.confirmLabel = 'Konfirmasi', this.danger = false,
  });
  final String title;
  final String message;
  final String confirmLabel;
  final bool danger;

  static Future<bool> show(BuildContext context, {
    required String title, required String message,
    String confirmLabel = 'Konfirmasi', bool danger = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: title, message: message,
        confirmLabel: confirmLabel, danger: danger,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(children: [
          Icon(danger ? Icons.warning_amber_rounded : Icons.help_outline_rounded,
              color: danger ? AppColors.danger : AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800))),
        ]),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: danger ? AppColors.danger : AppColors.primary),
            child: Text(confirmLabel),
          ),
        ],
      );
}