import 'package:flutter/material.dart';

class LocalOrder {
  final String name;
  final String phone;
  final String address;
  final String city;
  final List<dynamic> items;
  final num delivery;
  final num total;
  final String paymentMethod;
  final String paymentStatus;
  final bool saved;
  final DateTime createdAt;

  LocalOrder({
    this.name = '',
    this.phone = '',
    this.address = '',
    required this.city,
    required this.items,
    required this.delivery,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.saved,
    required this.createdAt,
  });
}

class OrderHistory extends ChangeNotifier {
  OrderHistory._();
  static final OrderHistory instance = OrderHistory._();

  final List<LocalOrder> orders = [];

  void add({
    String name = '',
    String phone = '',
    String address = '',
    required String city,
    required List<dynamic> items,
    required num delivery,
    required num total,
    required String paymentMethod,
    required String paymentStatus,
    bool saved = false,
  }) {
    orders.insert(
      0,
      LocalOrder(
        name: name,
        phone: phone,
        address: address,
        city: city,
        items: items,
        delivery: delivery,
        total: total,
        paymentMethod: paymentMethod,
        paymentStatus: paymentStatus,
        saved: saved,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}