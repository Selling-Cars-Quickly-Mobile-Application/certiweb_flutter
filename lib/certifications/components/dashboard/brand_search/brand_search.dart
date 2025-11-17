import 'package:flutter/material.dart';

class BrandSearch extends StatelessWidget {
  const BrandSearch({super.key});
  @override
  Widget build(BuildContext context) {
    final brands = [
      {
        'name': 'Audi',
        'logo': 'https://upload.wikimedia.org/wikipedia/commons/9/92/Audi-Logo_2016.svg',
        'route': '/cars?brand=Audi',
      },
      {
        'name': 'Mercedes-Benz',
        'logo': 'https://www.pngarts.com/files/3/Mercedes-Benz-Logo-PNG-Photo.png',
        'route': '/cars?brand=Mercedes-Benz',
      },
      {
        'name': 'BMW',
        'logo': 'https://upload.wikimedia.org/wikipedia/commons/4/44/BMW.svg',
        'route': '/cars?brand=BMW',
      },
      {
        'name': 'Volkswagen',
        'logo': 'https://cdn.worldvectorlogo.com/logos/volkswagen-10.svg',
        'route': '/cars?brand=Volkswagen',
      },
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 1),
      itemCount: brands.length,
      itemBuilder: (c, i) {
        final b = brands[i];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/cars', arguments: {'brand': b['name']});
          },
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.grey.shade200,
                  child: Image.network(b['logo']!, height: 48),
                ),
                const SizedBox(height: 8),
                Text(b['name']!, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      },
    );
  }
}