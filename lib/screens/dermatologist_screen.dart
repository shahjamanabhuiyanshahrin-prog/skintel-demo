import 'package:flutter/material.dart';

class DermatologistScreen extends StatelessWidget {
  const DermatologistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ekhon dummy list. Pore location onujayi real doctor list ashbe.
    final doctors = [
      {'name': 'Dr. Jane Cooper', 'title': 'Senior Dermatologist', 'exp': '10+ years'},
      {'name': 'Dr. Alex Smith', 'title': 'Dermatologist', 'exp': '7 years'},
      {'name': 'Dr. Maria Khan', 'title': 'Skin Specialist', 'exp': '5 years'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dermatologists'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: doctors.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final d = doctors[i];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5EFEC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.brown.shade300,
                child: Text(d['name']![4],
                    style: const TextStyle(color: Colors.white, fontSize: 18)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d['name']!,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    Text(d['title']!, style: const TextStyle(fontSize: 12)),
                    Text(d['exp']!, style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ]),
          );
        },
      ),
    );
  }
}