import 'package:flutter/material.dart';
import '../services/home_service.dart';
import 'face_scan_screen.dart';
import 'dermatologist_screen.dart';
import 'products_screen.dart';
import 'explore_screen.dart';
import 'profile_screen.dart';
import 'chatbot_screen.dart';
import 'notifications_screen.dart';
import 'skin_profile_screen.dart';
import 'orders_screen.dart';
import 'home_remedy_screen.dart';

const _bg = Color(0xFFF5EFEC);
const _dark = Color(0xFF111111);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<HomeData> _future;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _future = HomeService().fetchHomeData();
  }

  void _push(Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  void _openScan() => _push(const FaceScanScreen());
  void _openDerm() => _push(const DermatologistScreen());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(children: [
          FutureBuilder<HomeData>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError || !snap.hasData) {
                return Center(
                  child: TextButton(
                    onPressed: () => setState(
                        () => _future = HomeService().fetchHomeData()),
                    child: const Text('Something went wrong. Retry'),
                  ),
                );
              }
              return _content(snap.data!);
            },
          ),
          Positioned(
              right: 16,
              bottom: 12,
              child: _ChatBotButton(
                  onTap: () => _push(const ChatBotScreen()))),
        ]),
      ),
      // Scan button floats ABOVE the bar, in the center.
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _openScan,
          backgroundColor: _dark,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.center_focus_strong, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE6DAD4))),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                _nav(Icons.home_outlined, 'Home', 0),
                _nav(Icons.receipt_long_outlined, 'Orders', 4),
                _nav(Icons.inventory_2_outlined, 'Products', 1),
                _nav(Icons.explore_outlined, 'Explore', 2),
                _nav(Icons.person_outline, 'Profile', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _nav(IconData icon, String label, int i) {
    final active = _tab == i;
    return Expanded(
      child: InkWell(
        onTap: () {
          if (i == 1) _push(const ProductsScreen());
          if (i == 2) _push(const ExploreScreen());
          if (i == 3) _push(const ProfileScreen());
          if (i == 4) _push(const OrdersScreen());
        },
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: active ? _dark : Colors.grey, size: 22),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      fontSize: 10, color: active ? _dark : Colors.grey)),
            ]),
      ),
    );
  }

  Widget _content(HomeData d) {
    return ListView(padding: const EdgeInsets.only(bottom: 90), children: [
      // Header
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Skintel',
                style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            IconButton(
                onPressed: () => _push(const NotificationsScreen()),
                icon: const Icon(Icons.notifications_none, size: 22)),
          ],
        ),
      ),
      // Scan hero
      SizedBox(
        height: 240,
        child: Stack(alignment: Alignment.center, children: [
          Positioned.fill(
              child: _img('assets/images/face_scan_pic.jpg', fit: BoxFit.cover)),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1.5)),
          ),
          Positioned(
            bottom: 0,
            child: GestureDetector(
              onTap: _openScan,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 36, vertical: 10),
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: const Text('Tap to scan',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              ),
            ),
          ),
        ]),
      ),
      _title('Range of products'),
      SizedBox(
        height: 110,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: d.products.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) => _productCard(d.products[i]),
        ),
      ),
      _title('Male Grooming'),
      SizedBox(
        height: 96,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: d.grooming.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) => _groomingCard(d.grooming[i]),
        ),
      ),
      _title('Consult Dermatologist'),
      SizedBox(
        height: 150,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: d.dermatologists.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) => _dermCard(d.dermatologists[i]),
        ),
      ),
      _title('Know your skin'),
      _knowSkin(),
      _title('Home Remedy'),
      _homeRemedyCard(),
      _title('Our results'),
      SizedBox(
        height: 150,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: d.reviews.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) => _reviewCard(d.reviews[i]),
        ),
      ),
    ]);
  }

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
        child: Text(t,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      );

  BoxDecoration get _card => BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE6DAD4)),
      );

  Widget _btn(String t, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
          decoration: BoxDecoration(
              color: _dark, borderRadius: BorderRadius.circular(20)),
          child: Text(t,
              style: const TextStyle(color: Colors.white, fontSize: 11)),
        ),
      );

  Widget _productCard(SkinProduct p) => Container(
        width: 210,
        padding: const EdgeInsets.all(12),
        decoration: _card,
        child: Row(children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(p.title, style: const TextStyle(fontSize: 10)),
                  _btn('Explore', () => _push(ProductsScreen(skinType: p.label))),
                ]),
          ),
          CircleAvatar(
            radius: 26,
            backgroundColor: p.color,
            child: Text(p.label,
                style: const TextStyle(color: Colors.white, fontSize: 11)),
          ),
        ]),
      );

  Widget _groomingCard(GroomingItem g) => GestureDetector(
        onTap: () => _push(ProductsScreen(category: g.keyword, title: g.title)),
        child: Container(
          width: 96,
          decoration: _card,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                    radius: 18,
                    backgroundColor: _dark,
                    child: Icon(g.icon, size: 18, color: Colors.white)),
                const SizedBox(height: 8),
                Text(g.title,
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w600)),
              ]),
        ),
      );

  Widget _dermCard(Dermatologist d) => Container(
        width: 300,
        padding: const EdgeInsets.all(12),
        decoration: _card,
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
                width: 90,
                height: double.infinity,
                child: _img(d.image, fit: BoxFit.cover)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(d.name,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(d.title, style: const TextStyle(fontSize: 10)),
                  Text(d.experience, style: const TextStyle(fontSize: 10)),
                  const SizedBox(height: 6),
                  _stars(d.rating),
                  const SizedBox(height: 8),
                  _btn('Know more', _openDerm),
                ]),
          ),
        ]),
      );

  Widget _stars(double r) => Row(children: [
        ...List.generate(
            5, (_) => const Icon(Icons.star, size: 13, color: Colors.black)),
        const SizedBox(width: 4),
        Text(r.toStringAsFixed(1), style: const TextStyle(fontSize: 10)),
      ]);

  Widget _knowSkin() => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        height: 130,
        decoration: _card,
        child: Row(children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Let's personalize\nyour profile",
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700)),
                  _btn('Start now', () => _push(const SkinProfileScreen())),
                ]),
          ),
          const Icon(Icons.person_search, size: 70, color: Color(0xFF1B1B3A)),
        ]),
      );

  Widget _homeRemedyCard() {
    return GestureDetector(
      onTap: () => _push(const HomeRemedyScreen()),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        height: 125,
        decoration: _card,
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Simple skincare tips at home',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Discover safe home care for your skin.',
                    style: TextStyle(fontSize: 10),
                  ),
                  Text(
                    'Explore remedies →',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.spa_outlined,
              size: 65,
              color: Color(0xFF1B1B3A),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reviewCard(Review r) => Container(
        width: 210,
        padding: const EdgeInsets.all(12),
        decoration: _card,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.brown.shade300,
                    child: Text(r.name[0],
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11))),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(r.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700))),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                ...List.generate(5,
                    (_) => const Icon(Icons.star, size: 13, color: Colors.amber)),
                const SizedBox(width: 4),
                Text(r.rating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 10)),
              ]),
              const SizedBox(height: 8),
              Text(r.text,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10)),
            ]),
      );

  // Supports both asset images and network images
  Widget _img(String path, {BoxFit fit = BoxFit.cover}) {
    final fallback = Container(color: Colors.grey.shade300);
    if (path.startsWith('http')) {
      return Image.network(path,
          fit: fit, errorBuilder: (_, __, ___) => fallback);
    }
    return Image.asset(path, fit: fit, errorBuilder: (_, __, ___) => fallback);
  }
}

class _ChatBotButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ChatBotButton({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: const [
        CircleAvatar(
          radius: 22,
          backgroundColor: Color(0xFFE3F0FA),
          child: Icon(Icons.smart_toy_outlined, color: Color(0xFF1565C0)),
        ),
        SizedBox(height: 2),
        Text('ChatBot',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1565C0))),
      ]),
    );
  }
}