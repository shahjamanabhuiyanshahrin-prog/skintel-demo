
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const Color purple = Color(0xFF56366F);
  static const Color pink = Color(0xFFFCE2E2);

  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _picker = ImagePicker();

  String? _gender;
  String? _skinType;
  String? _skinTone;

  List<String> _concerns = [];
  List<String> _goals = [];

  String? _avatarUrl;
  String? _newAvatarPath;

  bool _loading = true;
  bool _saving = false;
  bool _changePassword = false;
  bool _changeEmail = false;
  bool _obscurePassword = true;

  final List<String> _skinTypes = [
    'Dry',
    'Oily',
    'Normal',
    'Acne',
    'Combination',
  ];

  final List<String> _skinTones = [
    'Light',
    'Medium Light',
    'Medium',
    'Medium Dark',
    'Dark',
  ];

  
final List<String> _concernOptions = [
  'Black/White heads',
  'Dark Under Eyes',
  'Hyper-Pigmentation',
  'Roughness',
  'Sensitivity',
  'Wrinkles',
  'Dullness',
  'Large Pores',
  'Acne Scars',
];

final List<String> _goalOptions = [
  'Fix concerns',
  'Discover skincare products',
  'Educate myself',
  'Learn more about my skin',
  'Apply home treatments',
  'Practice facial yoga (coming soon)',
];


  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  Future<void> _loadProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Please log in again.');
      }

      final row = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (!mounted) return;

      _nameController.text =
          (row?['name'] ?? user.userMetadata?['name'] ?? '').toString();

      _ageController.text = (row?['age'] ?? user.userMetadata?['age'] ?? '')
          .toString();

      _emailController.text = user.email ?? '';

      _gender = (row?['gender'] ?? user.userMetadata?['gender'])?.toString();

      _skinType = row?['skin_type']?.toString();
      _skinTone = row?['skin_tone']?.toString();

      _concerns = _stringList(row?['concerns']);
      _goals = _stringList(row?['goals']);
      _avatarUrl = row?['avatar_url']?.toString();

      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load profile: $e')),
      );
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1000,
      );

      if (!mounted || image == null) return;

      setState(() => _newAvatarPath = image.path);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not select photo: $e')),
      );
    }
  }

  Future<String?> _uploadPhoto(String userId) async {
    if (_newAvatarPath == null) return _avatarUrl;

    final file = File(_newAvatarPath!);
    final path = '$userId/avatar.jpg';

    await _supabase.storage.from('profile-photos').upload(
          path,
          file,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );

    return _supabase.storage.from('profile-photos').getPublicUrl(path);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _supabase.auth.currentUser;
    if (user == null) return;

    setState(() => _saving = true);

    try {
      final name = _nameController.text.trim();
      final age = int.tryParse(_ageController.text.trim());

      final avatar = await _uploadPhoto(user.id);

      await _supabase.auth.updateUser(
        UserAttributes(
          data: {
            'name': name,
            if (age != null) 'age': age,
            if (_gender != null) 'gender': _gender,
          },
        ),
      );

      await _supabase.from('profiles').upsert(
        {
          'id': user.id,
          'name': name,
          'age': age,
          'gender': _gender,
          'avatar_url': avatar,
          'skin_type': _skinType,
          'skin_tone': _skinTone,
          'concerns': _concerns,
          'goals': _goals,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'id',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save profile: $e'),
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _updateEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email address')),
      );
      return;
    }

    try {
      await _supabase.auth.updateUser(
        UserAttributes(email: email),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Check your email for the confirmation link. '
            'Your email may change after confirmation.',
          ),
          duration: Duration(seconds: 5),
        ),
      );

      setState(() => _changeEmail = false);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update email: $e')),
      );
    }
  }

  Future<void> _updatePassword() async {
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 8 characters'),
        ),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: password),
      );

      if (!mounted) return;

      _passwordController.clear();
      _confirmPasswordController.clear();

      setState(() => _changePassword = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update password: $e')),
      );
    }
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: purple,
        ),
      ),
    );
  }

  Widget _textField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _dropdown(
    String label,
    String? value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    final validValue =
        value != null && options.contains(value) ? value : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: validValue,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        items: options
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _multiSelect(
    String title,
    List<String> options,
    List<String> selected,
    ValueChanged<List<String>> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          ...options.map(
            (option) => CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              activeColor: purple,
              title: Text(option, style: const TextStyle(fontSize: 14)),
              value: selected.contains(option),
              onChanged: (checked) {
                final next = List<String>.from(selected);

                if (checked == true && !next.contains(option)) {
                  next.add(option);
                } else {
                  next.remove(option);
                }

                onChanged(next);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _newAvatarPath != null
        ? FileImage(File(_newAvatarPath!)) as ImageProvider
        : (_avatarUrl != null && _avatarUrl!.isNotEmpty)
            ? NetworkImage(_avatarUrl!)
            : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F5),
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFFF8F6F5),
        foregroundColor: const Color(0xFF242126),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: purple))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 52,
                          backgroundColor: Colors.white,
                          backgroundImage: imageProvider,
                          child: imageProvider == null
                              ? const Icon(
                                  Icons.person,
                                  size: 52,
                                  color: purple,
                                )
                              : null,
                        ),
                        TextButton.icon(
                          onPressed: _pickPhoto,
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Change profile picture'),
                        ),
                      ],
                    ),
                  ),

                  _sectionTitle('Personal Information'),

                  _textField(
                    'Full name',
                    _nameController,
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Enter your name'
                            : null,
                  ),

                  _textField(
                    'Age',
                    _ageController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final age = int.tryParse(value ?? '');
                      if (age == null || age < 1 || age > 120) {
                        return 'Enter a valid age';
                      }
                      return null;
                    },
                  ),

                  _dropdown(
                    'Gender',
                    _gender,
                    ['Female', 'Male', 'Other', 'Prefer not to say'],
                    (value) => setState(() => _gender = value),
                  ),

                  _sectionTitle('Skin Profile'),

                  _dropdown(
                    'Skin Type',
                    _skinType,
                    _skinTypes,
                    (value) => setState(() => _skinType = value),
                  ),

                  _dropdown(
                    'Skin Tone',
                    _skinTone,
                    _skinTones,
                    (value) => setState(() => _skinTone = value),
                  ),

                  _multiSelect(
                    'Skin Concerns',
                    _concernOptions,
                    _concerns,
                    (value) => setState(() => _concerns = value),
                  ),

                  _multiSelect(
                    'Skincare Goals',
                    _goalOptions,
                    _goals,
                    (value) => setState(() => _goals = value),
                  ),

                  _sectionTitle('Email Address'),

                  _textField(
                    'Email',
                    _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),

                  OutlinedButton(
                    onPressed: () {
                      setState(() => _changeEmail = !_changeEmail);
                    },
                    child: Text(
                      _changeEmail ? 'Cancel email change' : 'Change email',
                    ),
                  ),

                  if (_changeEmail) ...[
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _updateEmail,
                      child: const Text('Request email change'),
                    ),
                  ],

                  _sectionTitle('Password'),

                  OutlinedButton(
                    onPressed: () {
                      setState(
                        () => _changePassword = !_changePassword,
                      );
                    },
                    child: Text(
                      _changePassword
                          ? 'Cancel password change'
                          : 'Change password',
                    ),
                  ),

                  if (_changePassword) ...[
                    const SizedBox(height: 12),
                    _textField(
                      'New password',
                      _passwordController,
                      obscure: _obscurePassword,
                      validator: null,
                    ),
                    _textField(
                      'Confirm new password',
                      _confirmPasswordController,
                      obscure: _obscurePassword,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Show password'),
                      value: !_obscurePassword,
                      onChanged: (value) {
                        setState(() => _obscurePassword = !value);
                      },
                    ),
                    ElevatedButton(
                      onPressed: _updatePassword,
                      child: const Text('Update password'),
                    ),
                  ],

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}