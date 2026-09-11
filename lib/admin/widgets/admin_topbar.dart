import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class AdminTopbar extends StatelessWidget {
  const AdminTopbar({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8E3))),
      ),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.text)),
          const Spacer(),
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded, color: AppColors.mutedText)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded, color: AppColors.mutedText)),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              'https://ui-avatars.com/api/?name=Super+Admin&background=2E7D32&color=fff',
              width: 38, height: 38,
              errorBuilder: (_, __, ___) => Container(
                width: 38, height: 38, color: AppColors.primary,
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}