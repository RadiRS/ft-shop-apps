import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/product.dart';

// Configure global data products provider (mix in with ChangeNotifier)
class Products with ChangeNotifier {
  final String authToken;
  final String userId;
  List<Product> _items = [];

  Products(
    this.authToken,
    this.userId,
    this._items,
  );

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product findBydId(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    String filterString =
        filterByUser ? '&orderBy="userId"&equalTo="$userId"' : '';

    try {
      // Get the products data
      Uri url = Uri.parse(
          'https://e-ecommerce-firebase-v1.firebaseio.com/products.json?auth=$authToken$filterString');
      final List<Product> loadedProducts = [];
      final res = await http.get(url);
      final jsonDecode = json.decode(res.body);
      final extractedData = jsonDecode as Map<String, dynamic>;

      if (extractedData == null) {
        _items = [];
        notifyListeners();
        return;
      }

      // Get favorites data
      url = Uri.parse(
          'https://e-ecommerce-firebase-v1.firebaseio.com/user-favorites/$userId.json?auth=$authToken');
      final favRes = await http.get(url);
      final favData = json.decode(favRes.body);

      extractedData.forEach((key, value) {
        loadedProducts.add(Product(
          id: key,
          title: value['title'],
          description: value['description'],
          price: value['price'],
          imageUrl: value['imageUrl'],
          // * the mark of (??) means if value is null then set to false
          isFavorite: favData == null ? false : favData[key] ?? false,
        ));
      });

      _items = loadedProducts.reversed.toList();
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<void> addProduct(Product item) async {
    final Uri url = Uri.parse(
        'https://e-ecommerce-firebase-v1.firebaseio.com/products.json?auth=$authToken');

    try {
      final res = await http.post(
        url,
        body: json.encode({
          'title': item.title,
          'description': item.description,
          'imageUrl': item.imageUrl,
          'price': item.price,
          'userId': userId,
        }),
      );

      final newProduct = Product(
        id: json.decode(res.body)['name'],
        title: item.title,
        description: item.description,
        price: item.price,
        imageUrl: item.imageUrl,
      );

      _items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  Future<void> updateProduct(String id, Product item) async {
    final prodIndex = _items.indexWhere((element) => element.id == id);

    if (prodIndex >= 0) {
      final Uri url = Uri.parse(
          'https://e-ecommerce-firebase-v1.firebaseio.com/products/$id.json?auth=$authToken');

      try {
        await http.patch(
          url,
          body: json.encode({
            'title': item.title,
            'description': item.description,
            'imageUrl': item.imageUrl,
            'price': item.price,
            'userId': userId,
          }),
        );

        _items[prodIndex] = item;
        notifyListeners();
      } catch (e) {
        throw e;
      }
    } else {
      print('No Product');
    }
  }

  Future<void> deleteProduct(String id) async {
    final Uri url = Uri.parse(
        'https://e-ecommerce-firebase-v1.firebaseio.com/products/$id.json?auth=$authToken');

    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    var existingProduct = _items[existingProductIndex];

    try {
      _items.removeAt(existingProductIndex);

      // * For res.statusCode delete request error doesn't set to catch
      final res = await http.delete(url);

      if (res.statusCode >= 400) {
        throw HttpException('Could not delete product');
      }

      existingProduct = null;
      notifyListeners();
    } catch (e) {
      // print(e);
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw e;
    }

    // _items.removeWhere((element) => element.id == id);
  }
}
