import 'package:flutter/material.dart';
import '../services/cart_service.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  const OrderDetailsScreen({super.key, required this.order});

  String _payLabel(String method) {
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
        return method;
    }
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  int _stepIndex(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 1;
      case 'shipped':
        return 2;
      case 'delivered':
        return 3;
      default:
        return 0;
    }
  }

  Widget _box(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: const Color(0xFFF5EFEC),
          borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        ...children,
      ]),
    );
  }

  Widget _row(String a, String b, {bool bold = false}) {
    final style = TextStyle(
        fontSize: 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w400);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(a, style: style),
        const SizedBox(width: 16),
        Expanded(
            child: Text(b, textAlign: TextAlign.right, style: style)),
      ]),
    );
  }

  Widget _timeline(String status) {
    final steps = ['Pending', 'Confirmed', 'Shipped', 'Delivered'];
    final current = _stepIndex(status);
    return Row(children: [
      for (var i = 0; i < steps.length; i++)
        Expanded(
          child: Column(children: [
            Icon(
              i <= current ? Icons.check_circle : Icons.circle_outlined,
              color: i <= current ? Colors.green : Colors.black38,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(steps[i],
                style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        i == current ? FontWeight.w800 : FontWeight.w400)),
          ]),
        ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final o = order;
    final id = o['id'].toString();
    final short = id == 'local'
        ? 'NEW'
        : (id.length > 8 ? id.substring(0, 8) : id).toUpperCase();
    final time = o['_time'] as DateTime?;
    final day = (time == null || time.millisecondsSinceEpoch == 0)
        ? '-'
        : time.toLocal().toString().substring(0, 16);
    final status = '${o['status'] ?? 'pending'}';
    final items = (o['items'] is List) ? (o['items'] as List) : [];
    final total = (o['total'] as num?) ?? 0;
    final delivery = (o['delivery_charge'] as num?) ?? 0;
    final subtotal = total - delivery;

    final name = (o['name'] ?? '').toString();
    final phone = (o['phone'] ?? '').toString();
    final city = (o['city'] ?? '').toString();
    final address = (o['address'] ?? '').toString();

    final payMethod = '${o['payment_method']}';
    final payStatus = '${o['payment_status']}';

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #$short'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _box('Status', [
          _row('Current status', _cap(status), bold: true),
          _row('Placed on', day),
          const SizedBox(height: 10),
          _timeline(status),
        ]),
        _box('Items', [
          for (final it in items)
            if (it is Map)
              _row(
                '${it['qty']} x ${it['name']}'
                '${it['seller'] == null ? '' : '\nSold by ${it['seller']}'}',
                tk((it['price'] as num? ?? 0) * (it['qty'] as num? ?? 1)),
              ),
        ]),
        _box('Delivery details', [
          if (name.isNotEmpty) _row('Name', name),
          if (phone.isNotEmpty) _row('Phone', phone),
          if (city.isNotEmpty) _row('City', city),
          if (address.isNotEmpty) _row('Address', address),
          if (name.isEmpty && phone.isEmpty && address.isEmpty)
            _row('City', city.isEmpty ? '-' : city),
        ]),
        _box('Payment', [
          _row('Method', _payLabel(payMethod)),
          _row('Payment status', _cap(payStatus)),
          const Divider(),
          _row('Items total', tk(subtotal)),
          _row('Delivery charge', tk(delivery)),
          _row('Total', tk(total), bold: true),
        ]),
      ]),
    );
  }
}