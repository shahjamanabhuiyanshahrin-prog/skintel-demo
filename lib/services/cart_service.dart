import 'package:flutter/foundation.dart';

class CartItem {
  final String offerId;
  final String sellerName;
  final String name;
  final String brand;
  final String image;
  final double price;
  int qty;

  CartItem({
    required this.offerId,
    required this.sellerName,
    required this.name,
    required this.brand,
    required this.image,
    required this.price,
    this.qty = 1,
  });

  Map<String, dynamic> toJson() => {
        'offer_id': offerId,
        'seller': sellerName,
        'name': name,
        'brand': brand,
        'image': image,
        'price': price,
        'qty': qty,
      };
}

// 1250 -> "Tk 1,250"
String tk(num v) {
  final s = v.round().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return 'Tk $buf';
}

class CartService extends ChangeNotifier {
  CartService._();
  static final CartService instance = CartService._();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get count => _items.fold(0, (s, i) => s + i.qty);
  double get total => _items.fold(0.0, (s, i) => s + i.price * i.qty);

  void add({
    required String offerId,
    required String sellerName,
    required String name,
    required String brand,
    required String image,
    required double price,
  }) {
    final i = _items.indexWhere((e) => e.offerId == offerId);
    if (i >= 0) {
      if (_items[i].qty < 20) _items[i].qty++;
    } else {
      _items.add(CartItem(
        offerId: offerId,
        sellerName: sellerName,
        name: name,
        brand: brand,
        image: image,
        price: price,
      ));
    }
    notifyListeners();
  }

  void setQty(CartItem item, int qty) {
    if (qty < 1) {
      _items.remove(item);
    } else {
      item.qty = qty > 20 ? 20 : qty;
    }
    notifyListeners();
  }

  void remove(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  // For place_order RPC: [{offer_id, qty}]
  List<Map<String, dynamic>> toRpc() =>
      _items.map((e) => {'offer_id': e.offerId, 'qty': e.qty}).toList();
}