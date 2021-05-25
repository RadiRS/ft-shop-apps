import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/product.dart';

// Configure global data products provider (mix in with ChangeNotifier)
class Products with ChangeNotifier {
  final String authToken;
  List<Product> _items = [];

  Products(
    this.authToken,
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

  Future<void> fetchAndSetProducts() async {
    Uri url = Uri.parse(
        'https://e-ecommerce-firebase-v1.firebaseio.com/products.json?auth=$authToken');

    // print(authToken);

    try {
      final List<Product> loadedProducts = [];
      final res = await http.get(url);
      final jsonDecode = json.decode(res.body);

      // * Print json data with beautiful format
      // JsonEncoder encoder = new JsonEncoder.withIndent('  ');
      // String prettyprint = encoder.convert(jsonDecode);
      // // print(json.decode(res.body));
      // print(prettyprint);

      final extractedData = jsonDecode as Map<String, dynamic>;

      if (extractedData == null) {
        _items = [];
        notifyListeners();
        return;
      }

      print(extractedData);

      extractedData.forEach((key, value) {
        loadedProducts.add(Product(
          id: key,
          title: value['title'],
          description: value['description'],
          price: value['price'],
          imageUrl: value['imageUrl'],
          isFavorite: value['isFavorite'],
        ));
      });

      _items = loadedProducts.reversed.toList();
      notifyListeners();
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<void> addProduct(Product item) async {
    Uri url = Uri.parse(
        'https://e-ecommerce-firebase-v1.firebaseio.com/products.json');

    try {
      final res = await http.post(
        url,
        body: json.encode({
          'title': item.title,
          'description': item.description,
          'imageUrl': item.imageUrl,
          'price': item.price,
          'isFavorite': item.isFavorite,
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
          'https://e-ecommerce-firebase-v1.firebaseio.com/products/$id.json');

      try {
        await http.patch(
          url,
          body: json.encode({
            'title': item.title,
            'description': item.description,
            'imageUrl': item.imageUrl,
            'price': item.price
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
        'https://e-ecommerce-firebase-v1.firebaseio.com/products/$id.json');

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
