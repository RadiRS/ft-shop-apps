import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus() async {
    final oldStatus = isFavorite;

    isFavorite = !isFavorite;

    // Like set state in statfull widget
    notifyListeners();

    try {
      final Uri url = Uri.parse(
          'https://e-ecommerce-firebase-v1.firebaseio.com/products/$id.json');

      final res = await http.patch(
        url,
        body: json.encode({'isFavorite': isFavorite}),
      );

      if (res.statusCode >= 400) {
        throw HttpException('Could not update product');
      }
    } catch (e) {
      isFavorite = oldStatus;
      notifyListeners();
      throw e;
    }
  }
}
