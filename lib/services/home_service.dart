import 'package:flutter/material.dart';

// ---------- Models ----------
class SkinProduct {
  final String title; // e.g. "Products for dry skin type"
  final String label; // e.g. "Dry"
  final Color color;
  SkinProduct(this.title, this.label, this.color);
}

class Dermatologist {
  final String name, title, experience, image;
  final double rating;
  Dermatologist(this.name, this.title, this.experience, this.rating, this.image);
}

class Review {
  final String name, text;
  final double rating;
  final String? avatar;
  Review(this.name, this.rating, this.text, {this.avatar});
}

class GroomingItem {
  final String title, keyword; // keyword = internet search term
  final IconData icon;
  GroomingItem(this.title, this.keyword, this.icon);
}

class HomeData {
  final List<SkinProduct> products;
  final List<GroomingItem> grooming;
  final List<Dermatologist> dermatologists;
  final List<Review> reviews;
  HomeData(this.products, this.grooming, this.dermatologists, this.reviews);
}

// ---------- Service (connect your backend here) ----------
class HomeService {
  Future<HomeData> fetchHomeData() async {
    // TODO: Put your real backend call here (http / Dio / Supabase).
    // Example:
    // final res = await http.get(Uri.parse('$baseUrl/home'));
    // return HomeData.fromJson(jsonDecode(res.body));
    await Future.delayed(const Duration(milliseconds: 600));
    return HomeData(
      [
        SkinProduct('Products for dry\nskin type', 'Dry', const Color(0xFFB9825A)),
        SkinProduct('Products for oily\nskin type', 'Oily', const Color(0xFFE8C4B4)),
      ],
      [
        GroomingItem('Beard care', 'beard oil men', Icons.face),
        GroomingItem('Shaving', 'shaving men', Icons.content_cut),
        GroomingItem('Face wash', 'face wash men', Icons.water_drop_outlined),
        GroomingItem('Hair care', 'hair men', Icons.spa_outlined),
        GroomingItem('Aftershave', 'aftershave men', Icons.air),
      ],
      [
        Dermatologist('Dr. Jane Cooper', 'Senior Dermatologist',
            '10+ years Experience', 5.0, 'assets/images/dermatologist.jpg'),
      ],
      [
        Review('Leslie Alexander', 5.0,
            'My skin feels so much smoother after two weeks. The scan picked the right products for me.'),
        Review('Saily Jane', 5.0,
            'Great recommendations and the dermatologist consultation was quick and very helpful.'),
        Review('Daniel Brooks', 4.5,
            'The male grooming section is a great idea. My beard care routine finally makes sense.'),
      ],
    );
  }
}