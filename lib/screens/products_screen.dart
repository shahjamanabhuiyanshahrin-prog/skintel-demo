import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
  String _sort = 'asc'; // 'asc' = low to high, 'desc' = high to low

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = ApiService().getProducts(
        skinType: widget.skinType,
        category: widget.category,
        query: _ctrl.text,
        sort: _sort);
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
      // One scrolling list: everything (result card, search, price buttons and
      // products) moves together when you scroll.
      body: ListView(children: [
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
        FutureBuilder<List<Map<String, String>>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final items = snap.data ?? [];
            final hasPrices = items.any((p) => (p['price'] ?? '').isNotEmpty);
            if (items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: TextButton(
                    onPressed: () => setState(_load),
                    child: const Text('No products found. Tap to retry'),
                  ),
                ),
              );
            }
            return Column(children: [
              if (hasPrices)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Row(children: [
                    const Text('Price: ', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 6),
                    _sortChip('Low to high', 'asc'),
                    const SizedBox(width: 8),
                    _sortChip('High to low', 'desc'),
                  ]),
                ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.78),
                itemCount: items.length,
                itemBuilder: (_, i) => _card(items[i]),
              ),
            ]);
          },
        ),
      ]),
    );
  }

  Widget _sortChip(String label, String value) {
    final selected = _sort == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: Colors.black,
      backgroundColor: const Color(0xFFF5EFEC),
      showCheckmark: false,
      labelStyle: TextStyle(
        fontSize: 11,
        color: selected ? Colors.white : Colors.black,
      ),
      onSelected: (_) => setState(() {
        _sort = value;
        _load();
      }),
    );
  }

  // Opens the product page of the store in the browser.
  Future<void> _open(String? link) async {
    final uri = Uri.tryParse(link ?? '');
    final ok = uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    if (!ok) {
      _toast('No web page for this product.');
      return;
    }
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) _toast('Could not open the page.');
    } catch (_) {
      _toast('Could not open the page.');
    }
  }

  void _toast(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Widget _card(Map<String, String> p) {
    final icon = Container(
        color: const Color(0xFFE8C4B4),
        child: const Center(
            child: Icon(Icons.spa, size: 40, color: Colors.white)));
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _open(p['link']),
      child: Container(
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
                      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                      errorBuilder: (_, __, ___) => icon),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(p['name']!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        if ((p['price'] ?? '').isNotEmpty)
          Text(p['price']!,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        if (p['brand']!.isNotEmpty)
          Text(p['brand']!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10)),
        const SizedBox(height: 4),
        const Row(children: [
          Icon(Icons.open_in_new, size: 12),
          SizedBox(width: 4),
          Text('View product', style: TextStyle(fontSize: 10)),
        ]),
      ]),
    ));
  }
}