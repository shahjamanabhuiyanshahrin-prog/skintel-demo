import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/onboarding_service.dart';
import 'products_screen.dart';

class _Tip {
  final String title;
  final String summary;
  final String body;
  final String category;
  final String skin; // 'All' or a skin type
  final String? product; // search words for the product suggestion
  const _Tip(this.title, this.summary, this.body, this.category, this.skin,
      [this.product]);
}

class _Video {
  final String title;
  final String subtitle;
  final String query;
  final IconData icon;
  final Color color;
  const _Video(this.title, this.subtitle, this.query, this.icon, this.color);
}

const List<_Video> _videos = [
  _Video(
      'How to prep skin before makeup',
      'For every skin type',
      'how to prep skin before makeup for all skin types',
      Icons.brush,
      Color(0xFF8E6C88)),
];

Color _catColor(String c) {
  switch (c) {
    case 'Sunscreen':
      return const Color(0xFFE0A030);
    case 'Lifestyle':
      return const Color(0xFF5E9E6E);
    case 'Routine':
      return const Color(0xFF8E6C88);
    case 'Safety':
      return const Color(0xFFC0594F);
    case 'Moisturizer':
      return const Color(0xFF6C7FB8);
    case 'Cleanser':
      return const Color(0xFF3E8E9E);
    case 'Ingredients':
      return const Color(0xFF9A6B3F);
    case 'Fact':
      return const Color(0xFF4A6FA5);
    case 'Myth':
      return const Color(0xFFB5536B);
    case 'Skin health':
      return const Color(0xFFB07A5A);
    case 'Men':
      return const Color(0xFF3B4A5A);
    default:
      return const Color(0xFF777777);
  }
}

IconData _catIcon(String c) {
  switch (c) {
    case 'Sunscreen':
      return Icons.wb_sunny_outlined;
    case 'Lifestyle':
      return Icons.self_improvement;
    case 'Routine':
      return Icons.checklist;
    case 'Safety':
      return Icons.health_and_safety_outlined;
    case 'Moisturizer':
      return Icons.opacity;
    case 'Cleanser':
      return Icons.bubble_chart;
    case 'Ingredients':
      return Icons.science_outlined;
    case 'Fact':
      return Icons.auto_awesome;
    case 'Myth':
      return Icons.help_outline;
    case 'Skin health':
      return Icons.favorite_border;
    case 'Men':
      return Icons.face_6;
    default:
      return Icons.lightbulb_outline;
  }
}

const List<_Tip> _tips = [
  // ---------------- General (All) ----------------
  _Tip(
      'Always wear sunscreen',
      'The most important step for every skin type.',
      'Use a broad-spectrum sunscreen with SPF 30 or higher every morning, even on cloudy days. Apply it as the last step of your morning routine and reapply every 2 to 3 hours if you are outside. Sun damage causes dark spots, early wrinkles and uneven skin tone.',
      'Sunscreen',
      'All',
      'sunscreen SPF 50 face'),
  _Tip(
      'Drink enough water',
      'Hydrated skin looks fresh and healthy.',
      'Aim for around 2 litres of water a day. Water alone will not fix dry skin, but dehydration can make skin look dull and tired. Eat fruits and vegetables too.',
      'Lifestyle',
      'All'),
  _Tip(
      'Never sleep with makeup on',
      'It clogs pores and causes breakouts.',
      'Remove makeup and sunscreen every night before bed. Use a gentle cleanser, or a cleansing balm first if you wear heavy makeup. Change your pillowcase once a week.',
      'Routine',
      'All',
      'cleansing balm makeup remover'),
  _Tip(
      'Patch test new products',
      'Avoid reactions before they happen.',
      'Apply a small amount of a new product behind your ear or on your inner arm for 24 hours. If you see redness, itching or burning, do not use it on your face.',
      'Safety',
      'All'),
  _Tip(
      'Skin is your largest organ',
      'It covers your whole body and protects it.',
      'Your skin is the largest organ of the body. It protects you from germs, helps control body temperature and senses touch. Looking after it is about health, not just looks.',
      'Fact',
      'All'),
  _Tip(
      'Skin renews itself',
      'Roughly every 4 weeks in young adults.',
      'Skin cells move from the lower layers to the surface and shed. This cycle takes about 28 days in young adults and gets slower with age. This is why a new product needs 4 to 6 weeks before you judge it.',
      'Fact',
      'All'),
  _Tip(
      'Oily skin can still be dehydrated',
      'Oil and water are not the same thing.',
      'Skin type (dry, oily) is about oil. Dehydration is about water. Oily skin can lack water too, and it may feel tight and look dull. A light hydrating gel or hyaluronic acid helps.',
      'Fact',
      'All',
      'hyaluronic acid serum'),
  _Tip(
      'Higher SPF is not all-day protection',
      'SPF 30 blocks about 97% of UVB rays.',
      'SPF 50 blocks about 98%, so the gain is small. What matters more is using enough and reapplying every 2 to 3 hours. Look for the words broad-spectrum on the label.',
      'Fact',
      'All',
      'broad spectrum sunscreen SPF 30'),
  _Tip(
      'UVA rays pass through windows',
      'You need sunscreen indoors near windows too.',
      'UVB rays cause sunburn and are mostly blocked by glass. UVA rays go through glass and clouds and cause ageing and dark spots. Wear sunscreen if you sit near a window for long.',
      'Fact',
      'All',
      'broad spectrum sunscreen SPF 50'),
  _Tip(
      'Myth: pores open and close',
      'Pores do not have muscles.',
      'Warm water does not open pores and cold water does not close them. Pore size is mostly genetic. You can make pores look smaller by keeping them clean, using sunscreen and using ingredients like niacinamide.',
      'Myth',
      'All'),
  _Tip(
      'Myth: expensive means better',
      'Ingredients matter more than the price.',
      'A simple, affordable cleanser, moisturizer and sunscreen from a trusted brand can work as well as a luxury one. Check the ingredient list and whether it suits your skin type.',
      'Myth',
      'All'),
  _Tip(
      'Myth: dark skin does not need sunscreen',
      'Everyone can get sun damage.',
      'Darker skin has more natural protection but it is not complete. Sun can still cause dark spots, uneven tone and skin cancer. Everyone should use sunscreen.',
      'Myth',
      'All',
      'sunscreen no white cast'),
  _Tip(
      'Myth: toothpaste cures pimples',
      'It can burn and irritate your skin.',
      'Toothpaste has ingredients that are not made for skin and can cause redness, dryness and burns. Use a product with salicylic acid or benzoyl peroxide instead.',
      'Myth',
      'All',
      'benzoyl peroxide acne spot treatment'),
  _Tip(
      'Do not pop pimples',
      'It can cause scars and spread bacteria.',
      'Squeezing pushes bacteria deeper and can leave marks that last for months. Use a spot treatment and be patient. See a dermatologist for painful or frequent breakouts.',
      'Skin health',
      'All',
      'salicylic acid spot treatment'),
  _Tip(
      'Your phone is dirty',
      'It touches your cheek many times a day.',
      'Phones collect bacteria and oil. Wipe your phone with an alcohol wipe every day and try not to touch your face with unwashed hands. This helps with breakouts.',
      'Fact',
      'All'),
  _Tip(
      'Sleep is skin repair time',
      'Poor sleep can show on your face.',
      'Your skin repairs itself while you sleep. Too little sleep can lead to dull skin and dark circles. Aim for 7 to 9 hours.',
      'Lifestyle',
      'All'),

  // ---------------- Dry skin ----------------
  _Tip(
      'Moisturize while skin is damp',
      'Locks in moisture for longer.',
      'Apply a thick, fragrance-free moisturizer within a few minutes after washing your face. Look for ceramides, glycerin or hyaluronic acid. Avoid hot water, which dries skin out.',
      'Moisturizer',
      'Dry',
      'ceramide moisturizer for dry skin'),
  _Tip(
      'Use a gentle, creamy cleanser',
      'Harsh foaming washes strip dry skin.',
      'Choose a creamy or milky cleanser and wash once or twice a day with lukewarm water. Pat your face dry instead of rubbing.',
      'Cleanser',
      'Dry',
      'creamy gentle face cleanser for dry skin'),
  _Tip(
      'Use heavier cream at night, lighter by day',
      'Dry skin loses more water at night.',
      'A richer night cream helps dry skin recover. In the morning use a lighter moisturizer under sunscreen.',
      'Routine',
      'Dry',
      'night cream for dry skin'),
  _Tip(
      'Add a hydrating serum',
      'Water first, cream second.',
      'A hyaluronic acid or glycerin serum pulls water into the skin. Apply it on damp skin, then seal it in with a moisturizer. Without a cream on top, the serum can evaporate and leave skin even drier.',
      'Ingredients',
      'Dry',
      'hyaluronic acid serum for dry skin'),
  _Tip(
      'Keep showers short and lukewarm',
      'Hot water removes natural oils.',
      'Long, hot showers strip the oils your skin needs. Keep showers under 10 minutes, use lukewarm water, and apply body lotion within 3 minutes of drying off.',
      'Lifestyle',
      'Dry',
      'body lotion for dry skin'),
  _Tip(
      'Choose fragrance-free products',
      'Perfume can irritate dry, sensitive skin.',
      'Fragrance and strong alcohol are common causes of stinging and redness on dry skin. Pick products marked fragrance-free and alcohol-free, especially toners and cleansers.',
      'Safety',
      'Dry',
      'fragrance free moisturizer'),
  _Tip(
      'Do not scrub flaky skin',
      'Scrubbing makes dryness worse.',
      'Flaky patches need moisture, not rough scrubs. Use a gentle lactic acid exfoliant once a week at most, and always follow with a rich moisturizer.',
      'Routine',
      'Dry',
      'lactic acid gentle exfoliant'),
  _Tip(
      'Protect your lips and hands',
      'They dry out first.',
      'Lips and hands have very few oil glands. Use a lip balm with petrolatum or shea butter, and apply hand cream after every wash, especially in winter or in air-conditioned rooms.',
      'Skin health',
      'Dry',
      'lip balm and hand cream'),

  // ---------------- Oily skin ----------------
  _Tip(
      'Do not skip moisturizer',
      'Oily skin still needs hydration.',
      'Skipping moisturizer can make your skin produce even more oil. Use a light, gel-based or oil-free moisturizer labeled non-comedogenic.',
      'Moisturizer',
      'Oily',
      'oil free gel moisturizer'),
  _Tip(
      'Try niacinamide',
      'Helps control oil and the look of pores.',
      'A serum with 2 to 5 percent niacinamide can help balance oil and calm redness. Start slowly, a few times a week, and watch how your skin reacts.',
      'Ingredients',
      'Oily',
      'niacinamide serum'),
  _Tip(
      'Do not over-wash',
      'Washing too often irritates oily skin.',
      'Wash twice a day at most. Over-washing damages the skin barrier and can lead to more oil and more breakouts.',
      'Cleanser',
      'Oily',
      'gentle gel cleanser for oily skin'),
  _Tip(
      'Use oil-free sunscreen',
      'Look for gel or matte formulas.',
      'Heavy sunscreens can feel greasy on oily skin. Choose gel, fluid or matte sunscreens labeled non-comedogenic.',
      'Sunscreen',
      'Oily',
      'oil free matte sunscreen'),
  _Tip(
      'Use salicylic acid for clogged pores',
      'It cleans oil from inside the pore.',
      'Salicylic acid (BHA) is oil-soluble, so it can get inside pores and clear blackheads. Start with a 1 to 2 percent cleanser or toner two or three times a week.',
      'Ingredients',
      'Oily',
      'salicylic acid BHA toner'),
  _Tip(
      'Try a clay mask once a week',
      'Absorbs extra oil and cleans pores.',
      'A kaolin or bentonite clay mask can soak up surface oil. Leave it on for 10 minutes, do not let it fully dry and crack, then rinse and moisturize. Once a week is enough.',
      'Routine',
      'Oily',
      'clay face mask for oily skin'),
  _Tip(
      'Blot, do not rub',
      'Control shine through the day.',
      'Press an oil-blotting sheet on the shiny areas to lift oil without disturbing your sunscreen or makeup. Avoid washing your face again and again during the day.',
      'Lifestyle',
      'Oily',
      'oil blotting sheets'),
  _Tip(
      'Pick non-comedogenic makeup',
      'Heavy makeup can block pores.',
      'Look for the words non-comedogenic or oil-free on foundation and concealer. Always remove makeup at night with a cleansing balm followed by a gentle gel cleanser.',
      'Safety',
      'Oily',
      'non comedogenic foundation'),

  // ---------------- Combination skin ----------------
  _Tip(
      'Treat each zone differently',
      'Combination skin has dry and oily areas.',
      'Use a lightweight lotion on the T-zone (forehead, nose, chin) and a slightly richer cream on dry cheeks. A gentle, balanced cleanser works for the whole face.',
      'Routine',
      'Combination',
      'lightweight lotion for combination skin'),
  _Tip(
      'Exfoliate gently, not daily',
      'Once or twice a week is enough.',
      'Too much exfoliation damages the skin barrier. Use a gentle chemical exfoliant such as lactic or salicylic acid, once or twice a week. Avoid rough scrubs.',
      'Routine',
      'Combination',
      'lactic acid exfoliant'),
  _Tip(
      'Try multi-masking',
      'Different masks for different areas.',
      'Put a clay mask on your T-zone and a hydrating mask on your cheeks at the same time. This treats oil and dryness together in one session. Do it once a week.',
      'Routine',
      'Combination',
      'clay mask and hydrating mask'),
  _Tip(
      'Choose a balanced gel-cream moisturizer',
      'Light enough for the T-zone, rich enough for cheeks.',
      'Gel-cream moisturizers hydrate without feeling heavy. If your cheeks still feel tight, add a few extra drops of a hydrating serum only on the dry areas.',
      'Moisturizer',
      'Combination',
      'gel cream moisturizer'),
  _Tip(
      'Use a balancing toner',
      'Helps settle oil and dryness together.',
      'An alcohol-free toner with niacinamide or green tea can calm the skin and reduce shine in the T-zone without drying your cheeks. Apply it with clean hands, not a rough cotton pad.',
      'Ingredients',
      'Combination',
      'alcohol free balancing toner'),
  _Tip(
      'Spot treat only the oily zones',
      'Do not put strong actives everywhere.',
      'Use salicylic acid or benzoyl peroxide only on the T-zone or on pimples. Putting them on dry cheeks can cause peeling and redness.',
      'Ingredients',
      'Combination',
      'salicylic acid spot treatment'),
  _Tip(
      'Layer from light to heavy',
      'Order matters in your routine.',
      'Apply thin products first (toner, serum), then lotion or cream, then sunscreen. Thin-to-thick layering lets each product absorb properly and avoids a greasy T-zone.',
      'Routine',
      'Combination'),

  // ---------------- Normal skin ----------------
  _Tip(
      'Keep your routine simple',
      'Fewer products, steadier skin.',
      'Normal skin does best with a basic routine: gentle cleanser, moisturizer and sunscreen. Add one new product at a time so you know what works.',
      'Routine',
      'Normal',
      'gentle face cleanser and moisturizer'),
  _Tip(
      'Add one active at a time',
      'Normal skin can handle more, but go slowly.',
      'When you want to try vitamin C, retinol or acids, add only one at a time and wait 2 to 3 weeks. Always use sunscreen in the morning.',
      'Ingredients',
      'Normal',
      'vitamin C serum'),
  _Tip(
      'Use vitamin C in the morning',
      'An antioxidant shield under sunscreen.',
      'A vitamin C serum helps protect against pollution and sun damage and brightens dull skin. Apply it after cleansing and before moisturizer and sunscreen.',
      'Ingredients',
      'Normal',
      'vitamin C serum 10%'),
  _Tip(
      'Start retinol slowly at night',
      'Great for long-term skin health.',
      'Begin with a low strength retinol two nights a week, then slowly increase. Use a pea-sized amount for the whole face. Do not use it together with strong acids, and always wear sunscreen the next day.',
      'Ingredients',
      'Normal',
      'retinol serum beginner'),
  _Tip(
      'Exfoliate once a week',
      'Keeps skin smooth and glowing.',
      'Normal skin can handle a gentle AHA or BHA exfoliant once a week. This removes dead cells and helps products absorb better. Skip it if your skin feels sore.',
      'Routine',
      'Normal',
      'gentle AHA exfoliant'),
  _Tip(
      'Use a hydrating mask weekly',
      'A small boost for glowing skin.',
      'A sheet mask or cream mask once a week adds extra water and keeps normal skin plump and soft. Choose one with hyaluronic acid or aloe.',
      'Routine',
      'Normal',
      'hydrating sheet mask'),
  _Tip(
      'Adjust to the seasons',
      'Normal skin can turn dry or oily with weather.',
      'In humid summers switch to a lighter gel moisturizer. In dry winters use a slightly richer cream. Your skin type is not fixed, so change your products when your skin changes.',
      'Lifestyle',
      'Normal'),

  // ---------------- Men's grooming ----------------
  _Tip(
      'Shave after a warm wash',
      'Warm water softens the hair.',
      'Wash your face with warm water first, or shave after a shower. Use a shaving gel or cream, shave in the direction the hair grows, and use a sharp, clean razor. A dull razor causes cuts and irritation.',
      'Men',
      'All',
      'shaving gel for men'),
  _Tip(
      'Prevent razor bumps',
      'Ingrown hairs are common after shaving.',
      'Do not shave too close and do not stretch the skin. Rinse with cool water after shaving and use an alcohol-free aftershave or moisturizer. Exfoliate gently twice a week.',
      'Men',
      'All',
      'aftershave balm for razor bumps'),
  _Tip(
      'Skip alcohol-heavy aftershave',
      'It can dry and sting your skin.',
      'Strong alcohol aftershaves dry out the skin. Choose a soothing, alcohol-free balm or lotion with aloe or glycerin.',
      'Men',
      'All',
      'alcohol free aftershave balm'),
  _Tip(
      'Men need sunscreen too',
      'Face, neck and ears get the most sun.',
      'Apply sunscreen with SPF 30 or higher every morning. Do not forget the neck, ears and the back of your hands. Beard areas need protection too.',
      'Men',
      'All',
      'men sunscreen SPF 30'),
  _Tip(
      'Wash your beard',
      'A beard traps dirt and oil.',
      'Wash your beard 2 to 3 times a week with a mild beard wash or gentle shampoo. Use a few drops of beard oil on damp skin to prevent dryness and itching under the beard.',
      'Men',
      'All',
      'beard wash and beard oil'),
  _Tip(
      'Keep a simple routine',
      'Three steps are enough.',
      'Wash your face with a gentle cleanser, apply a light moisturizer, and use sunscreen in the morning. At night, cleanse and moisturize. Add other products slowly.',
      'Men',
      'All',
      'men face wash'),
  _Tip(
      'Men often have oilier skin',
      'Thicker skin, more oil.',
      'On average, men have thicker skin and more oil production. Use a gel or lightweight moisturizer, and wash your face after sweating or exercise.',
      'Men',
      'All',
      'men oil control face wash'),
  _Tip(
      'Fact: men\'s skin ages differently',
      'Collagen is higher, but sun damage still shows.',
      'Men usually have thicker skin with more collagen, so wrinkles may appear a little later. But smoking, sun and poor sleep age skin just as fast.',
      'Men',
      'All',
      'men face moisturizer SPF'),
  _Tip(
      'Trim and clean regularly',
      'Good grooming goes beyond skin.',
      'Keep nails short and clean, trim nose and ear hair, and wash your hair regularly. Use a deodorant and change into clean clothes after the gym.',
      'Men',
      'All',
      'men deodorant'),
  _Tip(
      'Treat dandruff early',
      'It is common and treatable.',
      'Use an anti-dandruff shampoo with zinc pyrithione, ketoconazole or selenium sulfide 2 to 3 times a week. See a doctor if the scalp is red, painful or flaky for weeks.',
      'Men',
      'All',
      'anti dandruff shampoo ketoconazole'),
];

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  static const _filters = [
    'All',
    'Dry',
    'Oily',
    'Combination',
    'Normal',
    'Men'
  ];
  String _filter = 'All';
  String? _mine;

  @override
  void initState() {
    super.initState();
    _loadMine();
  }

  Future<void> _loadMine() async {
    try {
      final data = await OnboardingService.getOnboardingData();
      final t = data?['skin_type']?.toString();
      if (t != null &&
          _filters.contains(t) &&
          t != 'All' &&
          t != 'Men' &&
          mounted) {
        setState(() {
          _mine = t;
          _filter = t;
        });
      }
    } catch (_) {}
  }

  // All  -> every tip
  // Men  -> men's grooming tips
  // Dry / Oily / Combination / Normal -> only tips made for that skin type
  List<_Tip> get _visible {
    if (_filter == 'All') return _tips;
    if (_filter == 'Men') {
      return _tips.where((t) => t.category == 'Men').toList();
    }
    return _tips
        .where((t) => t.category != 'Men' && t.skin == _filter)
        .toList();
  }

  Future<void> _openVideo(_Video v) async {
    final uri = Uri.https(
        'www.youtube.com', '/results', {'search_query': v.query});
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open YouTube.')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open YouTube.')));
      }
    }
  }

  void _open(_Tip t) {
    final color = _catColor(t.category);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.65)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(children: [
                  Icon(_catIcon(t.category), color: Colors.white, size: 36),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(t.category.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 12,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              Text(t.title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Text(t.body, style: const TextStyle(fontSize: 14, height: 1.5)),
              if (t.product != null) ...[
                const SizedBox(height: 20),
                const Text('Products to use',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Look for: ${t.product}',
                    style:
                        const TextStyle(fontSize: 13, color: Colors.black54)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24))),
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('Find products with prices'),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductsScreen(
                            category: t.product,
                            title: t.title,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _hero() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 180,
        child: Stack(fit: StackFit.expand, children: [
          Image.asset(
            'assets/images/face_scan_pic.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: const Color(0xFF3B2F2F)),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x33000000), Color(0xCC000000)],
              ),
            ),
          ),
          const Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Healthy skin starts here',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                  SizedBox(height: 4),
                  Text('Tips, myths, facts and videos for every skin type.',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ]),
          ),
        ]),
      ),
    );
  }

  Widget _sectionTitle(String t, [String? sub]) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        if (sub != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(sub,
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ),
      ]),
    );
  }

  Widget _videoCard(_Video v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openVideo(v),
        child: Container(
          width: double.infinity,
          height: 130,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [v.color, v.color.withOpacity(0.7)]),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(v.icon, color: Colors.white70, size: 24),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(v.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16)),
                          const SizedBox(height: 2),
                          Text(v.subtitle,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ]),
                  ]),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                  color: Colors.white24, shape: BoxShape.circle),
              child: const Icon(Icons.play_arrow,
                  color: Colors.white, size: 34),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _tipCard(_Tip t) {
    final color = _catColor(t.category);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _open(t),
        child: Container(
          decoration: BoxDecoration(
              color: const Color(0xFFF5EFEC),
              borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            Container(
              width: 64,
              height: 84,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [color, color.withOpacity(0.7)]),
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(14)),
              ),
              child: Icon(_catIcon(t.category), color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(t.category,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: color)),
                      ),
                      const SizedBox(height: 4),
                      Text(t.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(t.summary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black87)),
                    ]),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.chevron_right),
            ),
          ]),
        ),
      ),
    );
  }

  String get _tipsSubtitle {
    if (_filter == 'All') return 'General tips for every skin type';
    if (_filter == 'Men') return "Grooming tips for men";
    if (_filter == _mine) return 'Tips made for your skin type: $_filter';
    return 'Tips made for $_filter skin';
  }

  @override
  Widget build(BuildContext context) {
    final tips = _visible;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: const Text('Explore'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _hero(),
          _sectionTitle('Watch and learn', 'Tap to watch on YouTube'),
          for (final v in _videos) _videoCard(v),
          _sectionTitle('Beauty tips', _tipsSubtitle),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final f in _filters)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f == 'Men' ? "Men's grooming" : f),
                      selected: _filter == f,
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (final t in tips) _tipCard(t),
        ],
      ),
    );
  }
}