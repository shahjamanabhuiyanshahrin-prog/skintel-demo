import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/cart_service.dart';
import '../services/order_history_service.dart';

const List<String> kCities = [
  'Bagerhat', 'Bandarban', 'Barguna', 'Barishal', 'Bhola', 'Bogura',
  'Brahmanbaria', 'Chandpur', 'Chapainawabganj', 'Chattogram', 'Chuadanga',
  'Cumilla', "Cox's Bazar", 'Dhaka', 'Dinajpur', 'Faridpur', 'Feni',
  'Gaibandha', 'Gazipur', 'Gopalganj', 'Habiganj', 'Jamalpur', 'Jashore',
  'Jhalokathi', 'Jhenaidah', 'Joypurhat', 'Khagrachhari', 'Khulna',
  'Kishoreganj', 'Kurigram', 'Kushtia', 'Lakshmipur', 'Lalmonirhat',
  'Madaripur', 'Magura', 'Manikganj', 'Meherpur', 'Moulvibazar', 'Munshiganj',
  'Mymensingh', 'Naogaon', 'Narail', 'Narayanganj', 'Narsingdi', 'Natore',
  'Netrokona', 'Nilphamari', 'Noakhali', 'Pabna', 'Panchagarh', 'Patuakhali',
  'Pirojpur', 'Rajbari', 'Rajshahi', 'Rangamati', 'Rangpur', 'Satkhira',
  'Shariatpur', 'Sherpur', 'Sirajganj', 'Sunamganj', 'Sylhet', 'Tangail',
  'Thakurgaon',
];

double deliveryFor(String? city) => city == 'Sylhet' ? 80 : 150;

InputDecoration _dec(String label) => InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF5EFEC),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    );

ButtonStyle _black() => ElevatedButton.styleFrom(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    minimumSize: const Size.fromHeight(50),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)));

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  String? _city;
  String _pay = 'cod';
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  void _say(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  // ---------------- City search ----------------
  Future<void> _pickCity() async {
    FocusScope.of(context).unfocus();
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        var query = '';
        return StatefulBuilder(
          builder: (ctx, setS) {
            final list = kCities
                .where((c) => c.toLowerCase().contains(query.toLowerCase()))
                .toList();
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.75,
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 12, 16, 4),
                    child: Row(children: [
                      IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(ctx)),
                      const Text('Choose city / district',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16)),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: TextField(
                      autofocus: true,
                      onChanged: (v) => setS(() => query = v.trim()),
                      decoration: _dec('Search city / district')
                          .copyWith(prefixIcon: const Icon(Icons.search)),
                    ),
                  ),
                  Expanded(
                    child: list.isEmpty
                        ? const Center(
                            child: Text('No city found.',
                                style: TextStyle(color: Colors.black54)))
                        : ListView.builder(
                            itemCount: list.length,
                            itemBuilder: (_, i) {
                              final c = list[i];
                              return ListTile(
                                title: Text(c),
                                trailing: c == _city
                                    ? const Icon(Icons.check,
                                        color: Colors.green)
                                    : null,
                                onTap: () => Navigator.pop(ctx, c),
                              );
                            },
                          ),
                  ),
                ]),
              ),
            );
          },
        );
      },
    );
    if (picked != null) setState(() => _city = picked);
  }

  Future<void> _start() async {
    if (_name.text.trim().length < 2) return _say('Please enter your name.');
    if (!RegExp(r'^01[3-9][0-9]{8}$').hasMatch(_phone.text.trim())) {
      return _say('Enter a valid Bangladeshi number (11 digits, like 01712345678).');
    }
    if (_city == null) return _say('Please choose your city.');
    if (_address.text.trim().length < 5) return _say('Please enter your full address.');

    final delivery = deliveryFor(_city);
    final total = CartService.instance.total + delivery;

    if (_pay == 'bkash') {
      final ok = await _bkashSheet(total);
      if (ok != true) return;
    } else if (_pay == 'card') {
      final ok = await _cardSheet(total);
      if (ok != true) return;
    }
    await _place(delivery, total);
  }

  Future<void> _place(double delivery, double total) async {
    setState(() => _busy = true);
    final cart = CartService.instance;
    final items = <Map<String, dynamic>>[
      for (final it in cart.items)
        {
          'offer_id': it.offerId,
          'name': it.name,
          'seller': it.sellerName,
          'price': it.price,
          'qty': it.qty,
        }
    ];
    final method = _pay == 'cod' ? 'cod' : 'demo_$_pay';
    final payStatus = _pay == 'cod' ? 'pending' : 'paid';
    var saved = true;
    try {
      await Supabase.instance.client.from('orders').insert({
        'user_id': Supabase.instance.client.auth.currentUser?.id,
        'name': _name.text.trim(),
        'phone': _phone.text.trim(),
        'city': _city,
        'address': _address.text.trim(),
        'items': items,
        'delivery_charge': delivery,
        'total': total,
        'payment_method': method,
        'payment_status': payStatus,
        'status': 'pending',
      });
    } catch (e) {
      saved = false;
      debugPrint('ORDER SAVE ERROR: $e');
    }
    // Always remember the order inside the app so My orders shows it.
    OrderHistory.instance.add(
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      address: _address.text.trim(),
      city: _city!,
      items: items,
      delivery: delivery,
      total: total,
      paymentMethod: method,
      paymentStatus: payStatus,
      saved: saved,
    );
    cart.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => _PlacedScreen(
                total: total, city: _city!, delivery: delivery)));
  }

  // ---------------- bKash ----------------
  Future<bool?> _bkashSheet(double total) {
    final number = TextEditingController();
    final pin = TextEditingController();
    var step = 1;
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () =>
                      step == 2 ? setS(() => step = 1) : Navigator.pop(ctx)),
              const Text('bKash payment',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ]),
            const SizedBox(height: 12),
            Text('Amount: ${tk(total)}',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            if (step == 1) ...[
              TextField(
                  controller: number,
                  keyboardType: TextInputType.number,
                  maxLength: 11,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _dec('Your bKash number')),
              ElevatedButton(
                style: _black(),
                onPressed: () {
                  if (!RegExp(r'^01[3-9][0-9]{8}$').hasMatch(number.text)) {
                    _say('Enter a valid 11 digit bKash number.');
                    return;
                  }
                  setS(() => step = 2);
                },
                child: const Text('Next'),
              ),
            ] else ...[
              TextField(
                  controller: pin,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _dec('bKash PIN (5 digits)')),
              ElevatedButton(
                style: _black(),
                onPressed: () {
                  if (pin.text.length != 5) {
                    _say('PIN must be 5 digits.');
                    return;
                  }
                  Navigator.pop(ctx, true);
                },
                child: const Text('Payment is done'),
              ),
            ],
          ]),
        ),
      ),
    );
  }

  // ---------------- Card ----------------
  Future<bool?> _cardSheet(double total) {
    final holder = TextEditingController();
    final cardNum = TextEditingController();
    final exp = TextEditingController();
    final cvv = TextEditingController();
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(ctx)),
              const Text('Card payment',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ]),
            const SizedBox(height: 12),
            TextField(controller: holder, decoration: _dec('Name on card')),
            const SizedBox(height: 10),
            TextField(
                controller: cardNum,
                keyboardType: TextInputType.number,
                maxLength: 16,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _dec('Card number (16 digits)')),
            Row(children: [
              Expanded(
                child: TextField(
                    controller: exp,
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                    onChanged: (v) {
                      if (v.length == 2 && !v.contains('/')) {
                        exp.text = '$v/';
                        exp.selection =
                            TextSelection.collapsed(offset: exp.text.length);
                      }
                    },
                    decoration: _dec('Expiry MM/YY')),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                    controller: cvv,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _dec('CVV')),
              ),
            ]),
            ElevatedButton(
              style: _black(),
              onPressed: () {
                if (holder.text.trim().length < 2) {
                  _say('Enter the name on the card.');
                  return;
                }
                if (cardNum.text.length != 16) {
                  _say('Card number must be 16 digits.');
                  return;
                }
                if (!RegExp(r'^(0[1-9]|1[0-2])/[0-9]{2}$').hasMatch(exp.text)) {
                  _say('Expiry must be like 08/28.');
                  return;
                }
                if (cvv.text.length != 3) {
                  _say('CVV must be 3 digits.');
                  return;
                }
                Navigator.pop(ctx, true);
              },
              child: Text('Pay ${tk(total)}'),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _payTile(String value, String label, IconData icon) {
    return RadioListTile<String>(
      value: value,
      groupValue: _pay,
      onChanged: (v) => setState(() => _pay = v!),
      title: Text(label),
      secondary: Icon(icon),
      contentPadding: EdgeInsets.zero,
      activeColor: Colors.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartService.instance;
    final delivery = deliveryFor(_city);
    final total = cart.total + delivery;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(controller: _name, decoration: _dec('Full name')),
        const SizedBox(height: 12),
        TextField(
            controller: _phone,
            keyboardType: TextInputType.number,
            maxLength: 11,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _dec('Phone (11 digits, 01XXXXXXXXX)')),
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: _pickCity,
          child: InputDecorator(
            decoration: _dec('City / District')
                .copyWith(suffixIcon: const Icon(Icons.search)),
            child: Text(
              _city ?? 'Tap to search and choose',
              style: TextStyle(
                  fontSize: 16,
                  color: _city == null ? Colors.black45 : Colors.black),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
            controller: _address,
            maxLines: 2,
            decoration: _dec('Full address')),
        const SizedBox(height: 16),
        const Text('Payment',
            style: TextStyle(fontWeight: FontWeight.w800)),
        _payTile('cod', 'Cash on delivery', Icons.payments_outlined),
        _payTile('bkash', 'bKash', Icons.phone_android),
        _payTile('card', 'Card', Icons.credit_card),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: const Color(0xFFF5EFEC),
              borderRadius: BorderRadius.circular(10)),
          child: Column(children: [
            Row(children: [
              const Text('Items'),
              const Spacer(),
              Text(tk(cart.total)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Text(_city == null
                  ? 'Delivery (choose city)'
                  : 'Delivery ($_city)'),
              const Spacer(),
              Text(tk(delivery)),
            ]),
            const Divider(),
            Row(children: [
              const Text('Total',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              const Spacer(),
              Text(tk(total),
                  style: const TextStyle(fontWeight: FontWeight.w800)),
            ]),
          ]),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: _black(),
          onPressed: _busy || cart.isEmpty ? null : _start,
          child: _busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('Place order'),
        ),
      ]),
    );
  }
}

class _PlacedScreen extends StatelessWidget {
  final double total;
  final double delivery;
  final String city;
  const _PlacedScreen(
      {required this.total, required this.delivery, required this.city});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            const Text('Order placed',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Total ${tk(total)} (delivery to $city: ${tk(delivery)})',
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            const Text('Status: Pending',
                style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 28),
            ElevatedButton(
              style: _black(),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (r) => false),
              child: const Text('Back to home'),
            ),
          ]),
        ),
      ),
    );
  }
}