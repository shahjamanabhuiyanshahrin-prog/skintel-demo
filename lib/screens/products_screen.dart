import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';
import '../services/market_service.dart';
import 'cart_screen.dart';
import 'seller_screen.dart';

class ProductsScreen extends StatefulWidget {
  final String? skinType;
  final String? category;
  final String? title;
  final Widget? header;

  const ProductsScreen({
    super.key,
    this.skinType,
    this.category,
    this.title,
    this.header,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _ctrl = TextEditingController();

  late Future<List<Map<String, String>>> _future;

  String _sort = 'asc';

  late String _mode;
  late Future<List<Product>> _recFuture;

  String _recSort = 'none';
  String _recCategory = 'All';
  String _skin = 'All skin types';

  // YOUR RENDER BACKEND
  static const String _backendUrl =
      'https://skintel-demo.onrender.com';

  static const _skins = [
    'All skin types',
    'Dry',
    'Oily',
    'Combination',
    'Normal'
  ];

  @override
  void initState() {
    super.initState();

    _mode = widget.category != null ? 'prices' : 'local';

    final s = widget.skinType;

    if (s != null && _skins.contains(s)) {
      _skin = s;
    }

    if (widget.category != null) {
      _load();
    } else {
      _loadRec();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // LOAD RECOMMENDED PRODUCTS
  void _loadRec() {
    _recFuture = MarketService.getProducts();
  }

  // LOAD PRICE PRODUCTS
  void _load() {
    _future = ApiService().getProducts(
      skinType: widget.skinType,
      category: widget.category,
      query: _ctrl.text,
      sort: _sort,
    );
  }

  // FIXED PRODUCT IMAGE URL
  String _productImageUrl(String image, String name, String brand) {
    if (image.startsWith('https://') ||
        image.startsWith('http://')) {
      return image;
    }

    return Uri.parse('$_backendUrl/product_image').replace(
      queryParameters: {
        'name': name,
        'brand': brand,
      },
    ).toString();
  }

  // PRODUCT IMAGE WIDGET
  Widget _imageBox(Product p, double iconSize) {
    final placeholder = Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFE8C4B4),
            Color(0xFFD9A58F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.spa,
          size: iconSize,
          color: Colors.white,
        ),
      ),
    );

    final url = _productImageUrl(
      p.image,
      p.name,
      p.brand,
    );

    return Image.network(
      url,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.contain,
      webHtmlElementStrategy:
          WebHtmlElementStrategy.prefer,
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }

        return placeholder;
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('PRODUCT IMAGE ERROR: $url');
        debugPrint('$error');

        return placeholder;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.skinType;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title ??
              (t == null ? 'Products' : 'For $t skin'),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Sell on Skintel',
            icon: const Icon(Icons.storefront_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SellerScreen(),
                ),
              );
            },
          ),
          ListenableBuilder(
            listenable: CartService.instance,
            builder: (context, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CartScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEDEDED),
                      shape: BoxShape.circle,
                    ),
                    child: Badge(
                      isLabelVisible:
                          CartService.instance.count > 0,
                      label: Text(
                        '${CartService.instance.count}',
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          if (widget.header != null) widget.header!,

          if (widget.category == null) _modeBar(),

          if (widget.category == null) _skinBar(),

          if (_mode == 'prices')
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16, 8, 16, 8,
              ),
              child: TextField(
                controller: _ctrl,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => setState(_load),
                decoration: InputDecoration(
                  hintText:
                      'Search brand (e.g. Nivea, Cetaphil)',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xFFF5EFEC),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

          if (_mode != 'prices') _recList(),

          if (_mode == 'prices')
            FutureBuilder<List<Map<String, String>>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState !=
                    ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final items = snap.data ?? [];

                final hasPrices = items.any(
                  (p) => (p['price'] ?? '').isNotEmpty,
                );

                if (items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: TextButton(
                        onPressed: () => setState(_load),
                        child: const Text(
                          'No products found. Tap to retry',
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    if (hasPrices)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          16, 0, 16, 0,
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Price: ',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 6),
                            _sortChip('Low to high', 'asc'),
                            const SizedBox(width: 8),
                            _sortChip('High to low', 'desc'),
                          ],
                        ),
                      ),

                    GridView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.78,
                      ),
                      itemCount: items.length,
                      itemBuilder: (_, i) => _card(items[i]),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  // LOCAL / IMPORTED TABS
  Widget _modeBar() {
    Widget tab(String label, String value) {
      final selected = _mode == value;

      return Padding(
        padding: const EdgeInsets.only(right: 20),
        child: InkWell(
          onTap: () => setState(() => _mode = value),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected
                      ? FontWeight.w800
                      : FontWeight.w500,
                  color: selected
                      ? Colors.black
                      : Colors.black45,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 2,
                width: 28,
                color: selected
                    ? Colors.black
                    : Colors.transparent,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          tab('Local', 'local'),
          tab('Imported', 'imported'),
        ],
      ),
    );
  }

  // SKIN TYPE FILTER
  Widget _skinBar() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
        children: [
          for (final s in _skins)
            _pill(
              s,
              s == _skin,
              () => setState(() => _skin = s),
            ),
        ],
      ),
    );
  }

  Widget _pill(
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: selected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: selected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  static const _originRank = {
    'Korean': 0,
    'American': 1,
    'Japanese': 2,
  };

  // RECOMMENDED PRODUCT LIST
  Widget _recList() {
    return FutureBuilder<List<Product>>(
      future: _recFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snap.hasError) {
          debugPrint('products error: ${snap.error}');

          return Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: TextButton(
                onPressed: () => setState(_loadRec),
                child: const Text(
                  'Could not load products. Tap to retry',
                ),
              ),
            ),
          );
        }

        final chosen =
            _skin == 'All skin types' ? null : _skin;

        final all = (snap.data ?? []).where((p) {
          return _mode == 'local'
              ? p.isLocal
              : !p.isLocal;
        }).toList();

        if (all.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(
              child: Text('No products found.'),
            ),
          );
        }

        final cats = <String>{};

        for (final p in all) {
          cats.add(p.category);
        }

        final catList = [
          'All',
          ...(cats.toList()..sort()),
        ];

        final cat = catList.contains(_recCategory)
            ? _recCategory
            : 'All';

        final indexed = (cat == 'All'
                ? all
                : all
                    .where((p) => p.category == cat)
                    .toList())
            .asMap()
            .entries
            .toList();

        indexed.sort((a, b) {
          if (chosen != null) {
            final sa = a.value.suits(chosen) ? 0 : 1;
            final sb = b.value.suits(chosen) ? 0 : 1;

            if (sa != sb) {
              return sa.compareTo(sb);
            }
          }

          final pa = a.value.minPrice;
          final pb = b.value.minPrice;

          if (_recSort != 'none') {
            if (pa == null && pb != null) return 1;
            if (pa != null && pb == null) return -1;

            if (pa != null && pb != null && pa != pb) {
              return _recSort == 'asc'
                  ? pa.compareTo(pb)
                  : pb.compareTo(pa);
            }
          } else {
            final av = pa == null ? 1 : 0;
            final bv = pb == null ? 1 : 0;

            if (av != bv) {
              return av.compareTo(bv);
            }

            final ra = _originRank[a.value.origin] ?? 3;
            final rb = _originRank[b.value.origin] ?? 3;

            if (ra != rb) {
              return ra.compareTo(rb);
            }
          }

          return a.key.compareTo(b.key);
        });

        final items = indexed.map((e) => e.value).toList();

        final width = MediaQuery.of(context).size.width;

        final cols = width >= 1000
            ? 6
            : (width >= 700 ? 4 : 3);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(
                  16, 4, 8, 4,
                ),
                children: [
                  for (final c in catList)
                    _pill(
                      c,
                      c == cat,
                      () => setState(() => _recCategory = c),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                16, 4, 16, 0,
              ),
              child: Row(
                children: [
                  const Text(
                    'Price: ',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(width: 6),
                  _recSortChip('Low to high', 'asc'),
                  const SizedBox(width: 8),
                  _recSortChip('High to low', 'desc'),
                ],
              ),
            ),

            GridView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: 16,
                crossAxisSpacing: 12,
                childAspectRatio: 0.56,
              ),
              itemCount: items.length,
              itemBuilder: (_, i) => _gridCard(items[i]),
            ),
          ],
        );
      },
    );
  }

  // PRICE SORT
  Widget _recSortChip(String label, String value) {
    final selected = _recSort == value;

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
      onSelected: (_) {
        setState(() {
          _recSort = selected ? 'none' : value;
        });
      },
    );
  }

  // ADD PRODUCT TO CART
  void _addOffer(Product p, Offer o) {
    final img = _productImageUrl(
      p.image,
      p.name,
      p.brand,
    );

    CartService.instance.add(
      offerId: o.id,
      sellerName: o.sellerName,
      name: p.name,
      brand: p.brand,
      image: img,
      price: o.price,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added to cart (${o.sellerName})'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  String _availability(Product p) =>
      p.offers.isEmpty ? 'No seller yet' : 'Out of stock';

  // PRODUCT CARD
  Widget _gridCard(Product p) {
    final best = p.cheapest;

    return Opacity(
      opacity: best == null ? 0.55 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _details(p),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: double.infinity,
                  child: _imageBox(p, 30),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              p.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              p.category,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black45,
              ),
            ),

            const Spacer(),

            Row(
              children: [
                Expanded(
                  child: Text(
                    best == null
                        ? _availability(p)
                        : tk(best.price),
                    style: TextStyle(
                      fontSize: best == null ? 10 : 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                if (best != null)
                  InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _addOffer(p, best),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEDEDED),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_shopping_cart,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // PRODUCT DETAILS
  void _details(Product p) {
    final best = p.cheapest;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20, 20, 20, 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 96,
                        height: 96,
                        child: _imageBox(p, 36),
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${p.origin} · ${p.category}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            p.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            p.brand,
                            style: const TextStyle(fontSize: 12),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            best == null
                                ? _availability(p)
                                : 'From ${tk(best.price)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (p.description.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    p.description,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],

                const SizedBox(height: 18),

                const Text(
                  'Sellers',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                if (p.offers.isEmpty)
                  const Text(
                    'No seller has listed this product yet.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),

                for (final o in p.offers)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5EFEC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                o.sellerName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              Text(
                                o.inStock
                                    ? 'In stock (${o.stock})'
                                    : 'Out of stock',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Text(
                          tk(o.price),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(width: 10),

                        ElevatedButton(
                          onPressed: o.inStock
                              ? () {
                                  _addOffer(p, o);
                                  Navigator.pop(sheetContext);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // PRICE SEARCH SORT
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
      onSelected: (_) {
        setState(() {
          _sort = value;
          _load();
        });
      },
    );
  }

  // OPEN PRODUCT WEBSITE
  Future<void> _open(String? link) async {
    final uri = Uri.tryParse(link ?? '');

    final ok = uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https');

    if (!ok) {
      _toast('No web page for this product.');
      return;
    }

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        _toast('Could not open the page.');
      }
    } catch (_) {
      _toast('Could not open the page.');
    }
  }

  void _toast(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  // PRICE PRODUCT CARD
  Widget _card(Map<String, String> p) {
    final icon = Container(
      color: const Color(0xFFE8C4B4),
      child: const Center(
        child: Icon(
          Icons.spa,
          size: 40,
          color: Colors.white,
        ),
      ),
    );

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _open(p['link']),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF5EFEC),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: double.infinity,
                  child: (p['image'] ?? '').isEmpty
                      ? icon
                      : Image.network(
                          p['image']!,
                          fit: BoxFit.contain,
                          webHtmlElementStrategy:
                              WebHtmlElementStrategy.prefer,
                          errorBuilder: (_, __, ___) => icon,
                        ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              p['name'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),

            if ((p['price'] ?? '').isNotEmpty)
              Text(
                p['price']!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),

            if ((p['brand'] ?? '').isNotEmpty)
              Text(
                p['brand']!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10),
              ),

            const SizedBox(height: 4),

            const Row(
              children: [
                Icon(Icons.open_in_new, size: 12),
                SizedBox(width: 4),
                Text(
                  'View product',
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}