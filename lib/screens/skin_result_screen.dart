import 'package:flutter/material.dart';
import 'products_screen.dart';

/// Shown after a face scan. Compares the scan with the skin type saved in the
/// user's profile (onboarding) and lets the user choose which one to use.
/// Products below the card follow the chosen skin type.
class SkinResultScreen extends StatefulWidget {
  final String scanType; // what the face scan suggests
  final String? savedType; // from the profile, or null if not set
  final String notes; // short text from the backend

  const SkinResultScreen({
    super.key,
    required this.scanType,
    this.savedType,
    this.notes = '',
  });

  @override
  State<SkinResultScreen> createState() => _SkinResultScreenState();
}

class _SkinResultScreenState extends State<SkinResultScreen> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    // If the user already told us their skin type, start with that one.
    _selected = widget.savedType ?? widget.scanType;
  }

  @override
  Widget build(BuildContext context) {
    return ProductsScreen(
      // A new key reloads the products when the choice changes.
      key: ValueKey(_selected),
      skinType: _selected,
      title: 'Your skin result',
      header: _SkinChoiceCard(
        scanType: widget.scanType,
        savedType: widget.savedType,
        selected: _selected,
        notes: widget.notes,
        onSelect: (t) => setState(() => _selected = t),
      ),
    );
  }
}

class _SkinChoiceCard extends StatelessWidget {
  final String scanType;
  final String? savedType;
  final String selected;
  final String notes;
  final ValueChanged<String> onSelect;

  const _SkinChoiceCard({
    required this.scanType,
    required this.savedType,
    required this.selected,
    required this.notes,
    required this.onSelect,
  });

  Widget _chip(String label, String type) {
    final isSelected = selected == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Colors.black,
      backgroundColor: Colors.white,
      showCheckmark: false,
      labelStyle: TextStyle(
        fontSize: 12,
        color: isSelected ? Colors.white : Colors.black,
      ),
      onSelected: (_) => onSelect(type),
    );
  }

  @override
  Widget build(BuildContext context) {
    final saved = savedType;
    final differs = saved != null && saved != scanType;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFEC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Face scan suggests: $scanType',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(notes, style: const TextStyle(fontSize: 11)),
          ],
          const SizedBox(height: 10),
          if (differs) ...[
            Text(
              'Your profile says: $saved. Which should we use for your products?',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _chip('My profile: $saved', saved),
                _chip('Face scan: $scanType', scanType),
              ],
            ),
          ] else if (saved != null)
            const Text(
              'This matches your profile.',
              style: TextStyle(fontSize: 12),
            ),
          const SizedBox(height: 8),
          const Text(
            'This is an estimate, not a medical diagnosis.',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Text(
            'Recommended products for $selected skin',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}