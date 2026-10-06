import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  String? _selectedGender;

  bool _hidePassword = true;
  bool _hideConfirm = true;
  bool _isLoading = false;

  // Track whether user has started typing
  bool _nameTouched = false;
  bool _ageTouched = false;
  bool _emailTouched = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ==============================
  // VALIDATION
  // ==============================

  bool get _nameValid {
    final name = _nameController.text.trim();

    if (name.isEmpty) return false;

    // Only letters and spaces
    return RegExp(
      r"^[a-zA-Z]+(?:[ .'-][a-zA-Z]+)*$",
    ).hasMatch(name);
  }

  bool get _ageValid {
    final age = int.tryParse(
      _ageController.text.trim(),
    );

    if (age == null) return false;

    return age >= 13 && age <= 100;
  }

  // ============================================================
  // ONLY GMAIL IS ALLOWED
  // ============================================================

  static const List<String> _allowedDomains = [
    'gmail.com',
  ];

  // ============================================================
  // EMAIL VALIDATION
  // ============================================================

  bool get _emailValid {
    // IMPORTANT:
    // Do NOT convert the email to lowercase here.
    // We want uppercase letters to be rejected.

    final email = _emailController.text.trim();

    if (email.isEmpty) return false;

    // ----------------------------------------------------------
    // EMAIL MUST BE COMPLETELY LOWERCASE
    //
    // eva@gmail.com -> VALID
    // Eva@gmail.com -> INVALID
    // EVA@gmail.com -> INVALID
    // eva@Gmail.com -> INVALID
    // ----------------------------------------------------------

    if (email != email.toLowerCase()) {
      return false;
    }

    // ----------------------------------------------------------
    // EMAIL MUST NOT CONTAIN SPACES
    // ----------------------------------------------------------

    if (email.contains(RegExp(r'\s'))) {
      return false;
    }

    // ----------------------------------------------------------
    // MUST HAVE EXACTLY ONE @
    // ----------------------------------------------------------

    final atCount = '@'.allMatches(email).length;

    if (atCount != 1) {
      return false;
    }

    final parts = email.split('@');

    if (parts.length != 2) {
      return false;
    }

    final localPart = parts[0];
    final domain = parts[1];

    // ----------------------------------------------------------
    // LOCAL PART CANNOT BE EMPTY
    // ----------------------------------------------------------

    if (localPart.isEmpty) {
      return false;
    }

    // ----------------------------------------------------------
    // MUST CONTAIN AT LEAST ONE LETTER
    //
    // 123@gmail.com  -> INVALID
    // 1234@gmail.com -> INVALID
    // eva123@gmail.com -> VALID
    // ----------------------------------------------------------

    if (!RegExp(r'[a-z]').hasMatch(localPart)) {
      return false;
    }

    // ----------------------------------------------------------
    // ONLY THESE CHARACTERS ARE ALLOWED:
    //
    // a-z
    // 0-9
    // .
    //
    // NO:
    // _
    // -
    // +
    // *
    // /
    // #
    // $
    // %
    // &
    // !
    // ----------------------------------------------------------

    final localRegex = RegExp(
      r'^[a-z0-9](?:[a-z0-9.]{0,63}[a-z0-9])?$',
    );

    if (!localRegex.hasMatch(localPart)) {
      return false;
    }

    // ----------------------------------------------------------
    // DOT RULES
    //
    // eva..name@gmail.com -> INVALID
    // .eva@gmail.com      -> INVALID
    // eva.@gmail.com      -> INVALID
    // eva.name@gmail.com  -> VALID
    // ----------------------------------------------------------

    if (localPart.contains('..')) {
      return false;
    }

    if (localPart.startsWith('.')) {
      return false;
    }

    if (localPart.endsWith('.')) {
      return false;
    }

    // ----------------------------------------------------------
    // DOMAIN MUST BE EXACTLY gmail.com
    // ----------------------------------------------------------

    if (!_allowedDomains.contains(domain)) {
      return false;
    }

    return true;
  }

  // ============================================================
  // SIMPLE EDIT DISTANCE
  // ============================================================

  int _editDistance(String a, String b) {
    final dp = List.generate(
      a.length + 1,
      (_) => List.filled(
        b.length + 1,
        0,
      ),
    );

    for (var i = 0; i <= a.length; i++) {
      dp[i][0] = i;
    }

    for (var j = 0; j <= b.length; j++) {
      dp[0][j] = j;
    }

    for (var i = 1; i <= a.length; i++) {
      for (var j = 1; j <= b.length; j++) {
        if (a[i - 1] == b[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1];
        } else {
          dp[i][j] =
              1 +
              [
                dp[i - 1][j],
                dp[i][j - 1],
                dp[i - 1][j - 1],
              ].reduce(
                (x, y) => x < y ? x : y,
              );
        }
      }
    }

    return dp[a.length][b.length];
  }

  // ============================================================
  // EMAIL SUGGESTION
  // ============================================================

  String? get _emailSuggestion {
    final email =
        _emailController.text.trim().toLowerCase();

    final parts = email.split('@');

    if (parts.length != 2) {
      return null;
    }

    final localPart = parts[0];
    final domain = parts[1];

    if (domain.isEmpty ||
        _allowedDomains.contains(domain)) {
      return null;
    }

    for (final allowed in _allowedDomains) {
      if (_editDistance(domain, allowed) <= 2) {
        return '$localPart@$allowed';
      }
    }

    return null;
  }

  // ==============================
  // SIGN UP
  // ==============================

  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _nameTouched = true;
      _ageTouched = true;
      _emailTouched = true;
    });

    // Name validation
    if (!_nameValid) {
      _showMessage('Write a valid name');
      return;
    }

    // Age validation
    if (!_ageValid) {
      _showMessage('Write a valid age');
      return;
    }

    // Gender validation
    if (_selectedGender == null) {
      _showMessage(
        'Please select your gender',
      );
      return;
    }

    // Email validation
    if (!_emailValid) {
      _showMessage('Write a valid email');
      return;
    }

    // Password validation
    if (_passwordController.text.length < 8) {
      _showMessage(
        'Password must be at least 8 characters',
      );
      return;
    }

    // Confirm password validation
    if (_passwordController.text !=
        _confirmController.text) {
      _showMessage(
        'Passwords do not match',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email =
          _emailController.text.trim();

      final password =
          _passwordController.text;

      final response =
          await Supabase
              .instance
              .client
              .auth
              .signUp(
                email: email,
                password: password,
              );

      if (!mounted) return;

      if (response.user != null) {
        _showMessage(
          'Account created. Please check your email for the 6-digit code.',
        );

        Navigator.pushNamed(
          context,
          '/authorize',
          arguments: email,
        );
      } else {
        _showMessage(
          'Unable to create account. Please try again.',
        );
      }
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage(
        'Something went wrong. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ==============================
  // MESSAGE
  // ==============================

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  // ==============================
  // VALIDATION ICON
  // ==============================

  Widget? _validationIcon({
    required bool touched,
    required bool valid,
  }) {
    if (!touched) return null;

    return Icon(
      valid
          ? Icons.check_circle
          : Icons.cancel,
      color: valid
          ? Colors.black
          : const Color(0xFFD94A4A),
      size: 20,
    );
  }

  // ==============================
  // NORMAL TEXT FIELD
  // ==============================

  Widget _field({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffix,
    ValueChanged<String>? onChanged,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 6),

        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          onChanged: onChanged,

          style: const TextStyle(
            fontSize: 14,
          ),

          decoration: InputDecoration(
            hintText: hint,

            hintStyle: const TextStyle(
              fontSize: 14,
              color: Color(0xFF9A9A9A),
            ),

            suffixIcon: suffix,

            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            isDense: true,

            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),

            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(8),

              borderSide: BorderSide(
                color: errorText != null
                    ? const Color(0xFFD94A4A)
                    : const Color(0xFFE5E5E5),
              ),
            ),

            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(8),

              borderSide: BorderSide(
                color: errorText != null
                    ? const Color(0xFFD94A4A)
                    : Colors.black,
              ),
            ),
          ),
        ),

        if (errorText != null) ...[
          const SizedBox(height: 4),

          Text(
            errorText,

            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFFD94A4A),
            ),
          ),
        ],
      ],
    );
  }

  // ==============================
  // PASSWORD EYE ICON
  // ==============================

  Widget _eyeButton(
    bool hidden,
    VoidCallback onTap,
  ) {
    return IconButton(
      onPressed: onTap,

      icon: Icon(
        hidden
            ? Icons.visibility_off_outlined
            : Icons.visibility_outlined,

        size: 18,

        color:
            const Color(0xFF8E8E93),
      ),
    );
  }

  // ==============================
  // GENDER
  // ==============================

  Widget _genderField() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',

          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 6),

        DropdownButtonFormField<String>(
          value: _selectedGender,

          decoration:
              InputDecoration(
            hintText:
                'Select your gender',

            hintStyle:
                const TextStyle(
              fontSize: 14,
              color: Color(0xFF9A9A9A),
            ),

            filled: true,
            fillColor:
                const Color(0xFFFAFAFA),

            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),

            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(8),

              borderSide:
                  const BorderSide(
                color: Color(0xFFE5E5E5),
              ),
            ),

            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(8),

              borderSide:
                  const BorderSide(
                color: Colors.black,
              ),
            ),
          ),

          items: const [
            DropdownMenuItem(
              value: 'Male',
              child: Text('Male'),
            ),

            DropdownMenuItem(
              value: 'Female',
              child: Text('Female'),
            ),

            DropdownMenuItem(
              value: 'Other',
              child: Text('Other'),
            ),

            DropdownMenuItem(
              value: 'Prefer not to say',
              child: Text(
                'Prefer not to say',
              ),
            ),
          ],

          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
        ),
      ],
    );
  }

  // ==============================
  // BUILD
  // ==============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.white,

      body: SafeArea(
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            24,
            24,
            24,
            24,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              const Text(
                'Sign up',

                style: TextStyle(
                  fontSize: 28,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(height: 32),

              // ==========================
              // NAME
              // ==========================

              _field(
                label: 'Name',
                hint: 'Enter your name',
                controller:
                    _nameController,

                keyboardType:
                    TextInputType.name,

                onChanged: (_) {
                  setState(() {
                    _nameTouched = true;
                  });
                },

                suffix:
                    _validationIcon(
                  touched:
                      _nameTouched,
                  valid:
                      _nameValid,
                ),

                errorText:
                    _nameTouched &&
                            _nameController
                                .text
                                .isNotEmpty &&
                            !_nameValid
                        ? 'Write a valid name'
                        : null,
              ),

              const SizedBox(height: 16),

              // ==========================
              // AGE
              // ==========================

              _field(
                label: 'Age',
                hint: 'Enter your age',
                controller:
                    _ageController,

                keyboardType:
                    TextInputType.number,

                onChanged: (_) {
                  setState(() {
                    _ageTouched = true;
                  });
                },

                suffix:
                    _validationIcon(
                  touched:
                      _ageTouched,
                  valid:
                      _ageValid,
                ),

                errorText:
                    _ageTouched &&
                            _ageController
                                .text
                                .isNotEmpty &&
                            !_ageValid
                        ? 'Write a valid age'
                        : null,
              ),

              const SizedBox(height: 16),

              // ==========================
              // GENDER
              // ==========================

              _genderField(),

              const SizedBox(height: 16),

              // ==========================
              // EMAIL
              // ==========================

              _field(
                label: 'Email',
                hint: 'example@gmail.com',

                controller:
                    _emailController,

                keyboardType:
                    TextInputType
                        .emailAddress,

                onChanged: (_) {
                  setState(() {
                    _emailTouched = true;
                  });
                },

                suffix:
                    _validationIcon(
                  touched:
                      _emailTouched,
                  valid:
                      _emailValid,
                ),

                errorText:
                    _emailTouched &&
                            _emailController
                                .text
                                .isNotEmpty
                        ? (!_emailValid
                            ? (_emailSuggestion !=
                                    null
                                ? 'Did you mean ${_emailSuggestion!}?'
                                : 'Write a valid email')
                            : null)
                        : null,
              ),

              const SizedBox(height: 16),

              // ==========================
              // PASSWORD
              // ==========================

              _field(
                label:
                    'Create a password',

                hint:
                    'must be 8 characters',

                controller:
                    _passwordController,

                obscure:
                    _hidePassword,

                suffix:
                    _eyeButton(
                  _hidePassword,
                  () => setState(
                    () => _hidePassword =
                        !_hidePassword,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ==========================
              // CONFIRM PASSWORD
              // ==========================

              _field(
                label:
                    'Confirm password',

                hint:
                    'repeat password',

                controller:
                    _confirmController,

                obscure:
                    _hideConfirm,

                suffix:
                    _eyeButton(
                  _hideConfirm,
                  () => setState(
                    () => _hideConfirm =
                        !_hideConfirm,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ==========================
              // SIGN UP BUTTON
              // ==========================

              SizedBox(
                width:
                    double.infinity,

                height: 48,

                child:
                    ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : _signUp,

                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        Colors.black,

                    foregroundColor:
                        Colors.white,

                    elevation: 0,

                    textStyle:
                        const TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w600,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        6,
                      ),
                    ),
                  ),

                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,

                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                Colors.white,
                          ),
                        )
                      : const Text(
                          'Sign Up',
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // ==========================
              // TERMS
              // ==========================

              const Center(
                child:
                    Text.rich(
                  TextSpan(
                    style:
                        TextStyle(
                      fontSize: 11,
                      height: 1.5,
                      color:
                          Color(
                        0xFF8E8E93,
                      ),
                    ),

                    children: [
                      TextSpan(
                        text:
                            'By creating an account or signing you\n'
                            'agree to our ',
                      ),

                      TextSpan(
                        text:
                            'Terms and Conditions',

                        style:
                            TextStyle(
                          fontWeight:
                              FontWeight.w700,

                          color:
                              Colors.black,

                          decoration:
                              TextDecoration
                                  .underline,
                        ),
                      ),
                    ],
                  ),

                  textAlign:
                      TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}