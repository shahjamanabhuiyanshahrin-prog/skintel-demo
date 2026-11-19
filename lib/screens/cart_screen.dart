import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import 'checkout_screen.dart';
import 'orders_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  // If the product has a real http picture use it,
  // otherwise ask the Python backend for the picture.
  String _imageUrl(CartItem it) {
    if (it.image.startsWith('http')) return it.image;
    return Uri.http('localhost:5000', '/product_image', {
      'name': it.name,
      'brand': it.brand,
    }).toString();
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartService.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const OrdersScreen())),
            child: const Text('My orders'),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: cart,
        builder: (context, _) {
          if (cart.isEmpty) {
            return const Center(
                child: Text('Your cart is empty.',
                    style: TextStyle(color: Colors.black54)));
          }
          return Column(children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: cart.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _row(cart, cart.items[i]),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE5E5E5)))),
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Total', style: TextStyle(fontSize: 12)),
                  Text(tk(cart.total),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                ]),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CheckoutScreen())),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(160, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24))),
                  child: const Text('Checkout'),
                ),
              ]),
            ),
          ]);
        },
      ),
    );
  }

  Widget _row(CartService cart, CartItem it) {
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
            width: 64,
            height: 64,
            child: Image.network(_imageUrl(it),
                fit: BoxFit.cover,
                webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                errorBuilder: (_, __, ___) => icon),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(it.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text('Sold by ${it.sellerName}',
                style: const TextStyle(fontSize: 11, color: Colors.black54)),
            Text(tk(it.price), style: const TextStyle(fontSize: 12)),
            Row(children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => cart.setQty(it, it.qty - 1),
              ),
              Text('${it.qty}',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => cart.setQty(it, it.qty + 1),
              ),
              const Spacer(),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.delete_outline),
                onPressed: () => cart.remove(it),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}