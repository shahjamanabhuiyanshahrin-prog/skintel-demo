import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/cart_service.dart';
import '../services/market_service.dart';

InputDecoration _dec(String label) => InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF5EFEC),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    );

ButtonStyle _blackButton() => ElevatedButton.styleFrom(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    minimumSize: const Size.fromHeight(50),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)));

void _say(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

// ---------------------------------------------------------------------------
// Seller home: register first, then manage your offers and see your orders.
// ---------------------------------------------------------------------------
class SellerScreen extends StatefulWidget {
  const SellerScreen({super.key});
  @override
  State<SellerScreen> createState() => _SellerScreenState();
}

class _SellerScreenState extends State<SellerScreen> {
  Map<String, dynamic>? _seller;
  bool _loading = true;
  bool _failed = false;
  int _refresh = 0;

  @override
  void initState() {
    super.initState();
    _loadSeller();
  }

  Future<void> _loadSeller() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final s = await MarketService.mySeller();
      if (!mounted) return;
      setState(() {
        _seller = s;
        _loading = false;
      });
    } catch (e) {
      debugPrint('seller error: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
          appBar: AppBar(title: const Text('Sell on Skintel')),
          body: const Center(child: CircularProgressIndicator()));
    }
    if (_failed) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sell on Skintel')),
        body: Center(
          child: TextButton(
              onPressed: _loadSeller,
              child: const Text('Could not load. Tap to retry')),
        ),
      );
    }
    if (_seller == null) {
      return _RegisterSeller(onDone: _loadSeller);
    }
    final sellerId = '${_seller!['id']}';
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${_seller!['shop_name']}'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.black,
            indicatorColor: Colors.black,
            tabs: [Tab(text: 'My offers'), Tab(text: 'Orders')],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Add offer'),
          onPressed: () async {
            final changed = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                    builder: (_) => AddOfferScreen(sellerId: sellerId)));
            if (changed == true) setState(() => _refresh++);
          },
        ),
        body: TabBarView(children: [
          _OffersTab(
              key: ValueKey('offers$_refresh'),
              sellerId: sellerId,
              onChanged: () => setState(() => _refresh++)),
          _OrdersTab(key: ValueKey('orders$_refresh'), sellerId: sellerId),
        ]),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
class _RegisterSeller extends StatefulWidget {
  final VoidCallback onDone;
  const _RegisterSeller({required this.onDone});
  @override
  State<_RegisterSeller> createState() => _RegisterSellerState();
}

class _RegisterSellerState extends State<_RegisterSeller> {
  final _shop = TextEditingController();
  final _phone = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _shop.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final phone = _phone.text.replaceAll(RegExp(r'[^0-9+]'), '');
    if (_shop.text.trim().length < 2) {
      _say(context, 'Please enter your shop name.');
      return;
    }
    if (phone.length < 10 || phone.length > 15) {
      _say(context, 'Please enter a valid phone number.');
      return;
    }
    setState(() => _busy = true);
    try {
      await MarketService.registerSeller(_shop.text.trim(), phone);
      widget.onDone();
    } on PostgrestException catch (e) {
      debugPrint('register error: ${e.message}');
      if (mounted) setState(() => _busy = false);
      if (mounted) _say(context, e.message);
    } catch (e) {
      debugPrint('register error: $e');
      if (mounted) setState(() => _busy = false);
      if (mounted) _say(context, 'Could not save. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell on Skintel'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('Become a seller',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text(
            'List skincare products with your own price and stock. Buyers order through Skintel and you deliver.',
            style: TextStyle(fontSize: 13, color: Colors.black54)),
        const SizedBox(height: 20),
        TextField(controller: _shop, decoration: _dec('Shop name')),
        const SizedBox(height: 12),
        TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: _dec('Phone number')),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _busy ? null : _save,
          style: _blackButton(),
          child: _busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('Create seller account'),
        ),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
class _OffersTab extends StatefulWidget {
  final String sellerId;
  final VoidCallback onChanged;
  const _OffersTab({super.key, required this.sellerId, required this.onChanged});
  @override
  State<_OffersTab> createState() => _OffersTabState();
}

class _OffersTabState extends State<_OffersTab> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = MarketService.myOffers(widget.sellerId);
  }

  Future<void> _edit(Map<String, dynamic> o) async {
    final price = TextEditingController(text: '${(o['price'] as num).round()}');
    final stock = TextEditingController(text: '${o['stock']}');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${(o['products'] as Map?)?['name'] ?? 'Offer'}',
            style: const TextStyle(fontSize: 15)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
              controller: price,
              keyboardType: TextInputType.number,
              decoration: _dec('Price (Tk)')),
          const SizedBox(height: 12),
          TextField(
              controller: stock,
              keyboardType: TextInputType.number,
              decoration: _dec('Stock')),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save')),
        ],
      ),
    );
    if (ok != true) return;
    final p = double.tryParse(price.text.trim());
    final s = int.tryParse(stock.text.trim());
    if (p == null || p <= 0 || s == null || s < 0) {
      if (mounted) _say(context, 'Enter a price above 0 and a stock of 0 or more.');
      return;
    }
    try {
      await MarketService.saveOffer(
          productId: '${o['product_id']}',
          sellerId: widget.sellerId,
          price: p,
          stock: s);
      widget.onChanged();
    } catch (e) {
      debugPrint('save offer error: $e');
      if (mounted) _say(context, 'Could not save. Please try again.');
    }
  }

  Future<void> _delete(Map<String, dynamic> o) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove this offer?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Remove')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await MarketService.deleteOffer('${o['id']}');
      widget.onChanged();
    } catch (e) {
      debugPrint('delete offer error: $e');
      if (mounted) _say(context, 'Could not remove. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
              child: TextButton(
                  onPressed: widget.onChanged,
                  child: const Text('Could not load. Tap to retry')));
        }
        final offers = snap.data ?? [];
        if (offers.isEmpty) {
          return const Center(
              child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
                'You have no offers yet. Tap "Add offer" to sell a product.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54)),
          ));
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          itemCount: offers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final o = offers[i];
            final prod = (o['products'] as Map?) ?? {};
            final image = '${prod['image_url'] ?? ''}';
            final icon = Container(
                color: const Color(0xFFE8C4B4),
                child: const Icon(Icons.spa, color: Colors.white));
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: const Color(0xFFF5EFEC),
                  borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 54,
                    height: 54,
                    child: image.isEmpty
                        ? icon
                        : Image.network(image,
                            fit: BoxFit.cover,
                            webHtmlElementStrategy:
                                WebHtmlElementStrategy.prefer,
                            errorBuilder: (_, __, ___) => icon),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${prod['name'] ?? ''}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(
                            '${tk(o['price'] as num)}  ·  Stock ${o['stock']}',
                            style: const TextStyle(fontSize: 12)),
                      ]),
                ),
                IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _edit(o)),
                IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _delete(o)),
              ]),
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
class _OrdersTab extends StatelessWidget {
  final String sellerId;
  const _OrdersTab({super.key, required this.sellerId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: MarketService.sellerOrders(sellerId),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          debugPrint('seller orders error: ${snap.error}');
          return const Center(child: Text('Could not load orders.'));
        }
        final rows = snap.data ?? [];
        if (rows.isEmpty) {
          return const Center(
              child: Text('No orders yet.',
                  style: TextStyle(color: Colors.black54)));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: rows.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final r = rows[i];
            final ord = (r['orders'] as Map?) ?? {};
            final date = '${ord['created_at'] ?? ''}';
            final day = date.length >= 10 ? date.substring(0, 10) : date;
            final qty = (r['qty'] as num).toInt();
            final price = (r['price'] as num);
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: const Color(0xFFF5EFEC),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text('$qty x ${r['product_name']}',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700)),
                      ),
                      Text(tk(price * qty),
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w800)),
                    ]),
                    const SizedBox(height: 6),
                    Text('${ord['name'] ?? ''}  ·  ${ord['phone'] ?? ''}',
                        style: const TextStyle(fontSize: 12)),
                    Text('${ord['address'] ?? ''}, ${ord['city'] ?? ''}',
                        style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                        '$day  ·  ${ord['payment_method'] == 'cod' ? 'Cash on delivery' : 'Demo payment'}',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black54)),
                  ]),
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Add (or update) your price and stock for a product.
// ---------------------------------------------------------------------------
class AddOfferScreen extends StatefulWidget {
  final String sellerId;
  const AddOfferScreen({super.key, required this.sellerId});
  @override
  State<AddOfferScreen> createState() => _AddOfferScreenState();
}

class _AddOfferScreenState extends State<AddOfferScreen> {
  late Future<List<Product>> _products;
  Product? _picked;
  final _price = TextEditingController();
  final _stock = TextEditingController(text: '10');
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _products = MarketService.getProducts();
  }

  @override
  void dispose() {
    _price.dispose();
    _stock.dispose();
    super.dispose();
  }

  Future<void> _newProduct() async {
    final id = await Navigator.push<String>(
        context, MaterialPageRoute(builder: (_) => const NewProductScreen()));
    if (id == null) return;
    final fresh = MarketService.getProducts();
    setState(() => _products = fresh);
    final list = await fresh;
    final match = list.where((p) => p.id == id);
    if (match.isNotEmpty && mounted) setState(() => _picked = match.first);
  }

  Future<void> _save() async {
    final p = double.tryParse(_price.text.trim());
    final s = int.tryParse(_stock.text.trim());
    if (_picked == null) {
      _say(context, 'Please choose a product.');
      return;
    }
    if (p == null || p <= 0) {
      _say(context, 'Enter a price above 0.');
      return;
    }
    if (s == null || s < 0) {
      _say(context, 'Enter a stock of 0 or more.');
      return;
    }
    setState(() => _busy = true);
    try {
      await MarketService.saveOffer(
          productId: _picked!.id,
          sellerId: widget.sellerId,
          price: p,
          stock: s);
      if (mounted) Navigator.pop(context, true);
    } on PostgrestException catch (e) {
      debugPrint('offer error: ${e.message}');
      if (mounted) setState(() => _busy = false);
      if (mounted) _say(context, e.message);
    } catch (e) {
      debugPrint('offer error: $e');
      if (mounted) setState(() => _busy = false);
      if (mounted) _say(context, 'Could not save. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add offer'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<List<Product>>(
        future: _products,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return const Center(child: Text('Could not load products.'));
          }
          final list = snap.data ?? [];
          return ListView(padding: const EdgeInsets.all(20), children: [
            const Text('1. Choose a product',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Autocomplete<Product>(
              displayStringForOption: (p) => p.name,
              optionsBuilder: (v) {
                final q = v.text.trim().toLowerCase();
                if (q.isEmpty) return const Iterable<Product>.empty();
                return list
                    .where((p) =>
                        p.name.toLowerCase().contains(q) ||
                        p.brand.toLowerCase().contains(q))
                    .take(10);
              },
              onSelected: (p) => setState(() => _picked = p),
              fieldViewBuilder: (context, ctrl, focus, onSubmit) => TextField(
                controller: ctrl,
                focusNode: focus,
                decoration: _dec('Search by name or brand'),
              ),
            ),
            if (_picked != null) ...[
              const SizedBox(height: 8),
              Text('Selected: ${_picked!.name}',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700)),
            ],
            TextButton(
              onPressed: _newProduct,
              child: const Text('Product not in the list? Add a new product'),
            ),
            const SizedBox(height: 12),
            const Text('2. Your price and stock',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            TextField(
                controller: _price,
                keyboardType: TextInputType.number,
                decoration: _dec('Price (Tk)')),
            const SizedBox(height: 12),
            TextField(
                controller: _stock,
                keyboardType: TextInputType.number,
                decoration: _dec('Stock (how many you have)')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _busy ? null : _save,
              style: _blackButton(),
              child: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Save offer'),
            ),
          ]);
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add a product that is not in the catalog yet.
// ---------------------------------------------------------------------------
class NewProductScreen extends StatefulWidget {
  const NewProductScreen({super.key});
  @override
  State<NewProductScreen> createState() => _NewProductScreenState();
}

class _NewProductScreenState extends State<NewProductScreen> {
  static const _categories = [
    'Cleanser',
    'Moisturizer',
    'Serum',
    'Sunscreen',
    'Toner',
    'Treatment',
    'Other'
  ];
  static const _origins = [
    'Local',
    'Korean',
    'American',
    'Japanese',
    'French',
    'Other'
  ];
  static const _skins = ['Dry', 'Oily', 'Combination', 'Normal'];

  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _desc = TextEditingController();
  final _image = TextEditingController();
  String _category = 'Moisturizer';
  String _origin = 'Local';
  final Set<String> _picked = {};
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _brand.dispose();
    _desc.dispose();
    _image.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().length < 3 || _brand.text.trim().isEmpty) {
      _say(context, 'Please enter the product name and brand.');
      return;
    }
    final img = _image.text.trim();
    if (img.isNotEmpty && !img.startsWith('http')) {
      _say(context, 'The picture link must start with http.');
      return;
    }
    setState(() => _busy = true);
    try {
      final id = await MarketService.addProduct(
        name: _name.text.trim(),
        brand: _brand.text.trim(),
        category: _category,
        origin: _origin,
        skinTypes: _picked.toList(),
        description: _desc.text.trim(),
        imageUrl: img,
      );
      if (mounted) Navigator.pop(context, id);
    } on PostgrestException catch (e) {
      debugPrint('product error: ${e.message}');
      if (mounted) setState(() => _busy = false);
      if (mounted) _say(context, e.message);
    } catch (e) {
      debugPrint('product error: $e');
      if (mounted) setState(() => _busy = false);
      if (mounted) _say(context, 'Could not save. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New product'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        TextField(controller: _name, decoration: _dec('Product name')),
        const SizedBox(height: 12),
        TextField(controller: _brand, decoration: _dec('Brand')),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _category,
          decoration: _dec('Category'),
          items: [
            for (final c in _categories)
              DropdownMenuItem(value: c, child: Text(c)),
          ],
          onChanged: (v) => setState(() => _category = v!),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _origin,
          decoration: _dec('Made in / brand origin'),
          items: [
            for (final o in _origins) DropdownMenuItem(value: o, child: Text(o)),
          ],
          onChanged: (v) => setState(() => _origin = v!),
        ),
        const SizedBox(height: 16),
        const Text('Suits which skin types? (leave empty for all)',
            style: TextStyle(fontSize: 12)),
        const SizedBox(height: 6),
        Wrap(spacing: 8, children: [
          for (final s in _skins)
            FilterChip(
              label: Text(s),
              selected: _picked.contains(s),
              onSelected: (on) =>
                  setState(() => on ? _picked.add(s) : _picked.remove(s)),
            ),
        ]),
        const SizedBox(height: 12),
        TextField(
            controller: _desc, maxLines: 2, decoration: _dec('Short description')),
        const SizedBox(height: 12),
        TextField(
            controller: _image,
            decoration: _dec('Picture link (optional, starts with http)')),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _busy ? null : _save,
          style: _blackButton(),
          child: _busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('Save product'),
        ),
      ]),
    );
  }
}