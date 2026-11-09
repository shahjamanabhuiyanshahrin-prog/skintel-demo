import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';
import '../services/market_service.dart';
import 'cart_screen.dart';
import 'product_image.dart';

class ProductsScreen extends StatefulWidget {
  final String? skinType; // "Dry" / "Oily" / null = all
  final String? category; // e.g. "beard care men" (price search mode)
  final String? title;
  final Widget? header; // e.g. scan result card
  const ProductsScreen(
      {super.key, this.skinType, this.category, this.title, this.header});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _ctrl = TextEditingController();

  // 'local' / 'imported' = marketplace (Supabase)
  // 'prices' = old price search (SerpAPI), only used with a category
  late String _mode;

  // prices mode
  late Future<List<Map<String, String>>> _future;
  String _sort = 'asc';

  // marketplace mode
  late Future<List<Product>> _marketFuture;
  String _mSort = 'none'; // 'none', 'asc', 'desc'
  String _mCategory = 'All';

  // chosen skin type (null = all skin types)
  String? _skin;

  static const List<String> _skinTypes = [
    'Dry',
    'Oily',
    'Combination',
    'Normal'
  ];

  @override
  void initState() {
    super.initState();
    _skin = (widget.skinType == null || widget.skinType!.isEmpty)
        ? null
        : widget.skinType;
    _mode = widget.category != null ? 'prices' : 'local';
    _load();
    _loadMarket();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _load() {
    _future = ApiService().getProducts(
        skinType: widget.skinType,
        category: widget.category,
        query: _ctrl.text,
        sort: _sort);
  }

  void _loadMarket() {
    _marketFuture = MarketService.getProducts();
  }

  // 0 = made for this skin type, 1 = suits all skin types
  int _matchRank(Product p) {
    final s = _skin;
    if (s == null || s.isEmpty) return 0;
    final t = s.toLowerCase();
    return p.skinTypes.any((e) => e.toLowerCase() == t) ? 0 : 1;
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.skinType;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? (t == null ? 'Products' : 'For $t skin'),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
        actions: [
          ListenableBuilder(
            listenable: CartService.instance,
            builder: (context, _) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CartScreen())),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                      color: Color(0xFFEDEDED), shape: BoxShape.circle),
                  child: Badge(
                    isLabelVisible: CartService.instance.count > 0,
                    label: Text('${CartService.instance.count}'),
                    child: const Icon(Icons.shopping_bag_outlined, size: 20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(children: [
        if (widget.header != null) widget.header!,
        if (widget.category == null) _modeBar(),
        if (_mode != 'prices') _skinBar(),
        if (_mode == 'prices')
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
        if (_mode != 'prices') _marketList(),
        if (_mode == 'prices') _pricesList(),
      ]),
    );
  }

  // ---------------- tabs ----------------

  Widget _modeBar() {
    Widget tab(String label, String value) {
      final selected = _mode == value;
      return Padding(
        padding: const EdgeInsets.only(right: 20),
        child: InkWell(
          onTap: () => setState(() {
            _mode = value;
            _mCategory = 'All';
            if (value == 'prices') {
              _load();
            } else {
              _loadMarket();
            }
          }),
          child: Column(children: [
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                    color: selected ? Colors.black : Colors.black45)),
            const SizedBox(height: 4),
            Container(
                height: 2,
                width: 28,
                color: selected ? Colors.black : Colors.transparent),
          ]),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          tab('Local', 'local'),
          tab('Imported', 'imported'),
          tab('More (prices)', 'prices'),
        ]),
      ),
    );
  }

  // skin type row
  Widget _skinBar() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
        children: [
          _pill('All skin types', _skin == null,
              () => setState(() => _skin = null)),
          for (final s in _skinTypes)
            _pill(s, _skin == s, () => setState(() {
                  _skin = s;
                  _mCategory = 'All';
                })),
        ],
      ),
    );
  }

  Widget _pill(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: selected ? Colors.white : Colors.black)),
        ),
      ),
    );
  }

  // ---------------- marketplace ----------------

  Widget _marketList() {
    return FutureBuilder<List<Product>>(
      future: _marketFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          return Padding(
            padding: const EdgeInsets.all(30),
            child: Center(
              child: Column(children: [
                TextButton(
                  onPressed: () => setState(_loadMarket),
                  child: const Text('Could not load products. Tap to retry'),
                ),
                const SizedBox(height: 8),
                Text('${snap.error}',
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(fontSize: 10, color: Colors.black45)),
              ]),
            ),
          );
        }

        // tab + skin type filter
        final all = (snap.data ?? [])
            .where((p) => _mode == 'local' ? p.isLocal : !p.isLocal)
            .where((p) => p.suits(_skin))
            .toList();

        if (all.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: Text('No products found.')),
          );
        }

        final cats = <String>{};
        for (final p in all) {
          cats.add(p.category);
        }
        final catList = ['All', ...(cats.toList()..sort())];
        final cat = catList.contains(_mCategory) ? _mCategory : 'All';

        var items = cat == 'All'
            ? List<Product>.from(all)
            : all.where((p) => p.category == cat).toList();

        if (_mSort != 'none') {
          // products without an available offer go to the end
          items.sort((a, b) {
            final pa = a.minPrice;
            final pb = b.minPrice;
            if (pa == null && pb == null) return a.name.compareTo(b.name);
            if (pa == null) return 1;
            if (pb == null) return -1;
            final c = _mSort == 'asc' ? pa.compareTo(pb) : pb.compareTo(pa);
            return c != 0 ? c : a.name.compareTo(b.name);
          });
        } else {
          // 1) made for this skin type first
          // 2) imported: Korean, American, Japanese first
          // 3) then by name
          items.sort((a, b) {
            var c = _matchRank(a).compareTo(_matchRank(b));
            if (c != 0) return c;
            if (_mode == 'imported') {
              c = a.originRank.compareTo(b.originRank);
              if (c != 0) return c;
            }
            return a.name.compareTo(b.name);
          });
        }

        final width = MediaQuery.of(context).size.width;
        final cols = width >= 1000 ? 6 : (width >= 700 ? 4 : 3);

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
              children: [
                for (final c in catList)
                  _pill(c, c == cat, () => setState(() => _mCategory = c)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Row(children: [
              const Text('Price: ', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 6),
              _mSortChip('Low to high', 'asc'),
              const SizedBox(width: 8),
              _mSortChip('High to low', 'desc'),
            ]),
          ),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: Text('No products in this category.')),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.56),
              itemCount: items.length,
              itemBuilder: (_, i) => _gridCard(items[i]),
            ),
        ]);
      },
    );
  }

  Widget _mSortChip(String label, String value) {
    final selected = _mSort == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: Colors.black,
      backgroundColor: const Color(0xFFF5EFEC),
      showCheckmark: false,
      labelStyle: TextStyle(
          fontSize: 11, color: selected ? Colors.white : Colors.black),
      onSelected: (_) => setState(() => _mSort = selected ? 'none' : value),
    );
  }

  void _addOffer(Product p, Offer o) {
    CartService.instance.add(
      offerId: o.id,
      sellerName: o.sellerName,
      name: p.name,
      brand: p.brand,
      image: p.image,
      price: o.price,
    );
    _toast('Added to cart');
  }

  String _priceText(Product p) {
    if (p.cheapest != null) return 'From ${tk(p.cheapest!.price)}';
    if (p.hasOffers) return 'Out of stock';
    return 'No seller yet';
  }

  Widget _gridCard(Product p) {
    final canBuy = p.cheapest != null;
    return Opacity(
      opacity: canBuy ? 1 : 0.55,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _details(p),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: double.infinity,
                child: ProductImage(
                  image: p.image,
                  name: p.name,
                  brand: p.brand,
                  category: p.category,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(p.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(p.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: Colors.black45)),
          const Spacer(),
          Row(children: [
            Expanded(
              child: Text(_priceText(p),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w800)),
            ),
            if (canBuy)
              InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _addOffer(p, p.cheapest!),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                      color: Color(0xFFEDEDED), shape: BoxShape.circle),
                  child: const Icon(Icons.add_shopping_cart, size: 14),
                ),
              ),
          ]),
        ]),
      ),
    );
  }

  // Tap a card: details + every seller's offer
  void _details(Product p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 96,
                      height: 96,
                      child: ProductImage(
                        image: p.image,
                        name: p.name,
                        brand: p.brand,
                        category: p.category,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${p.origin} · ${p.category}',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.black54)),
                          const SizedBox(height: 4),
                          Text(p.name,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text(p.brand, style: const TextStyle(fontSize: 12)),
                          const SizedBox(height: 6),
                          Text(_priceText(p),
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w800)),
                        ]),
                  ),
                ]),
                if (p.description.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(p.description, style: const TextStyle(fontSize: 13)),
                ],
                const SizedBox(height: 16),
                const Text('Sellers',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                if (p.offers.isEmpty)
                  const Text('No seller has listed this product yet.',
                      style: TextStyle(fontSize: 12, color: Colors.black54))
                else
                  for (final o in p.offers)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF5EFEC),
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(o.sellerName,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text(
                                    o.available
                                        ? '${tk(o.price)} · ${o.stock} in stock'
                                        : '${tk(o.price)} · Out of stock',
                                    style: const TextStyle(fontSize: 12)),
                              ]),
                        ),
                        ElevatedButton(
                          onPressed: o.available
                              ? () {
                                  _addOffer(p, o);
                                  Navigator.pop(sheetContext);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20))),
                          child: const Text('Add'),
                        ),
                      ]),
                    ),
              ]),
        ),
      ),
    );
  }

  // ---------------- prices mode (SerpAPI, old) ----------------

  Widget _pricesList() {
    return FutureBuilder<List<Map<String, String>>>(
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
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(text), duration: const Duration(seconds: 1)));
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
                child: (p['image'] ?? '').isEmpty
                    ? icon
                    : Image.network(p['image']!,
                        fit: BoxFit.cover,
                        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                        errorBuilder: (_, __, ___) => icon),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(p['name'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          if ((p['price'] ?? '').isNotEmpty)
            Text(p['price']!,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
          if ((p['brand'] ?? '').isNotEmpty)
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
      ),
    );
  }
}