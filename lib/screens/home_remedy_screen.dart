
import 'package:flutter/material.dart';

const Color _bg = Color(0xFFF5EFEC);
const Color _dark = Color(0xFF171717);

class HomeRemedyScreen extends StatefulWidget {
  const HomeRemedyScreen({super.key});

  @override
  State<HomeRemedyScreen> createState() => _HomeRemedyScreenState();
}

class _HomeRemedyScreenState extends State<HomeRemedyScreen> {
  String _selectedCategory = 'All';
  final Set<String> _selectedIngredients = {};

  final List<String> _categories = [
    'All',
    'Dullness',
    'Dry Skin',
    'Oily Skin',
    'Under Eyes',
    'Acne',
  ];

  final List<String> _ingredients = [
    'Besan',
    'Yogurt',
    'Honey',
    'Aloe Vera',
    'Oats',
    'Cucumber',
    'Water',
  ];

  final List<Map<String, dynamic>> _remedies = [
    {
      'category': 'Dullness',
      'title': 'Besan + Yogurt + Honey',
      'subtitle': 'A gentle wash-off mask option',
      'ingredients': ['Besan', 'Yogurt', 'Honey'],
      'time': '5–10 minutes',
      'preparation':
          'Mix 1 teaspoon besan, 1 teaspoon plain unsweetened yogurt and 1 teaspoon honey into a smooth paste.',
      'usage':
          'Patch test first. Apply a thin layer without scrubbing. Rinse gently with lukewarm water after 5–10 minutes.',
      'warning':
          'This is not a proven treatment for dullness or pigmentation. Avoid if you have dairy or honey allergy, sensitive or irritated skin.',
      'icon': Icons.auto_awesome,
    },
    {
      'category': 'Dullness',
      'title': 'Oats + Yogurt Mask',
      'subtitle': 'A simple gentle wash-off option',
      'ingredients': ['Oats', 'Yogurt'],
      'time': '5–10 minutes',
      'preparation':
          'Mix 1 teaspoon finely ground plain oats with 1 teaspoon plain unsweetened yogurt.',
      'usage':
          'Apply gently to clean skin. Do not rub or scrub. Rinse with lukewarm water after 5–10 minutes.',
      'warning':
          'Avoid if you have an oat or dairy allergy. Stop if burning, redness or itching occurs.',
      'icon': Icons.spa_outlined,
    },
    {
      'category': 'Dullness',
      'title': 'Aloe Vera Gel',
      'subtitle': 'A simple soothing option',
      'ingredients': ['Aloe Vera'],
      'time': '5–10 minutes',
      'preparation':
          'Use a small amount of clean, fragrance-free, commercially prepared aloe vera gel.',
      'usage':
          'After patch testing, apply a thin layer. Rinse after 5–10 minutes if using as a wash-off mask.',
      'warning':
          'Aloe vera does not permanently brighten skin. It may cause allergy or irritation in some people.',
      'icon': Icons.eco_outlined,
    },
    {
      'category': 'Dry Skin',
      'title': 'Oats + Water',
      'subtitle': 'For dry-feeling skin',
      'ingredients': ['Oats', 'Water'],
      'time': '5–10 minutes',
      'preparation':
          'Mix 1 tablespoon finely ground plain oats with enough clean water to make a soft paste.',
      'usage':
          'Apply gently without rubbing. Rinse with lukewarm water. Follow with a fragrance-free moisturizer.',
      'warning':
          'Avoid if you have an oat allergy. Coarse oats can scratch the skin, so use only finely ground oats.',
      'icon': Icons.water_drop_outlined,
    },
    {
      'category': 'Dry Skin',
      'title': 'Aloe Vera + Oats',
      'subtitle': 'A gentle wash-off combination',
      'ingredients': ['Aloe Vera', 'Oats'],
      'time': '5 minutes',
      'preparation':
          'Mix 1 teaspoon fragrance-free aloe vera gel with 1 teaspoon finely ground oats.',
      'usage':
          'Patch test first. Apply a thin layer without scrubbing. Rinse gently after 5 minutes and moisturize.',
      'warning':
          'Avoid if you react to oats or aloe vera. This does not replace a regular moisturizer.',
      'icon': Icons.spa_outlined,
    },
    {
      'category': 'Oily Skin',
      'title': 'Pure Aloe Vera Gel',
      'subtitle': 'Lightweight soothing option',
      'ingredients': ['Aloe Vera'],
      'time': '5–10 minutes',
      'preparation':
          'Choose clean, fragrance-free aloe vera gel without added essential oils.',
      'usage':
          'Patch test first. Apply a thin layer and rinse after 5–10 minutes if desired.',
      'warning':
          'Aloe vera does not control oil production or cure acne. Stop if irritation occurs.',
      'icon': Icons.water_drop_outlined,
    },
    {
      'category': 'Oily Skin',
      'title': 'Cucumber Cool Compress',
      'subtitle': 'A refreshing cooling option',
      'ingredients': ['Cucumber', 'Water'],
      'time': 'A few minutes',
      'preparation':
          'Wash a cucumber thoroughly. Wet a clean soft cloth with cool water.',
      'usage':
          'Use the cool damp cloth gently on your face for a few minutes. Do not rub.',
      'warning':
          'This may feel refreshing but does not treat oily skin. Do not apply cucumber juice near the eyes.',
      'icon': Icons.spa_outlined,
    },
    {
      'category': 'Under Eyes',
      'title': 'Cool Water Compress',
      'subtitle': 'For temporary puffiness',
      'ingredients': ['Water'],
      'time': 'A few minutes',
      'preparation':
          'Wet a clean, soft washcloth with cool water and squeeze out extra water.',
      'usage':
          'Close your eyes and gently place the cloth over them for a few minutes. Never press on your eyeballs.',
      'warning':
          'Do not use besan, potato juice, turmeric or homemade masks around the eyes. Persistent or painful swelling needs medical advice.',
      'icon': Icons.remove_red_eye_outlined,
    },
    {
      'category': 'Acne',
      'title': 'Gentle Acne Care',
      'subtitle': 'A simple routine instead of DIY masks',
      'ingredients': ['Water'],
      'time': 'Daily routine',
      'preparation':
          'Prepare a gentle fragrance-free cleanser, non-comedogenic moisturizer and SPF 30+ sunscreen.',
      'usage':
          'Wash gently twice a day. Moisturize after washing and use sunscreen during the day. Do not squeeze pimples.',
      'warning':
          'Food masks are not proven acne treatments. Avoid lemon, toothpaste, baking soda and rough scrubs. Persistent or painful acne needs a dermatologist.',
      'icon': Icons.face_retouching_natural,
    },
  ];

  List<Map<String, dynamic>> get _filteredRemedies {
    return _remedies.where((item) {
      final categoryMatch = _selectedCategory == 'All' ||
          item['category'] == _selectedCategory;

      final recipeIngredients =
          item['ingredients'] as List<String>;

      // Show recipes containing at least one selected ingredient.
      final ingredientMatch = _selectedIngredients.isEmpty ||
          recipeIngredients.any(
            (ingredient) =>
                _selectedIngredients.contains(ingredient),
          );

      return categoryMatch && ingredientMatch;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = 'All';
      _selectedIngredients.clear();
    });
  }

  Widget _heading(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _detail(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipes = _filteredRemedies;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Home Remedy',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _clearFilters,
            tooltip: 'Reset filters',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Natural care, at home',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      'Choose ingredients you already have at home and explore different skincare options.',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _heading('1. Choose your skin concern'),
            ),

            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final selected =
                      _selectedCategory == category;

                  return ChoiceChip(
                    label: Text(category),
                    selected: selected,
                    selectedColor: _dark,
                    backgroundColor: _bg,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black,
                      fontSize: 11,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _heading('2. Ingredients available at home'),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 5,
                runSpacing: 2,
                children: _ingredients.map((ingredient) {
                  final selected =
                      _selectedIngredients.contains(ingredient);

                  return FilterChip(
                    label: Text(ingredient),
                    selected: selected,
                    selectedColor: const Color(0xFFE5D5CB),
                    backgroundColor: _bg,
                    checkmarkColor: _dark,
                    labelStyle: const TextStyle(
                      fontSize: 11,
                      color: Colors.black,
                    ),
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          _selectedIngredients.add(ingredient);
                        } else {
                          _selectedIngredients.remove(ingredient);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _selectedIngredients.isEmpty
                    ? 'Select one or more ingredients to find matching options.'
                    : 'Showing recipes containing your selected ingredients.',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade700,
                ),
              ),
            ),

            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '3. Available recipes',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${recipes.length} options',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: recipes.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(25),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.search_off,
                              size: 42,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No matching recipes found.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 7),
                            const Text(
                              'Try selecting different ingredients or changing your skin concern.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12),
                            ),
                            TextButton(
                              onPressed: _clearFilters,
                              child: const Text('Clear filters'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        final item = recipes[index];
                        final ingredients =
                            item['ingredients'] as List<String>;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: _bg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFE6DAD4),
                            ),
                          ),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            childrenPadding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            leading: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(
                                item['icon'] as IconData,
                                color: _dark,
                              ),
                            ),
                            title: Text(
                              item['title'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                item['subtitle'] as String,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            children: [
                              const Divider(),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.timer_outlined,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Duration: ${item['time']}',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              _heading('Ingredients'),

                              Wrap(
                                spacing: 6,
                                runSpacing: 5,
                                children: ingredients.map((ingredient) {
                                  return Chip(
                                    label: Text(
                                      ingredient,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    backgroundColor: Colors.white,
                                    visualDensity: VisualDensity.compact,
                                  );
                                }).toList(),
                              ),

                              const SizedBox(height: 12),

                              _detail(
                                'How to prepare',
                                item['preparation'] as String,
                              ),

                              _detail(
                                'How to use',
                                item['usage'] as String,
                              ),

                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.warning_amber_rounded,
                                      size: 18,
                                      color: Colors.brown,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        item['warning'] as String,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                'Patch test new ingredients first. Stop using anything that causes irritation. Home remedies are not medical treatments.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
