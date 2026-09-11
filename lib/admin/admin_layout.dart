import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/app_colors.dart';
import 'pages/analytics_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/logs_page.dart';
import 'pages/orders_page.dart';
import 'pages/products_page.dart';
import 'pages/reports_page.dart';
import 'pages/settings_page.dart';
import 'pages/stores_page.dart';
import 'pages/users_page.dart';
import 'providers/admin_provider.dart';
import 'widgets/admin_sidebar.dart';
import 'widgets/admin_topbar.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int _selectedIndex = 0;

  final _pages = const [
    DashboardPage(),
    UsersPage(),
    StoresPage(),
    ProductsPage(),
    OrdersPage(),
    AnalyticsPage(),
    ReportsPage(),
    LogsPage(),
    SettingsPage(),
  ];

  final _titles = const [
    'Dashboard',
    'Kelola Pengguna',
    'Kelola Toko',
    'Kelola Produk',
    'Kelola Pesanan',
    'Analytics',
    'Laporan & Export',
    'Audit Logs',
    'Pengaturan',
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminProvider(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        body: Row(
          children: [
            AdminSidebar(
              selectedIndex: _selectedIndex,
              onSelect: (i) => setState(() => _selectedIndex = i),
            ),
            Expanded(
              child: Column(
                children: [
                  AdminTopbar(title: _titles[_selectedIndex]),
                  Expanded(
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: _pages,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}