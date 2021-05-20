import 'package:flutter/material.dart';
import 'package:shop_app/screens/product_detail.screen.dart';
import 'package:shop_app/screens/products_overview.screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Online Shop Apps',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        accentColor: Colors.deepOrangeAccent,
        fontFamily: 'Lato',
      ),
      routes: {
        '/': (_) => ProductsOverviewScreen(),
        ProductDetailScreen.routeName: (_) => ProductDetailScreen()
      },
    );
  }
}
