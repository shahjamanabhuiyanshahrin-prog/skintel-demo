import 'package:flutter/material.dart';
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

const List<_Tip> _tips = [
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
      'Treat each zone differently',
      'Combination skin has dry and oily areas.',
      'Use a lightweight lotion on the T-zone (forehead, nose, chin) and a slightly richer cream on dry cheeks. A gentle, balanced cleanser works for the whole face.',
      'Routine',
      'Combination',
      'lightweight lotion for combination skin'),
  _Tip(
      'Keep your routine simple',
      'Fewer products, steadier skin.',
      'Normal skin does best with a basic routine: gentle cleanser, moisturizer and sunscreen. Add one new product at a time so you know what works.',
      'Routine',
      'Normal',
      'gentle face cleanser and moisturizer'),
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
  _Tip(
      'Use heavier cream at night, lighter by day',
      'Dry skin loses more water at night.',
      'A richer night cream helps dry skin recover. In the morning use a lighter moisturizer under sunscreen.',
      'Routine',
      'Dry',
      'night cream for dry skin'),
  _Tip(
      'Use oil-free sunscreen',
      'Look for gel or matte formulas.',
      'Heavy sunscreens can feel greasy on oily skin. Choose gel, fluid or matte sunscreens labeled non-comedogenic.',
      'Sunscreen',
      'Oily',
      'oil free matte sunscreen'),
  _Tip(
      'Exfoliate gently, not daily',
      'Once or twice a week is enough.',
      'Too much exfoliation damages the skin barrier. Use a gentle chemical exfoliant such as lactic or salicylic acid, once or twice a week. Avoid rough scrubs.',
      'Routine',
      'Combination',
      'lactic acid exfoliant'),
  _Tip(
      'Add one active at a time',
      'Normal skin can handle more, but go slowly.',
      'When you want to try vitamin C, retinol or acids, add only one at a time and wait 2 to 3 weeks. Always use sunscreen in the morning.',
      'Ingredients',
      'Normal',
      'vitamin C serum'),
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
      if (t != null && _filters.contains(t) && t != 'All' && t != 'Men' && mounted) {
        setState(() {
          _mine = t;
          _filter = t;
        });
      }
    } catch (_) {}
  }

  List<_Tip> get _visible {
    if (_filter == 'All') return _tips;
    if (_filter == 'Men') return _tips.where((t) => t.category == 'Men').toList();
    return _tips
        .where((t) =>
            t.category != 'Men' && (t.skin == 'All' || t.skin == _filter))
        .toList();
  }

  void _open(_Tip t) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.category.toUpperCase(),
                style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54)),
            const SizedBox(height: 6),
            Text(t.title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Text(t.body, style: const TextStyle(fontSize: 14, height: 1.5)),
            if (t.product != null) ...[
              const SizedBox(height: 20),
              const Text('Products to use',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('Look for: ${t.product}',
                  style: const TextStyle(fontSize: 13, color: Colors.black54)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final tips = _visible;
    return Scaffold(
      appBar: AppBar(
          title: const Text('Explore'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Beauty tips',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          if (_mine != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Showing tips for your skin type: $_mine',
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 12),
          for (final t in tips)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _open(t),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF5EFEC),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    Icon(t.category == 'Myth'
                        ? Icons.help_outline
                        : t.category == 'Fact'
                            ? Icons.auto_awesome
                            : Icons.lightbulb_outline),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(t.summary,
                                style: const TextStyle(fontSize: 11)),
                            const SizedBox(height: 4),
                            Text(t.category,
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.black54)),
                          ]),
                    ),
                    const Icon(Icons.chevron_right),
                  ]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}