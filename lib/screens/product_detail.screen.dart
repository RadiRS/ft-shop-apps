import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  static String routeName = '/product-detail';

  const ProductDetailScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access navigation arguments to get the id
    final id = ModalRoute.of(context).settings.arguments as String;
    // get provider products & filter by id product (set listen to false to disable listener)
    final product = Provider.of<Products>(context, listen: false).findBydId(id);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(product.title),
      ),
      body: null,
    );
  }
}
