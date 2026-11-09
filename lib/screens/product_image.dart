import 'package:flutter/material.dart';

// Backend address (Python server)
const String kBackendUrl = 'http://localhost:5000';

class ProductImage extends StatelessWidget {
  final String image;
  final String category;
  final String brand;
  final String name;
  final BoxFit fit;

  const ProductImage({
    super.key,
    this.image = '',
    this.category = '',
    this.brand = '',
    this.name = '',
    this.fit = BoxFit.cover,
  });

  String get _url {
    if (image.startsWith('http')) return image;
    final q = name.isNotEmpty ? name : category;
    return '$kBackendUrl/product_image'
        '?name=${Uri.encodeQueryComponent(q)}'
        '&brand=${Uri.encodeQueryComponent(brand)}';
  }

  IconData get _icon {
    final c = category.toLowerCase();
    if (c.contains('clean') || c.contains('wash')) return Icons.water_drop;
    if (c.contains('moist')) return Icons.spa;
    if (c.contains('sun')) return Icons.wb_sunny;
    if (c.contains('serum')) return Icons.science;
    return Icons.spa;
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_icon, size: 36, color: const Color(0xFF8E24AA)),
          if (brand.isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                brand,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6A1B9A),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Image.network(
      _url,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _placeholder();
      },
      errorBuilder: (context, error, stack) => _placeholder(),
    );
  }
}