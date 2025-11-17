import 'package:flutter/material.dart';
import 'toolbar/toolbar.dart';
import 'search_filters/search_filters.dart';
import 'new_certi_cars/new_certi_cars.dart';
import 'create_certificate/create_certificate.dart';
import 'brand_search/brand_search.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
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