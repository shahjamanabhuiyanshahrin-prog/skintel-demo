
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/onboarding_service.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color backgroundColor = Color(0xFFF8F6F5);
  static const Color pinkColor = Color(0xFFFCE2E2);
  static const Color purpleColor = Color(0xFF56366F);
  static const Color borderColor = Color(0xFFE1DCDC);

  late Future<Map<String, dynamic>> _profileFuture;
  bool _showGoals = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<Map<String, dynamic>> _loadProfile() async {
    final result = await OnboardingService.getOnboardingData();
    final user = Supabase.instance.client.auth.currentUser;

    final data = result == null
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(result);

    // Fallbacks for information stored during signup.
    final metadata = user?.userMetadata ?? {};

    data['name'] ??= metadata['name'];
    data['age'] ??= metadata['age'];
    data['gender'] ??= metadata['gender'];
    data['avatar_url'] ??= metadata['avatar_url'];

    // Email is provided by Supabase Auth.
    data['email'] ??= user?.email;

    return data;
  }

  Future<void> _refreshProfile() async {
    final future = _loadProfile();

    if (!mounted) return;

    setState(() {
      _profileFuture = future;
    });

    await future;
  }

  Future<void> _openEditProfile() async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const EditProfileScreen(),
      ),
    );

    if (!mounted) return;

    if (updated == true) {
      await _refreshProfile();
    }
  }

  String _displayValue(dynamic value, String fallback) {
    if (value == null || value.toString().trim().isEmpty) {
      return fallback;
    }

    return value.toString();
  }

  List<String> _toStringList(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      return value
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList();
    }

    if (value is String && value.trim().isNotEmpty) {
      return [value];
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: purpleColor,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 42),
                      const SizedBox(height: 12),
                      const Text(
                        'Could not load profile information.',
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          _refreshProfile();
                        },
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = snapshot.data ?? <String, dynamic>{};

            final skinType = _displayValue(
              data['skin_type'],
              'Not selected',
            );

            final skinTone = _displayValue(
              data['skin_tone'],
              'Not selected',
            );

            final concerns = _toStringList(data['concerns']);
            final goals = _toStringList(data['goals']);

            final name = _displayValue(
              data['name'],
              'Your Profile',
            );

            final avatarUrl = data['avatar_url']?.toString();

            return RefreshIndicator(
              onRefresh: _refreshProfile,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  // Header
                  Row(
                    children: [
                      const Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Settings',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Settings will be available soon.',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.settings_outlined),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // User information and edit button
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            avatarUrl != null && avatarUrl.isNotEmpty
                                ? NetworkImage(avatarUrl)
                                : null,
                        child: avatarUrl == null || avatarUrl.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 30,
                                color: purpleColor,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: purpleColor,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Edit profile',
                        onPressed: _openEditProfile,
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 25,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Concerns and goals card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _tabButton(
                                title: 'Concern',
                                selected: !_showGoals,
                                onTap: () {
                                  setState(() => _showGoals = false);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _tabButton(
                                title: 'Goal',
                                selected: _showGoals,
                                onTap: () {
                                  setState(() => _showGoals = true);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if ((_showGoals ? goals : concerns).isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            child: Text(
                              _showGoals
                                  ? 'No goals selected yet'
                                  : 'No concerns selected yet',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          )
                        else
                          ...(_showGoals ? goals : concerns).map(
                            (item) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 5,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _showGoals
                                        ? Icons.flag_outlined
                                        : Icons.check_box,
                                    size: 18,
                                    color: _showGoals
                                        ? purpleColor
                                        : const Color(0xFF69BE45),
                                  ),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: Text(
                                      item.replaceAll('_', ' '),
                                      style: const TextStyle(
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Factors',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  _factorRow(
                    icon: Icons.face_retouching_natural,
                    title: 'Skin Type',
                    subtitle: 'Skin characteristics',
                    value: skinType,
                  ),

                  _factorRow(
                    icon: Icons.water_drop_outlined,
                    title: 'Skin Tone',
                    subtitle: 'Your selected skin tone',
                    value: skinTone,
                  ),

                  _factorRow(
                    icon: Icons.spa_outlined,
                    title: 'Oiliness',
                    subtitle: 'Sebum protection',
                    value: 'Not analyzed',
                  ),

                  _factorRow(
                    icon: Icons.grain,
                    title: 'Texture',
                    subtitle: 'Surface feel',
                    value: 'Not analyzed',
                  ),

                  _factorRow(
                    icon: Icons.palette_outlined,
                    title: 'Tone',
                    subtitle: 'Color consistency',
                    value: 'Not analyzed',
                  ),

                  _factorRow(
                    icon: Icons.search,
                    title: 'Elasticity',
                    subtitle: 'Skin firmness',
                    value: 'Not analyzed',
                  ),

                  _factorRow(
                    icon: Icons.spa,
                    title: 'Sensitivity',
                    subtitle: 'Reactivity',
                    value: 'Not analyzed',
                  ),

                  const SizedBox(height: 16),

                  // Scan insights
                  Material(
                    color: const Color(0xFFE5DEDE),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Connect this button to your scan insights screen.",
                            ),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.face_retouching_natural,
                              size: 30,
                              color: purpleColor,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "See Scan's Insights",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _tabButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? pinkColor : const Color(0xFFF6F5F5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? pinkColor : borderColor,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _factorRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 21,
              color: purpleColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}