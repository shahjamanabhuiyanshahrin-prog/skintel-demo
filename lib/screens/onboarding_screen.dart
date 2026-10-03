import 'package:flutter/material.dart';

import '../services/onboarding_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  bool _isSaving = false;

  String? _skinType;
  String? _skinTone;
  String? _experience;

  final List<String> _concerns = [];
  final List<String> _goals = [];

  final List<double> _progress = [
    0.36,
    0.48,
    0.69,
    0.84,
    1.0,
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    try {
      final data = await OnboardingService.getOnboardingData();

      if (data == null || !mounted) return;

      setState(() {
        _skinType = data['skin_type'] as String?;
        _skinTone = data['skin_tone'] as String?;
        _experience = data['skincare_experience'] as String?;

        final savedConcerns = data['concerns'];

        if (savedConcerns is List) {
          _concerns
            ..clear()
            ..addAll(
              savedConcerns.map((e) => e.toString()),
            );
        }

        final savedGoals = data['goals'];

        if (savedGoals is List) {
          _goals
            ..clear()
            ..addAll(
              savedGoals.map((e) => e.toString()),
            );
        }
      });
    } catch (_) {
      // Existing user profile না থাকলে কোনো সমস্যা হবে না।
    }
  }

  void _nextStep() {
    if (!_validateCurrentStep()) return;

    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
    } else {
      _finishOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep == 0) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _currentStep--;
    });
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0 && _skinType == null) {
      _showMessage('Please select your skin type.');
      return false;
    }

    if (_currentStep == 1 && _skinTone == null) {
      _showMessage('Please select your skin tone.');
      return false;
    }

    if (_currentStep == 2 && _concerns.isEmpty) {
      _showMessage('Please select at least one concern.');
      return false;
    }

    if (_currentStep == 3 && _experience == null) {
      _showMessage(
        'Please select your skincare experience.',
      );
      return false;
    }

    if (_currentStep == 4 && _goals.isEmpty) {
      _showMessage('Please select at least one goal.');
      return false;
    }

    return true;
  }

  Future<void> _finishOnboarding() async {
    if (!_validateCurrentStep()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await OnboardingService.saveOnboardingData(
        skinType: _skinType!,
        skinTone: _skinTone!,
        concerns: _concerns,
        experience: _experience!,
        goals: _goals,
      );

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Could not save your information. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopProgress(),

            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildCurrentPage(),
              ),
            ),

            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // TOP PROGRESS
  // ----------------------------------------------------------

  Widget _buildTopProgress() {
    final percentage =
        (_progress[_currentStep] * 100).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _previousStep,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_left,
                    size: 18,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: _progress[_currentStep],
                    minHeight: 2,
                    backgroundColor:
                        const Color(0xFFE9E9E9),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(
                      Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 8,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // CURRENT PAGE
  // ----------------------------------------------------------

  Widget _buildCurrentPage() {
    switch (_currentStep) {
      case 0:
        return _skinTypePage();

      case 1:
        return _skinTonePage();

      case 2:
        return _concernsPage();

      case 3:
        return _experiencePage();

      case 4:
        return _goalsPage();

      default:
        return const SizedBox();
    }
  }

  // ----------------------------------------------------------
  // PAGE 1 - SKIN TYPE
  // ----------------------------------------------------------

  Widget _skinTypePage() {
    final options = [
      _SkinOption('Dry', Icons.water_drop_outlined),
      _SkinOption('Oily', Icons.opacity),
      _SkinOption('Normal', Icons.face_outlined),
      _SkinOption('Acne', Icons.healing_outlined),
      _SkinOption('Combination', Icons.auto_awesome_outlined),
    ];

    return _pageLayout(
      title: "What's your skin type?",
      subtitle:
          'Identifying your skin type allows us to offer more '
          'effective recommendations.',
      child: Wrap(
        spacing: 12,
        runSpacing: 14,
        alignment: WrapAlignment.center,
        children: options.map((option) {
          return _roundOption(
            label: option.label,
            icon: option.icon,
            selected: _skinType == option.label,
            onTap: () {
              setState(() {
                _skinType = option.label;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  // ----------------------------------------------------------
  // PAGE 2 - SKIN TONE
  // ----------------------------------------------------------

  Widget _skinTonePage() {
    final options = [
      _ToneOption(
        'Dark',
        const Color(0xFF9A5B35),
      ),
      _ToneOption(
        'Medium',
        const Color(0xFFD39169),
      ),
      _ToneOption(
        'Light',
        const Color(0xFFE8BDA1),
      ),
      _ToneOption(
        'Medium Light',
        const Color(0xFFE4AE8B),
      ),
      _ToneOption(
        'Medium Dark',
        const Color(0xFFB8754F),
      ),
    ];

    return _pageLayout(
      title: "What's your skin tone?",
      subtitle:
          'Identifying your skin tone allows us to offer more '
          'effective recommendations.',
      child: Wrap(
        spacing: 14,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: options.map((option) {
          return _roundOption(
            label: option.label,
            color: option.color,
            selected: _skinTone == option.label,
            onTap: () {
              setState(() {
                _skinTone = option.label;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  // ----------------------------------------------------------
  // PAGE 3 - CONCERNS
  // ----------------------------------------------------------

  Widget _concernsPage() {
    final concerns = [
      'Black/White heads',
      'Dark Eyes',
      'Hyper-pigmentation',
      'Roughness',
      'Sensitivity',
      'Wrinkles',
      'Dullness',
      'Large Pores',
      'Acne Scars',
    ];

    return _pageLayout(
      title: 'What are your concerns?',
      subtitle:
          'Identifying your concerns will help us to offer '
          'more effective recommendations.',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: concerns.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
          childAspectRatio: 0.82,
        ),
        itemBuilder: (context, index) {
          final concern = concerns[index];

          return _concernOption(
            label: concern,
            selected: _concerns.contains(concern),
            index: index,
            onTap: () {
              setState(() {
                if (_concerns.contains(concern)) {
                  _concerns.remove(concern);
                } else {
                  _concerns.add(concern);
                }
              });
            },
          );
        },
      ),
    );
  }

  // ----------------------------------------------------------
  // PAGE 4 - EXPERIENCE
  // ----------------------------------------------------------

  Widget _experiencePage() {
    final options = [
      'I do it regularly',
      'I tried a few times',
      'I have no idea',
    ];

    return _pageLayout(
      title:
          'How experienced are you in\nskincare routine?',
      subtitle:
          'We will use this info to improve your experience '
          'in the app.',
      child: Column(
        children: options.map((option) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _wideOption(
              option,
              selected: _experience == option,
              onTap: () {
                setState(() {
                  _experience = option;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // ----------------------------------------------------------
  // PAGE 5 - GOALS
  // ----------------------------------------------------------

  Widget _goalsPage() {
    final goals = [
      'Fix the concerns of my skin',
      'Discover skincare products',
      'Educate myself about skincare',
      'Learn more about my skin',
      'Apply home treatments',
      'Practice facial yoga (coming soon)',
    ];

    return _pageLayout(
      title: 'What are your goals?',
      subtitle:
          'Choose as many as you want. This will help us '
          'improve the app and your experience.',
      child: Column(
        children: goals.map((goal) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _wideOption(
              goal,
              selected: _goals.contains(goal),
              onTap: () {
                setState(() {
                  if (_goals.contains(goal)) {
                    _goals.remove(goal);
                  } else {
                    _goals.add(goal);
                  }
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // ----------------------------------------------------------
  // COMMON PAGE LAYOUT
  // ----------------------------------------------------------

  Widget _pageLayout({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 8.5,
              color: Colors.black54,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 34),

          child,
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // ROUND OPTIONS
  // ----------------------------------------------------------

  Widget _roundOption({
    required String label,
    IconData? icon,
    Color? color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color ?? const Color(0xFFDFA47F),
              border: Border.all(
                color: selected
                    ? Colors.black
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 5,
                      ),
                    ]
                  : null,
            ),
            child: icon != null
                ? Icon(
                    icon,
                    size: 22,
                    color: Colors.white,
                  )
                : null,
          ),

          const SizedBox(height: 5),

          SizedBox(
            width: 70,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 8,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // CONCERN OPTION
  // ----------------------------------------------------------

  Widget _concernOption({
    required String label,
    required bool selected,
    required int index,
    required VoidCallback onTap,
  }) {
    final colors = [
      const Color(0xFFB8754F),
      const Color(0xFFE0A17F),
      const Color(0xFFC98562),
      const Color(0xFFDCA58E),
      const Color(0xFFE5B5A0),
      const Color(0xFFD89072),
      const Color(0xFFE1B39D),
      const Color(0xFFB9785D),
      const Color(0xFFD99A7D),
    ];

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors[index],
              border: Border.all(
                color: selected
                    ? Colors.black
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: selected
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  )
                : const SizedBox(),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 7,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // WIDE OPTION
  // ----------------------------------------------------------

  Widget _wideOption(
    String label, {
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE9E2DF)
              : const Color(0xFFF5F2F1),
          borderRadius: BorderRadius.circular(7),
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
                label,
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.black,
                ),
              ),
            ),
            if (selected)
              const Icon(
                Icons.check,
                size: 15,
                color: Colors.black,
              ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // BOTTOM BUTTON
  // ----------------------------------------------------------

  Widget _buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 18),
      child: SizedBox(
        width: double.infinity,
        height: 44,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _nextStep,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.black54,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  _currentStep == 4
                      ? 'Finish'
                      : 'Continue',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// DATA CLASSES
// ------------------------------------------------------------

class _SkinOption {
  final String label;
  final IconData icon;

  const _SkinOption(
    this.label,
    this.icon,
  );
}

class _ToneOption {
  final String label;
  final Color color;

  const _ToneOption(
    this.label,
    this.color,
  );
}