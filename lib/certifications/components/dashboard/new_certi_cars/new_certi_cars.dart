import 'package:flutter/material.dart';

class NewCertiCars extends StatefulWidget {
  const NewCertiCars({super.key});
  @override
  State<NewCertiCars> createState() => _S();
}

class _S extends State<NewCertiCars> {
  final List<Map<String, String>> _cars = [
    {
      'id': '1',
      'name': 'BMW Serie 4',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSYVcLx4pGvnOpKwlHUU49s8jkRkJDGVxaiDw&s',
      'price': 'S/4,399.00',
      'route': '/car-detail/4'
    },
    {
      'id': '2',
      'name': 'Ford Mustang GT',
      'image': 'https://www.vdm.ford.com/content/dam/na/ford/en_us/images/mustang/2025/jellybeans/Ford_Mustang_2025_200A_PJS_883_89W_13B_COU_64F_99H_44U_EBST_YZTAC_DEFAULT_EXT_4.png',
      'price': 'S/4,599.00',
      'route': '/car-detail/5'
    },
    {
      'id': '3',
      'name': 'Kia Niro',
      'image': 'https://cdn.motor1.com/images/mgl/ojyBzq/s3/kia-niro-2025.jpg',
      'price': 'S/3,900.00',
      'route': '/car-detail/2'
    },
    {
      'id': '4',
      'name': 'Kia Sportage',
      'image': 'https://s3.amazonaws.com/kia-greccomotors/Sportage_blanca_01_9a1ad740c7.png',
      'price': 'S/3,299.00',
      'route': '/car-detail/3'
    },
  ];

  final PageController _pc = PageController(viewportFraction: 0.8);

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pc,
            itemCount: _cars.length,
            itemBuilder: (c, i) {
              final car = _cars[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, car['route']!);
                  },
                  child: Card(
                    child: Column(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.network(car['image']!, fit: BoxFit.cover),
                              ),
                              Positioned(
                                bottom: 8,
                                left: 8,
                                right: 8,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      car['price']!,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                    ),
                                    Row(
                                      children: const [
                                        Icon(Icons.search, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text('Ver detalles', style: TextStyle(color: Colors.white)),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(car['name']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              const Text('Color', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            left: 0,
            top: 120,
            child: IconButton(
              onPressed: () {
                _pc.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
              },
              icon: const Icon(Icons.chevron_left),
            ),
          ),
          Positioned(
            right: 0,
            top: 120,
            child: IconButton(
              onPressed: () {
                _pc.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
              },
              icon: const Icon(Icons.chevron_right),
            ),
          ),
        ],
      ),
    );
  }
}