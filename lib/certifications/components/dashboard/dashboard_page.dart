import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'toolbar/toolbar.dart';
import 'search_filters/search_filters.dart';
import 'new_certi_cars/new_certi_cars.dart';
import 'create_certificate/create_certificate.dart';
import 'brand_search/brand_search.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    _guardAuth();
  }

  Future<void> _guardAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token == null && mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: const [
          Toolbar(),
          SizedBox(height: 12),
          Padding(padding: EdgeInsets.all(12), child: SearchFilters()),
          SizedBox(height: 12),
          Padding(padding: EdgeInsets.all(12), child: NewCertiCars()),
          SizedBox(height: 12),
          Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: CreateCertificateBanner()),
          SizedBox(height: 12),
          Padding(padding: EdgeInsets.all(12), child: BrandSearch()),
        ],
      ),
    );
  }
}