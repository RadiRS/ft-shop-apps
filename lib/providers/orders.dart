import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/providers/cart.dart';

class Orders with ChangeNotifier {
  final String authToken;
  final String userId;
  List<OrderItem> _orders = [];

  Orders(
    this.authToken,
    this.userId,
    this._orders,
  );

  List<OrderItem> get orders => [..._orders];

  Future<void> fetchAndSetOrders() async {
    Uri url = Uri.parse(
        'https://e-ecommerce-firebase-v1.firebaseio.com/orders/$userId.json?auth=$authToken');

    try {
      final List<OrderItem> loadedOrders = [];
      final res = await http.get(url);
      final jsonDecode = json.decode(res.body);

      final extractedData = jsonDecode as Map<String, dynamic>;

      if (extractedData == null) {
        _orders = [];
        notifyListeners();
        return;
      }

      extractedData.forEach((key, value) {
        loadedOrders.add(
          OrderItem(
            id: key,
            amount: value['amount'],
            dateTime: DateTime.parse(value['dateTime']),
            products: (value['products'] as List<dynamic>)
                .map(
                  (e) => CartItem(
                    id: e['id'],
                    title: e['title'],
                    quantity: e['quantity'],
                    price: e['price'],
                  ),
                )
                .toList(),
          ),
        );
      });

      _orders = loadedOrders;
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    Uri url = Uri.parse(
        'https://e-ecommerce-firebase-v1.firebaseio.com/orders/$userId.json?auth=$authToken');
    final timestamp = DateTime.now();

    try {
      final res = await http.post(
        url,
        body: json.encode({
          'amount': total,
          'dateTime': timestamp.toIso8601String(),
          'products': cartProducts
              .map((e) => {
                    'id': e.id,
                    'title': e.title,
                    'quantity': e.quantity,
                    'price': e.price
                  })
              .toList(),
        }),
      );

      _orders.insert(
        0,
        OrderItem(
          id: json.decode(res.body)['name'],
          amount: total,
          products: cartProducts,
          dateTime: DateTime.now(),
        ),
      );

      notifyListeners();
    } catch (e) {
      throw e;
    }
  }
}

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}
