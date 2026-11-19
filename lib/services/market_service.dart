import 'package:supabase_flutter/supabase_flutter.dart';

// One seller's price for a product.
class Offer {
  final String id;
  final String sellerId;
  final String sellerName;
  final double price;
  final int stock;

  Offer({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.price,
    required this.stock,
  });

  bool get inStock => stock > 0;
}

class Product {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String origin;
  final String description;
  final String image;
  final List<String> skinTypes;
  final List<Offer> offers; // active offers, cheapest first

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.origin,
    required this.description,
    required this.image,
    required this.skinTypes,
    required this.offers,
  });

  bool get isLocal => origin == 'Local';

  // Cheapest offer that still has stock.
  Offer? get cheapest {
    for (final o in offers) {
      if (o.inStock) return o;
    }
    return null;
  }

  double? get minPrice => cheapest?.price;

  bool suits(String? skin) =>
      skin == null || skinTypes.contains('All') || skinTypes.contains(skin);
}

class MarketService {
  static SupabaseClient get _db => Supabase.instance.client;

  // ---------- buyer ----------
  static Future<List<Product>> getProducts() async {
    final rows = await _db
        .from('products')
        .select(
            '*, offers(id, price, stock, active, seller_id, sellers(id, shop_name))')
        .order('name');

    final list = <Product>[];
    for (final r in rows) {
      final offers = <Offer>[];
      for (final o in (r['offers'] as List? ?? [])) {
        if (o['active'] != true) continue;
        final seller = o['sellers'] as Map? ?? {};
        offers.add(Offer(
          id: '${o['id']}',
          sellerId: '${o['seller_id']}',
          sellerName: '${seller['shop_name'] ?? 'Seller'}',
          price: (o['price'] as num).toDouble(),
          stock: (o['stock'] as num).toInt(),
        ));
      }
      offers.sort((a, b) => a.price.compareTo(b.price));
      list.add(Product(
        id: '${r['id']}',
        name: '${r['name']}',
        brand: '${r['brand']}',
        category: '${r['category']}',
        origin: '${r['origin']}',
        description: '${r['description'] ?? ''}',
        image: '${r['image_url'] ?? ''}',
        skinTypes: List<String>.from(r['skin_types'] as List? ?? ['All']),
        offers: offers,
      ));
    }
    return list;
  }

  // The database checks price and stock itself, then saves the order.
  static Future<String> placeOrder({
    required String name,
    required String phone,
    required String city,
    required String address,
    required String payment,
    required List<Map<String, dynamic>> items,
  }) async {
    final id = await _db.rpc('place_order', params: {
      'p_name': name,
      'p_phone': phone,
      'p_city': city,
      'p_address': address,
      'p_payment': payment,
      'p_items': items,
    });
    return '$id';
  }

  // ---------- seller ----------
  static Future<Map<String, dynamic>?> mySeller() async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return null;
    return await _db.from('sellers').select().eq('user_id', uid).maybeSingle();
  }

  static Future<void> registerSeller(String shopName, String phone) async {
    await _db.from('sellers').insert({'shop_name': shopName, 'phone': phone});
  }

  static Future<List<Map<String, dynamic>>> myOffers(String sellerId) async {
    final rows = await _db
        .from('offers')
        .select('*, products(name, brand, image_url)')
        .eq('seller_id', sellerId)
        .order('created_at');
    return List<Map<String, dynamic>>.from(rows);
  }

  static Future<void> saveOffer({
    required String productId,
    required String sellerId,
    required double price,
    required int stock,
  }) async {
    await _db.from('offers').upsert({
      'product_id': productId,
      'seller_id': sellerId,
      'price': price,
      'stock': stock,
      'active': true,
    }, onConflict: 'product_id,seller_id');
  }

  static Future<void> deleteOffer(String offerId) async {
    await _db.from('offers').delete().eq('id', offerId);
  }

  static Future<String> addProduct({
    required String name,
    required String brand,
    required String category,
    required String origin,
    required List<String> skinTypes,
    required String description,
    required String imageUrl,
  }) async {
    final uid = _db.auth.currentUser?.id;
    final row = await _db
        .from('products')
        .insert({
          'name': name,
          'brand': brand,
          'category': category,
          'origin': origin,
          'skin_types': skinTypes.isEmpty ? ['All'] : skinTypes,
          'description': description,
          'image_url': imageUrl.isEmpty ? null : imageUrl,
          'created_by': uid,
        })
        .select('id')
        .single();
    return '${row['id']}';
  }

  // Order lines that belong to this seller, newest first.
  static Future<List<Map<String, dynamic>>> sellerOrders(
      String sellerId) async {
    final rows = await _db
        .from('order_items')
        .select(
            '*, orders(name, phone, address, city, created_at, status, payment_method)')
        .eq('seller_id', sellerId);
    final list = List<Map<String, dynamic>>.from(rows);
    list.sort((a, b) {
      final da = '${(a['orders'] as Map?)?['created_at'] ?? ''}';
      final db = '${(b['orders'] as Map?)?['created_at'] ?? ''}';
      return db.compareTo(da);
    });
    return list;
  }
}