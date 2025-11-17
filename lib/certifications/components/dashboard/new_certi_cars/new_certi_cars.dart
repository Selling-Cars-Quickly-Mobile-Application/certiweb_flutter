import 'dart:async';
import 'package:flutter/material.dart';

class NewCertiCars extends StatefulWidget {
  const NewCertiCars({super.key});

  @override
  State<NewCertiCars> createState() => _NewCertiCarsState();
}

class _NewCertiCarsState extends State<NewCertiCars> {
  final List<Map<String, String>> _cars = [
    {
      'id': '1',
      'name': 'BMW Serie 4',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSYVcLx4pGvnOpKwlHUU49s8jkRkJDGVxaiDw&s',
      'price': 'S/4,399.00',
      'color': 'Azul Metálico',
      'route': '/car-detail/4'
    },
    {
      'id': '2',
      'name': 'Ford Mustang GT',
      'image': 'https://www.vdm.ford.com/content/dam/na/ford/en_us/images/mustang/2025/jellybeans/Ford_Mustang_2025_200A_PJS_883_89W_13B_COU_64F_99H_44U_EBST_YZTAC_DEFAULT_EXT_4.png',
      'price': 'S/4,599.00',
      'color': 'Gris',
      'route': '/car-detail/5'
    },
    {
      'id': '3',
      'name': 'Kia Niro',
      'image': 'https://cdn.motor1.com/images/mgl/ojyBzq/s3/kia-niro-2025.jpg',
      'price': 'S/3,900.00',
      'color': 'Rojo',
      'route': '/car-detail/2'
    },
    {
      'id': '4',
      'name': 'Kia Sportage',
      'image': 'https://s3.amazonaws.com/kia-greccomotors/Sportage_blanca_01_9a1ad740c7.png',
      'price': 'S/3,299.00',
      'color': 'Blanco Perla',
      'route': '/car-detail/3'
    },
  ];

  late PageController _pageController;
  int _currentIndex = 0;
  late Timer _autoplayTimer;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _startAutoplay();
  }

  void _startAutoplay() {
    _autoplayTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_isHovering && _currentIndex < _cars.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoplayTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F0E1),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vehículos certificados',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1b4332),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Descubre nuestra selección de vehículos certificados y de confianza',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF495057),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          MouseRegion(
            onEnter: (_) => setState(() => _isHovering = true),
            onExit: (_) => setState(() => _isHovering = false),
            child: Stack(
              children: [
                SizedBox(
                  height: 280,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    itemCount: _cars.length,
                    itemBuilder: (context, index) {
                      final car = _cars[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, car['route']!);
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                        child: Image.network(
                                          car['image']!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withOpacity(0.6),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 12,
                                        left: 12,
                                        right: 12,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              car['price']!,
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                const Icon(Icons.search, color: Colors.white, size: 18),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Ver detalles',
                                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        car['name']!,
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF212529),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        car['color']!,
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: const Color(0xFF6c757d),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  left: 8,
                  top: 115,
                  child: IconButton(
                    onPressed: () {
                      if (_currentIndex > 0) {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    icon: const Icon(Icons.chevron_left, size: 28),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 2,
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 115,
                  child: IconButton(
                    onPressed: () {
                      if (_currentIndex < _cars.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    icon: const Icon(Icons.chevron_right, size: 28),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/cars');
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ver más modelos',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1b4332),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 18, color: Color(0xFF1b4332)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}