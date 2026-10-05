import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProductsScreen extends StatefulWidget {
  final String? skinType; // "Dry" / "Oily" / null = shob
  final String? category; // e.g. "beard care men"
  final String? title;
  final Widget? header; // e.g. scan result card
  const ProductsScreen(
      {super.key, this.skinType, this.category, this.title, this.header});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _ctrl = TextEditingController();
  late Future<List<Map<String, String>>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = ApiService().getProducts(
        skinType: widget.skinType,
        category: widget.category,
        query: _ctrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.skinType;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? (t == null ? 'Products' : 'For $t skin')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(children: [
        if (widget.header != null) widget.header!,
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            controller: _ctrl,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => setState(_load),
            decoration: InputDecoration(
              hintText: 'Search brand (e.g. Nivea, Cetaphil)',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: const Color(0xFFF5EFEC),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, String>>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = snap.data ?? [];
              if (items.isEmpty) {
                return Center(
                  child: TextButton(
                    onPressed: () => setState(_load),
                    child: const Text('No products found. Tap to retry'),
                  ),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.78),
                itemCount: items.length,
                itemBuilder: (_, i) => _card(items[i]),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _card(Map<String, String> p) {
    final icon = Container(
        color: const Color(0xFFE8C4B4),
        child: const Center(
            child: Icon(Icons.spa, size: 40, color: Colors.white)));
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: const Color(0xFFF5EFEC),
          borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: double.infinity,
              child: p['image']!.isEmpty
                  ? icon
                  : Image.network(p['image']!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => icon),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(p['name']!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        if (p['brand']!.isNotEmpty)
          Text(p['brand']!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10)),
      ]),
    );
  }
}
