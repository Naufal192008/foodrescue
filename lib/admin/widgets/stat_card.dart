import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key, required this.title, required this.value,
    required this.icon, required this.color, this.change, this.subtitle,
  });
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? change;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8E3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const Spacer(),
              if (change != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: change!.startsWith('+') ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(change!, style: TextStyle(
                    color: change!.startsWith('+') ? Colors.green.shade800 : Colors.red.shade800,
                    fontWeight: FontWeight.w800, fontSize: 11,
                  )),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Color(0xFF667085), fontWeight: FontWeight.w600, fontSize: 13)),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle!, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
          ],
        ],
      ),
    );
  }
}