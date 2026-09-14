import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
    final isCompact = MediaQuery.sizeOf(context).width < 900;

    return ChangeNotifierProvider(
      create: (_) => AdminProvider(),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF1F5F9),
        drawer: isCompact
            ? AdminSidebar(
                selectedIndex: _selectedIndex,
                forceExpanded: true,
                onSelect: (i) {
                  setState(() => _selectedIndex = i);
                  Navigator.of(context).pop();
                },
              )
            : null,
        body: Row(
          children: [
            if (!isCompact)
              AdminSidebar(
                selectedIndex: _selectedIndex,
                onSelect: (i) => setState(() => _selectedIndex = i),
              ),
            Expanded(
              child: Column(
                children: [
                  AdminTopbar(
                    title: _titles[_selectedIndex],
                    onMenu: isCompact
                        ? () => _scaffoldKey.currentState?.openDrawer()
                        : null,
                  ),
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
