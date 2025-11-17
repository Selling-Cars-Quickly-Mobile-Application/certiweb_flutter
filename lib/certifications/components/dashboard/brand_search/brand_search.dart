import 'package:flutter/material.dart';

class BrandSearch extends StatefulWidget {
  const BrandSearch({super.key});

  @override
  State<BrandSearch> createState() => _BrandSearchState();
}

class _BrandSearchState extends State<BrandSearch> {
  int? _hoveredBrand;

  final List<Map<String, String>> _brands = [
    {
      'name': 'Audi',
      'logo': 'https://upload.wikimedia.org/wikipedia/commons/9/92/Audi-Logo_2016.svg',
      'route': '/cars?brand=Audi',
      'color': '#BB0A30',
    },
    {
      'name': 'Mercedes-Benz',
      'logo': 'https://www.pngarts.com/files/3/Mercedes-Benz-Logo-PNG-Photo.png',
      'route': '/cars?brand=Mercedes-Benz',
      'color': '#00ADEF',
    },
    {
      'name': 'BMW',
      'logo': 'https://upload.wikimedia.org/wikipedia/commons/4/44/BMW.svg',
      'route': '/cars?brand=BMW',
      'color': '#0066B2',
    },
    {
      'name': 'Volkswagen',
      'logo': 'https://cdn.worldvectorlogo.com/logos/volkswagen-10.svg',
      'route': '/cars?brand=Volkswagen',
      'color': '#001E50',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 640;
    
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: isMobile ? 32 : 64,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              Text(
                'Explora nuestras marcas',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1e293b),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Descubre vehículos certificados de las mejores marcas del mercado',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF64748b),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
          const SizedBox(height: 48),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 1 : (MediaQuery.of(context).size.width < 1024 ? 2 : 4),
              childAspectRatio: 1,
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
            ),
            itemCount: _brands.length,
            itemBuilder: (context, i) {
              final brand = _brands[i];
              final isHovered = _hoveredBrand == i;
              
              return MouseRegion(
                onEnter: (_) => setState(() => _hoveredBrand = i),
                onExit: (_) => setState(() => _hoveredBrand = null),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/cars',
                      arguments: {'brand': brand['name']},
                    );
                  },
                  child: Card(
                    elevation: isHovered ? 12 : 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white.withOpacity(0.8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 128,
                            height: 128,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isHovered
                                    ? [
                                        Colors.grey.shade100.withOpacity(0.3),
                                        Colors.grey.shade200.withOpacity(0.3),
                                      ]
                                    : [
                                        Colors.grey.shade100,
                                        Colors.grey.shade200,
                                      ],
                              ),
                            ),
                            child: Center(
                              child: Image.network(
                                brand['logo']!,
                                height: 80,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.directions_car, size: 60),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            brand['name']!,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isHovered
                                  ? Color(int.parse(brand['color']!.replaceFirst('#', '0xff')))
                                  : const Color(0xFF1e293b),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search,
                                size: 16,
                                color: const Color(0xFF64748b),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Ver vehículos',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: const Color(0xFF64748b),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: isHovered ? 40 : 0,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Color(int.parse(brand['color']!.replaceFirst('#', '0xff'))),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 48),
          OutlinedButton.icon(
            onPressed: () {
              Scrollable.ensureVisible(
                context,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            icon: const Icon(Icons.arrow_upward),
            label: const Text('Volver al inicio'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              side: const BorderSide(color: Color(0xFFe2e8f0), width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}