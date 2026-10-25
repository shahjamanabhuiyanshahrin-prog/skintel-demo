import 'package:flutter/material.dart';
import '../services/onboarding_service.dart';
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;

  String? _selectedSkinType;
  String? _selectedSkinTone;
  String? _selectedExperience;

  final List<String> _selectedConcerns = [];
  final List<String> _selectedGoals = [];

  // ============================================================
  // SKIN TYPE
  // ============================================================

  final List<_ImageOption> _skinTypes = const [
    _ImageOption(
      name: 'Dry',
      image: 'assets/images/skin_types/dry.jpg',
    ),
    _ImageOption(
      name: 'Oily',
      image: 'assets/images/skin_types/oily.jpg',
    ),
    _ImageOption(
      name: 'Normal',
      image: 'assets/images/skin_types/normal.jpg',
    ),
    _ImageOption(
      name: 'Acne',
      image: 'assets/images/skin_types/acne.jpg',
    ),
    _ImageOption(
      name: 'Combination',
      image: 'assets/images/skin_types/combination.jpg',
    ),
  ];

  // ============================================================
  // CONCERNS
  // ============================================================

  final List<_ImageOption> _concerns = const [
    _ImageOption(
      name: 'Black/White heads',
      image: 'assets/images/concerns/black_white_heads.jpg',
    ),
    _ImageOption(
      name: 'Dark Under Eyes',
      image: 'assets/images/concerns/dark_circle.jpg',
    ),
    _ImageOption(
      name: 'Hyper-Pigmentation',
      image: 'assets/images/concerns/hyperpigmentation.jpg',
    ),
    _ImageOption(
      name: 'Roughness',
      image: 'assets/images/concerns/rough.jpg',
    ),
    _ImageOption(
      name: 'Sensitivity',
      image: 'assets/images/concerns/sensitivity.jpg',
    ),
    _ImageOption(
      name: 'Wrinkles',
      image: 'assets/images/concerns/wrinkle.jpg',
    ),
    _ImageOption(
      name: 'Dullness',
      image: 'assets/images/concerns/dullness.jpg',
    ),
    _ImageOption(
      name: 'Large Pores',
      image: 'assets/images/concerns/large_pores.jpg',
    ),
    _ImageOption(
      name: 'Acne Scars',
      image: 'assets/images/concerns/acne_scars.jpg',
    ),
  ];

  // ============================================================
  // SKIN TONES
  // ============================================================

  final List<_SkinTone> _skinTones = const [
    _SkinTone(
      name: 'Dark',
      color: Color(0xFFD19B73),
    ),
    _SkinTone(
      name: 'Medium',
      color: Color(0xFFEDBB98),
    ),
    _SkinTone(
      name: 'Light',
      color: Color(0xFFEEDDD0),
    ),
    _SkinTone(
      name: 'Medium Light',
      color: Color(0xFFE9C1A3),
    ),
    _SkinTone(
      name: 'Medium Dark',
      color: Color(0xFFD39D77),
    ),
  ];

  // ============================================================
  // PROGRESS
  // ============================================================

  final List<int> _progressPercent = const [
    36,
    48,
    69,
    84,
    100,
  ];

  final List<double> _progressValue = const [
    0.36,
    0.48,
    0.69,
    0.84,
    1.0,
  ];

  // ============================================================
  // NEXT
  // ============================================================

  
Future<void> _nextPage() async {
  if (_currentPage < 4) {
    setState(() {
      _currentPage++;
    });
    return;
  }

  // Save onboarding selections before opening Home.
  try {
    await OnboardingService.saveOnboardingData(
      skinType: _selectedSkinType ?? '',
      skinTone: _selectedSkinTone ?? '',
      concerns: List<String>.from(_selectedConcerns),
      experience: _selectedExperience ?? '',
      goals: List<String>.from(_selectedGoals),
    );

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Could not save onboarding data: $e'),
      ),
    );
  }
}


  // ============================================================
  // SKIP
  // ============================================================

  void _skip() {
    if (_currentPage < 4) {
      setState(() {
        _currentPage++;
      });
    }
  }

  // ============================================================
  // BACK
  // ============================================================

  void _goBack() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),

            Expanded(
              child: _buildCurrentPage(),
            ),

            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        48,
        22,
        48,
        0,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _goBack,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE0E0E0),
                  width: 1.2,
                ),
              ),
              child: const Icon(
                Icons.chevron_left,
                size: 32,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(width: 24),

          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _progressValue[_currentPage],
                minHeight: 4,
                backgroundColor: const Color(0xFFE5E5E5),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(
                  Colors.black,
                ),
              ),
            ),
          ),

          const SizedBox(width: 18),

          Text(
            '${_progressPercent[_currentPage]}%',
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF777777),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CURRENT PAGE
  // ============================================================

  Widget _buildCurrentPage() {
    switch (_currentPage) {
      case 0:
        return _buildSkinTypePage();

      case 1:
        return _buildSkinTonePage();

      case 2:
        return _buildConcernsPage();

      case 3:
        return _buildExperiencePage();

      case 4:
        return _buildGoalsPage();

      default:
        return const SizedBox();
    }
  }

  // ============================================================
  // COMMON PAGE CONTENT
  // ============================================================

  Widget _pageContent({
    required String title,
    required String subtitle,
    required Widget content,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        48,
        52,
        48,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              height: 1.15,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF888888),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 46),

          content,
        ],
      ),
    );
  }

  // ============================================================
  // PAGE 1 - SKIN TYPE
  // ============================================================

  Widget _buildSkinTypePage() {
    return _pageContent(
      title: "What's your skin type?",
      subtitle:
          'Identifying your skin type allows us to offer '
          'more effective recommendations.',
      content: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _skinTypes.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 18,
          mainAxisSpacing: 30,
          mainAxisExtent: 125,
        ),
        itemBuilder: (context, index) {
          final item = _skinTypes[index];

          return _buildImageOption(
            item: item,
            selected: _selectedSkinType == item.name,
            onTap: () {
              setState(() {
                _selectedSkinType = item.name;
              });
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // PAGE 2 - SKIN TONE
  // ============================================================

  Widget _buildSkinTonePage() {
    return _pageContent(
      title: "What's your skin tone?",
      subtitle:
          'Identifying your skin tone allows us to offer '
          'more effective recommendations.',
      content: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 28,
          runSpacing: 34,
          children: _skinTones.map((tone) {
            return _buildToneOption(tone);
          }).toList(),
        ),
      ),
    );
  }

  // ============================================================
  // SKIN TONE OPTION
  // ============================================================

  Widget _buildToneOption(_SkinTone tone) {
    final bool selected =
        _selectedSkinTone == tone.name;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSkinTone = tone.name;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 86,
        height: 86,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: tone.color,
          border: Border.all(
            color: selected
                ? Colors.black
                : Colors.transparent,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 7,
          ),
          child: Text(
            tone.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.visible,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.15,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PAGE 3 - CONCERNS
  // ============================================================

  Widget _buildConcernsPage() {
    return _pageContent(
      title: 'What are your concerns?',
      subtitle:
          'Identifying your concerns will help us to offer '
          'more effective recommendations.',
      content: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _concerns.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 14,
          mainAxisSpacing: 32,
          mainAxisExtent: 142,
        ),
        itemBuilder: (context, index) {
          final item = _concerns[index];

          return _buildConcernItem(
            item: item,
            selected: _selectedConcerns.contains(item.name),
            onTap: () {
              setState(() {
                if (_selectedConcerns.contains(item.name)) {
                  _selectedConcerns.remove(item.name);
                } else {
                  _selectedConcerns.add(item.name);
                }
              });
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // CONCERN ITEM
  // ============================================================

  Widget _buildConcernItem({
    required _ImageOption item,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: double.infinity,
        height: 142,
        child: Column(
          children: [
            // -------------------------------
            // CIRCLE IMAGE
            // -------------------------------

            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? Colors.black
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  item.image,
                  width: 78,
                  height: 78,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder:
                      (context, error, stackTrace) {
                    return Container(
                      width: 78,
                      height: 78,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFD1AD96),
                      ),
                      child: const Icon(
                        Icons.face,
                        color: Colors.white,
                        size: 36,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 8),

            // -------------------------------
            // LABEL
            // -------------------------------

            SizedBox(
              width: 105,
              height: 45,
              child: Center(
                child: Text(
                  item.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF777777),
                    height: 1.25,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // GENERIC IMAGE OPTION
  // ============================================================

  Widget _buildImageOption({
    required _ImageOption item,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: double.infinity,
        height: 125,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? Colors.black
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  item.image,
                  width: 78,
                  height: 78,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder:
                      (context, error, stackTrace) {
                    return Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFD1AD96),
                      ),
                      child: const Icon(
                        Icons.face,
                        color: Colors.white,
                        size: 34,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              height: 30,
              width: 100,
              child: Text(
                item.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF777777),
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PAGE 4 - EXPERIENCE
  // ============================================================

  Widget _buildExperiencePage() {
    final options = [
      'I do it regularly',
      'I tried a few times',
      'I have no idea',
    ];

    return _pageContent(
      title: 'How experienced are you in skincare routine?',
      subtitle:
          'We will use this info to improve your '
          'experience in the app.',
      content: Column(
        children: options.map((option) {
          return Padding(
            padding: const EdgeInsets.only(
              bottom: 12,
            ),
            child: _buildWideOption(
              text: option,
              selected:
                  _selectedExperience == option,
              onTap: () {
                setState(() {
                  _selectedExperience = option;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // PAGE 5 - GOALS
  // ============================================================

  Widget _buildGoalsPage() {
    final options = [
      'Fix the concerns of my skin',
      'Discover skincare products',
      'Educate myself about skincare',
      'Learn more about my skin',
      'Apply home treatments',
      'Practice facial yoga (coming soon)',
    ];

    return _pageContent(
      title: 'What are your goals?',
      subtitle:
          'Choose as many as you want. This will help us '
          'improve your experience.',
      content: Column(
        children: options.map((option) {
          final bool selected =
              _selectedGoals.contains(option);

          return Padding(
            padding: const EdgeInsets.only(
              bottom: 12,
            ),
            child: _buildWideOption(
              text: option,
              selected: selected,
              onTap: () {
                setState(() {
                  if (selected) {
                    _selectedGoals.remove(option);
                  } else {
                    _selectedGoals.add(option);
                  }
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // WIDE OPTION
  // ============================================================

  Widget _buildWideOption({
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFEDE7E4)
              : const Color(0xFFF6F4F3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? Colors.black
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black,
                ),
              ),
            ),
            if (selected)
              const Icon(
                Icons.check,
                size: 18,
                color: Colors.black,
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM BUTTONS
  // ============================================================

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        48,
        0,
        48,
        20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_currentPage < 3)
            GestureDetector(
              onTap: _skip,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                height: 42,
                child: Center(
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF777777),
                    ),
                  ),
                ),
              ),
            )
          else
            const SizedBox(height: 42),

          const SizedBox(height: 4),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              child: Text(
                _currentPage == 4
                    ? 'Finish'
                    : 'Continue',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// IMAGE OPTION MODEL
// ================================================================

class _ImageOption {
  final String name;
  final String image;

  const _ImageOption({
    required this.name,
    required this.image,
  });
}

// ================================================================
// SKIN TONE MODEL
// ================================================================

class _SkinTone {
  final String name;
  final Color color;

  const _SkinTone({
    required this.name,
    required this.color,
  });
}