import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SkinProfileScreen extends StatefulWidget {
  const SkinProfileScreen({super.key});
  @override
  State<SkinProfileScreen> createState() => _SkinProfileScreenState();
}

class _SkinProfileScreenState extends State<SkinProfileScreen> {
  String? _type;
  final _concerns = <String>{};
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    final ok = await ApiService()
        .saveSkinProfile({'type': _type, 'concerns': _concerns.toList()});
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profile saved')));
      Navigator.pop(context);
    }
  }

  Widget _chips(List<String> opts, bool Function(String) sel,
          void Function(String) tap) =>
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final o in opts)
          ChoiceChip(
            label: Text(o),
            selected: sel(o),
            selectedColor: Colors.black,
            labelStyle:
                TextStyle(color: sel(o) ? Colors.white : Colors.black),
            onSelected: (_) => setState(() => tap(o)),
          ),
      ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Personalize your profile'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Your skin type',
            style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        _chips(['Dry', 'Oily', 'Combination', 'Normal', 'Sensitive'],
            (o) => _type == o, (o) => _type = o),
        const SizedBox(height: 24),
        const Text('Your concerns',
            style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        _chips(['Acne', 'Dark spots', 'Wrinkles', 'Redness', 'Dullness'],
            _concerns.contains,
            (o) => _concerns.contains(o) ? _concerns.remove(o) : _concerns.add(o)),
        const SizedBox(height: 32),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24))),
          onPressed: (_type == null || _saving) ? null : _save,
          child: _saving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save'),
        ),
      ]),
    );
  }
}
