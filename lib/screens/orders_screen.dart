import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/cart_service.dart';
import '../services/order_history_service.dart';
import 'order_details_screen.dart';

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

  // This never throws. If Supabase gives nothing, we show local orders.
  Future<List<Map<String, dynamic>>> _load() async {
    final all = <Map<String, dynamic>>[];
    var remoteCount = 0;

    try {
      final rows = await Supabase.instance.client
          .from('orders')
          .select()
          .order('created_at', ascending: false);
      final list = List<Map<String, dynamic>>.from(rows);
      remoteCount = list.length;
      debugPrint('ORDERS FROM SUPABASE: $remoteCount');
      for (final r in list) {
        final m = Map<String, dynamic>.from(r);
        m['_time'] = DateTime.tryParse('${m['created_at']}') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        all.add(m);
      }
    } catch (e) {
      debugPrint('ORDERS LOAD ERROR: $e');
    }

    debugPrint('ORDERS IN APP MEMORY: ${OrderHistory.instance.orders.length}');

    // Local orders: skip "saved" ones only if Supabase really gave us rows.
    for (final o in OrderHistory.instance.orders) {
      if (o.saved == true && remoteCount > 0) continue;
      all.add({
        'id': 'local',
        'name': o.name,
        'phone': o.phone,
        'address': o.address,
        'items': o.items,
        'total': o.total,
        'delivery_charge': o.delivery,
        'city': o.city,
        'payment_method': o.paymentMethod,
        'payment_status': o.paymentStatus,
        'status': 'pending',
        '_time': o.createdAt,
      });
    }

    all.sort((a, b) =>
        (b['_time'] as DateTime).compareTo(a['_time'] as DateTime));
    return all;
  }

  String _payLabel(String method, String status) {
    switch (method) {
      case 'cod':
        return 'Cash on delivery';
      case 'demo_bkash':
      case 'bkash':
        return 'bKash';
      case 'demo_card':
      case 'card':
        return 'Card';
      default:
        return status;
    }
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _itemText(dynamic it) {
    try {
      if (it is Map) {
        final seller = it['seller'] ?? it['sellerName'];
        return '${it['qty']} x ${it['name']}'
            '${seller == null ? '' : ' ($seller)'}';
      }
      return '$it';
    } catch (_) {
      return '$it';
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _future = _load()),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
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
    final short = id == 'local'
        ? 'NEW'
        : (id.length > 8 ? id.substring(0, 8) : id).toUpperCase();
    final time = o['_time'] as DateTime;
    final day = time.millisecondsSinceEpoch == 0
        ? ''
        : time.toLocal().toString().substring(0, 10);
    final items = (o['items'] is List) ? (o['items'] as List) : [];
    final total = (o['total'] as num?) ?? 0;
    final delivery = (o['delivery_charge'] as num?);
    final city = (o['city'] ?? '').toString();
    final status = _cap('${o['status'] ?? 'pending'}');

    return Material(
      color: const Color(0xFFF5EFEC),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderDetailsScreen(order: o)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text('Order #$short',
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  const Spacer(),
                  Text(day, style: const TextStyle(fontSize: 11)),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 18),
                ]),
                const SizedBox(height: 6),
                for (final it in items)
                  Text(_itemText(it),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12)),
                if (delivery != null || city.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                      'Delivery${city.isEmpty ? '' : ' to $city'}: ${delivery == null ? '-' : tk(delivery)}',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.black54)),
                ],
                const SizedBox(height: 8),
                Row(children: [
                  Text(tk(total),
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  const Spacer(),
                  Text(
                      '${_payLabel('${o['payment_method']}', '${o['payment_status']}')}  ·  $status',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.black54)),
                ]),
              ]),
        ),
      ),
    );
  }
}