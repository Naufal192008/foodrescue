import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class ImpactCard extends StatelessWidget {
  const ImpactCard({
    super.key,
    required this.portions,
    required this.moneySaved,
    required this.co2Saved,
  });

  final int portions;
  final int moneySaved;
  final double co2Saved;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.eco_rounded, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                'Dampak Lingkungan Pribadimu',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ImpactValue(
                icon: Icons.restaurant_rounded,
                value: '$portions',
                label: 'Porsi terselamatkan',
              ),
              _ImpactValue(
                icon: Icons.savings_rounded,
                value: '${moneySaved}rb',
                label: 'Uang hemat',
              ),
              _ImpactValue(
                icon: Icons.cloud_done_rounded,
                value: '${co2Saved}kg',
                label: 'CO2e dicegah',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImpactValue extends StatelessWidget {
  const _ImpactValue({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
