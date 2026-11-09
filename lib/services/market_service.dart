import 'package:supabase_flutter/supabase_flutter.dart';

final _db = Supabase.instance.client;

// true = products with no seller offer get fake demo offers (for demo only)
const bool kDemoOffers = true;

// Only these brands will show in the app.
// (lowercase, no spaces, no symbols)
const List<String> kLocalBrands = [
  'skincafe',
  'skino',
  'innsaei',
  'theceleste',
  'celeste',
  'lilac',
  'mayatrueherbs',
  'rajkonna',
];

const List<String> kKoreanBrands = [
  'skin1004',
  'cosrx',
  'beautyofjoseon',
  'roundlab',
  'isntree',
  'torriden',
  'anua',
  'puritoseoul',
  'numbuzin',
  'innisfree',
  'iunik',
  'dralthea',
  'somebymi',
  'laneige',
  'etudehouse',
  'etude',
  'haruharuwonder',
  'klairs',
  'illiyoon',
  'axisy',
  'mediheal',
];

String _norm(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

bool _brandIn(String brand, List<String> keys) {
  final b = _norm(brand);
  if (b.isEmpty) return false;
  return keys.any((k) => b == k || b.startsWith(k));
}

// Placeholder Local products (demo only), used only when the brand
// has no real product in Supabase.
// Format: [name, brand, category, description]
const List<List<String>> kExtraLocal = [
  ['Skin Cafe Face Wash', 'Skin Cafe', 'Cleanser',
      'Gentle daily face wash. Demo listing.'],
  ['Skin Cafe Moisturizer', 'Skin Cafe', 'Moisturizer',
      'Daily hydrating moisturizer. Demo listing.'],
  ['Skin Cafe Serum', 'Skin Cafe', 'Serum',
      'Lightweight face serum. Demo listing.'],
  ["Skin'O Gel Moisturizer", "Skin'O", 'Moisturizer',
      'Light gel moisturizer. Demo listing.'],
  ["Skin'O Cleanser", "Skin'O", 'Cleanser',
      'Gentle daily cleanser. Demo listing.'],
  ['Innsaei Cleanser', 'Innsaei', 'Cleanser',
      'Science-based gentle cleanser. Demo listing.'],
  ['Innsaei Serum', 'Innsaei', 'Serum',
      'Science-based face serum. Demo listing.'],
  ['The Celeste Active Serum', 'The Celeste', 'Serum',
      'Serum with active ingredients. Demo listing.'],
  ['Lilac Face Wash', 'Lilac', 'Cleanser',
      'Fresh daily face wash. Demo listing.'],
  ['Lilac Serum', 'Lilac', 'Serum',
      'Lightweight face serum. Demo listing.'],
  ['Maya True Herbs Herbal Moisturizer', 'Maya True Herbs', 'Moisturizer',
      'Herbal skincare moisturizer. Demo listing.'],
  ['Rajkonna Face Wash', 'Rajkonna', 'Cleanser',
      'Affordable daily face wash. Demo listing.'],
];

List<Offer> _demoOffers(String productId, String name) {
  final h = name.codeUnits.fold<int>(7, (a, c) => (a * 31 + c) & 0x7fffffff);
  final base = 250 + h % 1500;
  return [
    Offer(
      id: 'demo-a-$productId',
      productId: productId,
      sellerId: 'demo-a',
      sellerName: 'Glow Demo Store',
      price: (base ~/ 10 * 10).toDouble(),
      stock: 50,
      active: true,
    ),
    Offer(
      id: 'demo-b-$productId',
      productId: productId,
      sellerId: 'demo-b',
      sellerName: 'Beauty Demo Mart',
      price: ((base * 1.08) ~/ 10 * 10).toDouble(),
      stock: 50,
      active: true,
    ),
  ];
}

class Offer {
  final String id;
  final String productId;
  final String sellerId;
  final String sellerName;
  final double price;
  final int stock;
  final bool active;

  Offer({
    required this.id,
    required this.productId,
    required this.sellerId,
    required this.sellerName,
    required this.price,
    required this.stock,
    required this.active,
  });

  bool get available => active && stock > 0;
  bool get isDemo => id.startsWith('demo-');

  factory Offer.fromMap(Map<String, dynamic> m) {
    final s = m['sellers'];
    return Offer(
      id: m['id'].toString(),
      productId: m['product_id'].toString(),
      sellerId: m['seller_id'].toString(),
      sellerName: (s is Map ? s['shop_name'] : null)?.toString() ?? 'Seller',
      price: (m['price'] as num).toDouble(),
      stock: (m['stock'] as num?)?.toInt() ?? 0,
      active: m['active'] as bool? ?? true,
    );
  }
}

class Product {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String origin;
  final List<String> skinTypes;
  final String description;
  final String image;
  final List<Offer> offers;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.origin,
    required this.skinTypes,
    required this.description,
    required this.image,
    required this.offers,
  });

  factory Product.fromMap(Map<String, dynamic> m) {
    final rawOffers = (m['offers'] as List?) ?? [];
    final offers = rawOffers
        .map((e) => Offer.fromMap(Map<String, dynamic>.from(e as Map)))
        .where((o) => o.active)
        .toList()
      ..sort((a, b) => a.price.compareTo(b.price));

    if (kDemoOffers && offers.isEmpty) {
      offers.addAll(
          _demoOffers(m['id'].toString(), (m['name'] ?? '').toString()));
    }

    return Product(
      id: m['id'].toString(),
      name: (m['name'] ?? '').toString(),
      brand: (m['brand'] ?? '').toString(),
      category: (m['category'] ?? '').toString(),
      origin: (m['origin'] ?? '').toString(),
      skinTypes:
          ((m['skin_types'] as List?) ?? []).map((e) => e.toString()).toList(),
      description: (m['description'] ?? '').toString(),
      image: (m['image_url'] ?? '').toString(),
      offers: offers,
    );
  }

  bool get isLocal =>
      origin.toLowerCase() == 'local' || _brandIn(brand, kLocalBrands);

  // Imported order: Korean, American, Japanese, then the rest
  int get originRank {
    if (_brandIn(brand, kKoreanBrands)) return 0;
    switch (origin.toLowerCase()) {
      case 'korean':
        return 0;
      case 'american':
        return 1;
      case 'japanese':
        return 2;
      default:
        return 3;
    }
  }

  List<Offer> get available => offers.where((o) => o.available).toList();
  Offer? get cheapest => available.isEmpty ? null : available.first;
  double? get minPrice => cheapest?.price;
  bool get hasOffers => offers.isNotEmpty;

  bool suits(String? skinType) {
    if (skinType == null || skinType.isEmpty) return true;
    if (skinTypes.isEmpty) return true;
    final t = skinType.toLowerCase();
    return skinTypes
        .any((s) => s.toLowerCase() == t || s.toLowerCase() == 'all');
  }
}

class MarketService {
  // ---------- Buyer ----------

  static Future<List<Product>> getProducts() async {
    final rows = await _db
        .from('products')
        .select(
            '*, offers(id, product_id, seller_id, price, stock, active, sellers(shop_name))')
        .order('name');
    final all = (rows as List)
        .map((e) => Product.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    // keep only the selected brands
    final list = all
        .where((p) =>
            _brandIn(p.brand, kLocalBrands) ||
            _brandIn(p.brand, kKoreanBrands))
        .toList();

    // add placeholder local products only for brands with no real product
    final names = list.map((p) => p.name.toLowerCase()).toSet();
    for (var i = 0; i < kExtraLocal.length; i++) {
      final e = kExtraLocal[i];
      if (names.contains(e[0].toLowerCase())) continue;
      final brandKey = _norm(e[1]);
      final brandHasReal = list.any((p) => _norm(p.brand) == brandKey);
      if (brandHasReal) continue;
      final id = 'local-$i';
      list.add(Product(
        id: id,
        name: e[0],
        brand: e[1],
        category: e[2],
        origin: 'Local',
        skinTypes: const ['All'],
        description: e[3],
        image: '',
        offers: kDemoOffers ? _demoOffers(id, e[0]) : [],
      ));
    }
    return list;
  }

  // Returns the new order id
  static Future<String> placeOrder({
    required String name,
    required String phone,
    required String city,
    required String address,
    required String payment, // 'cod' | 'demo_bkash' | 'demo_card'
    required List<Map<String, dynamic>> items, // [{offer_id, qty}]
  }) async {
    final res = await _db.rpc('place_order', params: {
      'p_name': name,
      'p_phone': phone,
      'p_city': city,
      'p_address': address,
      'p_payment': payment,
      'p_items': items,
    });
    return res.toString();
  }

  // ---------- Seller ----------

  static String get _uid => _db.auth.currentUser!.id;

  // null = this user is not a seller yet
  static Future<Map<String, dynamic>?> mySeller() async {
    final row =
        await _db.from('sellers').select().eq('user_id', _uid).maybeSingle();
    return row == null ? null : Map<String, dynamic>.from(row);
  }

  static Future<void> registerSeller(String shopName, String phone) async {
    await _db.from('sellers').insert({
      'user_id': _uid,
      'shop_name': shopName,
      'phone': phone,
    });
  }

  static Future<List<Map<String, dynamic>>> myOffers() async {
    final s = await mySeller();
    if (s == null) return [];
    final rows = await _db
        .from('offers')
        .select('*, products(name, brand, image_url)')
        .eq('seller_id', s['id'])
        .order('created_at', ascending: false);
    return (rows as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  static Future<void> saveOffer({
    required String productId,
    required double price,
    required int stock,
  }) async {
    final s = await mySeller();
    if (s == null) throw Exception('Register as a seller first.');
    await _db.from('offers').upsert({
      'product_id': productId,
      'seller_id': s['id'],
      'price': price,
      'stock': stock,
      'active': true,
    }, onConflict: 'product_id,seller_id');
  }

  static Future<void> deleteOffer(String offerId) async {
    await _db.from('offers').delete().eq('id', offerId);
  }

  static Future<void> addProduct({
    required String name,
    required String brand,
    required String category,
    required String origin,
    required List<String> skinTypes,
    required String description,
    required String imageUrl,
  }) async {
    await _db.from('products').insert({
      'name': name,
      'brand': brand,
      'category': category,
      'origin': origin,
      'skin_types': skinTypes,
      'description': description,
      'image_url': imageUrl,
      'created_by': _uid,
    });
  }

  static Future<List<Map<String, dynamic>>> sellerOrders() async {
    final s = await mySeller();
    if (s == null) return [];
    final rows = await _db
        .from('order_items')
        .select('*, orders(name, phone, city, address, created_at)')
        .eq('seller_id', s['id']);
    final list = (rows as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    String dateOf(Map<String, dynamic> m) =>
        (m['orders'] is Map ? m['orders']['created_at'] : '')?.toString() ??
        '';
    list.sort((a, b) => dateOf(b).compareTo(dateOf(a)));
    return list;
  }
}