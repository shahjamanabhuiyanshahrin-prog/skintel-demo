import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/cart_service.dart';

// Delivery charge: inside Sylhet Tk 80, anywhere else in Bangladesh Tk 150.
const double kDeliveryInsideSylhet = 80;
const double kDeliveryOutsideSylhet = 150;

const List<String> kBangladeshCities = [
  'Bagerhat',
  'Bandarban',
  'Barguna',
  'Barishal',
  'Bhola',
  'Bogura',
  'Brahmanbaria',
  'Chandpur',
  'Chapainawabganj',
  'Chattogram',
  'Chuadanga',
  'Cumilla',
  'Cox\'s Bazar',
  'Dhaka',
  'Dinajpur',
  'Faridpur',
  'Feni',
  'Gaibandha',
  'Gazipur',
  'Gopalganj',
  'Habiganj',
  'Jamalpur',
  'Jashore',
  'Jhalokathi',
  'Jhenaidah',
  'Joypurhat',
  'Khagrachhari',
  'Khulna',
  'Kishoreganj',
  'Kurigram',
  'Kushtia',
  'Lakshmipur',
  'Lalmonirhat',
  'Madaripur',
  'Magura',
  'Manikganj',
  'Meherpur',
  'Moulvibazar',
  'Munshiganj',
  'Mymensingh',
  'Naogaon',
  'Narail',
  'Narayanganj',
  'Narsingdi',
  'Natore',
  'Netrokona',
  'Nilphamari',
  'Noakhali',
  'Pabna',
  'Panchagarh',
  'Patuakhali',
  'Pirojpur',
  'Rajbari',
  'Rajshahi',
  'Rangamati',
  'Rangpur',
  'Satkhira',
  'Shariatpur',
  'Sherpur',
  'Sirajganj',
  'Sunamganj',
  'Sylhet',
  'Tangail',
  'Thakurgaon',
];

// Bangladeshi mobile number: 11 digits, like 01712345678
// (starts with 01, third digit is 3 to 9)
final RegExp kBdPhone = RegExp(r'^01[3-9][0-9]{8}$');

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  String _pay = 'cod';
  String? _city;

  double? get _delivery => _city == null
      ? null
      : (_city == 'Sylhet' ? kDeliveryInsideSylhet : kDeliveryOutsideSylhet);
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  void _toast(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // Demo payment screens. Nothing is saved or sent anywhere.
  Future<bool> _demoPayment(double amount) async {
    if (_pay == 'cod') return true;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _pay == 'demo_bkash'
          ? _BkashSheet(amount: amount)
          : _CardSheet(amount: amount),
    );
    return ok == true;
  }

  Future<void> _place() async {
    final cart = CartService.instance;
    final digits = _phone.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (_name.text.trim().isEmpty) {
      _toast('Please enter your name.');
      return;
    }
    if (!kBdPhone.hasMatch(digits)) {
      _toast('Enter a valid phone number: 11 digits, like 01712345678.');
      return;
    }
    if (_city == null) {
      _toast('Please select your city.');
      return;
    }
    if (_address.text.trim().length < 5) {
      _toast('Please enter your full address.');
      return;
    }
    if (cart.isEmpty) {
      _toast('Your cart is empty.');
      return;
    }
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _toast('Please log in again.');
      return;
    }

    final delivery = _delivery!;
    final total = cart.total + delivery;

    // 1) demo payment (bKash / card)
    final paid = await _demoPayment(total);
    if (!paid) return;
    if (!mounted) return;

    // 2) save the order
    setState(() => _busy = true);
    String id;
    bool saved = true;
    try {
      final row = await Supabase.instance.client
          .from('orders')
          .insert({
            'user_id': user.id,
            'items': cart.items.map((e) => e.toJson()).toList(),
            'subtotal': cart.total,
            'delivery_charge': delivery,
            'total': total,
            'city': _city,
            'name': _name.text.trim(),
            'phone': digits,
            'address': _address.text.trim(),
            'payment_method': _pay,
            'payment_status': _pay == 'cod' ? 'pay_on_delivery' : 'paid_demo',
          })
          .select('id')
          .single();
      id = row['id'].toString();
    } catch (e) {
      // Demo mode: still show "Order placed", but tell the truth on screen.
      debugPrint('ORDER SAVE ERROR: $e');
      id = 'DEMO${DateTime.now().millisecondsSinceEpoch}';
      saved = false;
    }

    cart.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (_) =>
              OrderPlacedScreen(orderId: id, total: total, saved: saved)),
    );
  }

  InputDecoration _dec(String label, {String? hint}) => InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF5EFEC),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
      );

  @override
  Widget build(BuildContext context) {
    final cart = CartService.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Delivery details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        TextField(controller: _name, decoration: _dec('Full name')),
        const SizedBox(height: 12),
        TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            decoration: _dec('Phone number', hint: '01XXXXXXXXX')),
        const SizedBox(height: 12),
        DropdownMenu<String>(
          width: MediaQuery.of(context).size.width - 32,
          enableFilter: true,
          requestFocusOnTap: true,
          label: const Text('City / District'),
          menuHeight: 300,
          onSelected: (v) => setState(() => _city = v),
          dropdownMenuEntries: [
            for (final city in kBangladeshCities)
              DropdownMenuEntry<String>(value: city, label: city),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
            'Delivery: Tk 80 inside Sylhet, Tk 150 outside Sylhet (all Bangladesh).',
            style: TextStyle(fontSize: 11, color: Colors.black54)),
        const SizedBox(height: 12),
        TextField(
            controller: _address,
            maxLines: 3,
            decoration: _dec('Full address (area, road, house)')),
        const SizedBox(height: 24),
        const Text('Payment',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        RadioListTile<String>(
          contentPadding: EdgeInsets.zero,
          value: 'cod',
          groupValue: _pay,
          onChanged: (v) => setState(() => _pay = v!),
          title: const Text('Cash on delivery'),
        ),
        RadioListTile<String>(
          contentPadding: EdgeInsets.zero,
          value: 'demo_bkash',
          groupValue: _pay,
          onChanged: (v) => setState(() => _pay = v!),
          title: const Text('bKash (demo)'),
        ),
        RadioListTile<String>(
          contentPadding: EdgeInsets.zero,
          value: 'demo_card',
          groupValue: _pay,
          onChanged: (v) => setState(() => _pay = v!),
          title: const Text('Card (demo)'),
        ),
        if (_pay != 'cod')
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
                'Demo payment: this is a prototype. No real money is taken. Use fake numbers only.',
                style: TextStyle(fontSize: 12, color: Colors.black54)),
          ),
        const Divider(height: 32),
        Row(children: [
          const Text('Subtotal', style: TextStyle(fontSize: 13)),
          const Spacer(),
          Text(tk(cart.total), style: const TextStyle(fontSize: 13)),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          const Text('Delivery', style: TextStyle(fontSize: 13)),
          const Spacer(),
          Text(_delivery == null ? 'Select city' : tk(_delivery!),
              style: const TextStyle(fontSize: 13)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          const Text('Total', style: TextStyle(fontSize: 14)),
          const Spacer(),
          Text(tk(cart.total + (_delivery ?? 0)),
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _busy ? null : _place,
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26))),
          child: _busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Text(_pay == 'cod' ? 'Place order' : 'Continue to payment'),
        ),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
// bKash demo payment
// Step 1: enter the bKash number.
// Step 2: enter the PIN, then press "Payment is done".
// ---------------------------------------------------------------------------
class _BkashSheet extends StatefulWidget {
  final double amount;
  const _BkashSheet({required this.amount});
  @override
  State<_BkashSheet> createState() => _BkashSheetState();
}

class _BkashSheetState extends State<_BkashSheet> {
  static const Color pink = Color(0xFFE2136E);
  final _number = TextEditingController();
  final _pin = TextEditingController();
  int _step = 0; // 0 = number, 1 = PIN
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _number.dispose();
    _pin.dispose();
    super.dispose();
  }

  void _back() {
    if (_busy) return;
    if (_step == 1) {
      setState(() {
        _step = 0;
        _error = null;
        _pin.clear();
      });
    } else {
      Navigator.pop(context, false);
    }
  }

  Future<void> _next() async {
    if (_step == 0) {
      final n = _number.text.trim();
      if (!kBdPhone.hasMatch(n)) {
        setState(() => _error =
            'Enter a valid bKash number (11 digits, like 01712345678).');
        return;
      }
      setState(() {
        _error = null;
        _step = 1;
      });
    } else {
      if (_pin.text.length != 5) {
        setState(() => _error = 'Enter a 5 digit PIN.');
        return;
      }
      setState(() {
        _error = null;
        _busy = true;
      });
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              IconButton(
                onPressed: _busy ? null : _back,
                icon: const Icon(Icons.arrow_back),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              const Spacer(),
            ]),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: pink, borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                const Text('bKash',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900)),
                const Spacer(),
                Text(tk(widget.amount),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
              ]),
            ),
            const SizedBox(height: 16),
            if (_step == 0) ...[
              const Text('Enter your bKash number',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              TextField(
                controller: _number,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                decoration: InputDecoration(
                  hintText: '01XXXXXXXXX',
                  filled: true,
                  fillColor: const Color(0xFFF5EFEC),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none),
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: const Color(0xFFF5EFEC),
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('bKash number',
                          style:
                              TextStyle(fontSize: 11, color: Colors.black54)),
                      const SizedBox(height: 2),
                      Text(_number.text.trim(),
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      const Text('Amount',
                          style:
                              TextStyle(fontSize: 11, color: Colors.black54)),
                      const SizedBox(height: 2),
                      Text(tk(widget.amount),
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                    ]),
              ),
              const SizedBox(height: 16),
              const Text('Enter your bKash PIN',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              TextField(
                controller: _pin,
                obscureText: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(5),
                ],
                decoration: InputDecoration(
                  hintText: '5 digit PIN',
                  filled: true,
                  fillColor: const Color(0xFFF5EFEC),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none),
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!,
                  style: const TextStyle(fontSize: 12, color: Colors.red)),
            ],
            const SizedBox(height: 8),
            const Text('Demo only. Use a fake number and a fake PIN.',
                style: TextStyle(fontSize: 11, color: Colors.black54)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _busy ? null : _next,
              style: ElevatedButton.styleFrom(
                  backgroundColor: pink,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25))),
              child: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(_step == 0 ? 'Next' : 'Payment is done'),
            ),
          ]),
    );
  }
}

// ---------------------------------------------------------------------------
// Card demo payment (card details + back arrow)
// ---------------------------------------------------------------------------
class _CardSheet extends StatefulWidget {
  final double amount;
  const _CardSheet({required this.amount});
  @override
  State<_CardSheet> createState() => _CardSheetState();
}

class _CardSheetState extends State<_CardSheet> {
  final _holder = TextEditingController();
  final _number = TextEditingController();
  final _expiry = TextEditingController();
  final _cvv = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _holder.dispose();
    _number.dispose();
    _expiry.dispose();
    _cvv.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, {String? hint}) => InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF5EFEC),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
      );

  Future<void> _pay() async {
    if (_holder.text.trim().isEmpty) {
      setState(() => _error = 'Enter the name on the card.');
      return;
    }
    if (_number.text.length != 16) {
      setState(() => _error = 'Card number must be 16 digits.');
      return;
    }
    if (!RegExp(r'^(0[1-9]|1[0-2])/[0-9]{2}$').hasMatch(_expiry.text.trim())) {
      setState(() => _error = 'Expiry must look like 08/28.');
      return;
    }
    if (_cvv.text.length != 3) {
      setState(() => _error = 'CVV must be 3 digits.');
      return;
    }
    setState(() {
      _error = null;
      _busy = true;
    });
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              IconButton(
                onPressed: _busy ? null : () => Navigator.pop(context, false),
                icon: const Icon(Icons.arrow_back),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              const Spacer(),
            ]),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.black, borderRadius: BorderRadius.circular(14)),
              child: Row(children: [
                const Icon(Icons.credit_card, color: Colors.white),
                const SizedBox(width: 10),
                const Text('Card payment',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
                const Spacer(),
                Text(tk(widget.amount),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
              ]),
            ),
            const SizedBox(height: 16),
            TextField(controller: _holder, decoration: _dec('Name on card')),
            const SizedBox(height: 12),
            TextField(
              controller: _number,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
              ],
              decoration: _dec('Card number', hint: '16 digits'),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _expiry,
                  keyboardType: TextInputType.datetime,
                  inputFormatters: [LengthLimitingTextInputFormatter(5)],
                  decoration: _dec('Expiry', hint: 'MM/YY'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _cvv,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  decoration: _dec('CVV', hint: '3 digits'),
                ),
              ),
            ]),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!,
                  style: const TextStyle(fontSize: 12, color: Colors.red)),
            ],
            const SizedBox(height: 8),
            const Text(
                'Demo only. Use fake numbers. Do not type your real card.',
                style: TextStyle(fontSize: 11, color: Colors.black54)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _busy ? null : _pay,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25))),
              child: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text('Pay ${tk(widget.amount)}'),
            ),
          ]),
    );
  }
}

// ---------------------------------------------------------------------------
// Order placed
// ---------------------------------------------------------------------------
class OrderPlacedScreen extends StatelessWidget {
  final String orderId;
  final double total;
  final bool saved;
  const OrderPlacedScreen(
      {super.key,
      required this.orderId,
      required this.total,
      this.saved = true});

  @override
  Widget build(BuildContext context) {
    final short = orderId.length > 8 ? orderId.substring(0, 8) : orderId;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.check_circle_outline, size: 72),
            const SizedBox(height: 16),
            const Text('Order placed',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Order #${short.toUpperCase()}  ·  ${tk(total)}',
                style: const TextStyle(color: Colors.black54)),
            if (!saved) ...[
              const SizedBox(height: 12),
              const Text('Demo order: it was not saved in the database.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.black54)),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home', (route) => false),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24))),
              child: const Text('Back to home'),
            ),
          ]),
        ),
      ),
    );
  }
}