import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingService {
  static final SupabaseClient _supabase =
      Supabase.instance.client;

  static Future<void> saveOnboardingData({
    required String skinType,
    required String skinTone,
    required List<String> concerns,
    required String experience,
    required List<String> goals,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    await _supabase.from('profiles').upsert(
      {
        'id': user.id,
        'skin_type': skinType,
        'skin_tone': skinTone,
        'concerns': concerns,
        'skincare_experience': experience,
        'goals': goals,
        'onboarding_completed': true,
        'updated_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'id',
    );
  }

  static Future<Map<String, dynamic>?> getOnboardingData() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return response;
  }
}