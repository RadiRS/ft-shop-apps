import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  static String routeName = '/product-detail';

  const ProductDetailScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context).settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Detail Product $id'),
      ),
      body: null,
    );
  }
}
