import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/cart_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  // Row level security makes sure you only get your own orders.
  Future<List<Map<String, dynamic>>> _load() async {
    final rows = await Supabase.instance.client
        .from('orders')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }

  String _payLabel(String method, String status) {
    switch (method) {
      case 'cod':
        return 'Cash on delivery';
      case 'demo_bkash':
        return 'bKash (demo)';
      case 'demo_card':
        return 'Card (demo)';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My orders'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: TextButton(
                onPressed: () => setState(() => _future = _load()),
                child: const Text('Could not load orders. Tap to retry'),
              ),
            );
          }
          final orders = snap.data ?? [];
          if (orders.isEmpty) {
            return const Center(
                child: Text('No orders yet.',
                    style: TextStyle(color: Colors.black54)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _card(orders[i]),
          );
        },
      ),
    );
  }

  Widget _card(Map<String, dynamic> o) {
    final id = o['id'].toString();
    final short = (id.length > 8 ? id.substring(0, 8) : id).toUpperCase();
    final date = (o['created_at'] ?? '').toString();
    final day = date.length >= 10 ? date.substring(0, 10) : date;
    final items = List<Map<String, dynamic>>.from(o['items'] as List? ?? []);
    final total = (o['total'] as num?) ?? 0;
    final delivery = (o['delivery_charge'] as num?);
    final city = (o['city'] ?? '').toString();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: const Color(0xFFF5EFEC),
          borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Order #$short',
              style: const TextStyle(fontWeight: FontWeight.w800)),
          const Spacer(),
          Text(day, style: const TextStyle(fontSize: 11)),
        ]),
        const SizedBox(height: 6),
        for (final it in items)
          Text('${it['qty']} x ${it['name']}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12)),
        if (delivery != null || city.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
              'Delivery${city.isEmpty ? '' : ' to $city'}: ${delivery == null ? '-' : tk(delivery)}',
              style: const TextStyle(fontSize: 11, color: Colors.black54)),
        ],
        const SizedBox(height: 8),
        Row(children: [
          Text(tk(total),
              style: const TextStyle(fontWeight: FontWeight.w800)),
          const Spacer(),
          Text(
              '${_payLabel('${o['payment_method']}', '${o['payment_status']}')}  ·  ${o['status']}',
              style: const TextStyle(fontSize: 11, color: Colors.black54)),
        ]),
      ]),
    );
  }
}