import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/cart.screen.dart';
import 'package:shop_app/screens/edit_product.screen.dart';
import 'package:shop_app/screens/orders.screen.dart';
import 'package:shop_app/screens/product_detail.screen.dart';
import 'package:shop_app/screens/products_overview.screen.dart';
import 'package:shop_app/screens/splash_screen.dart';
import 'package:shop_app/screens/user_products.screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Setup notifier provider
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Auth()),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: null,
          update: (_, auth, prevProducts) => Products(
            auth.token,
            auth.userId,
            prevProducts == null ? [] : prevProducts.items,
          ),
        ),
        ChangeNotifierProvider(create: (_) => Cart()),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: null,
          update: (_, auth, prevOrders) => Orders(
            auth.token,
            auth.userId,
            prevOrders == null ? [] : prevOrders.orders,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (_, auth, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Online Shop',
            theme: ThemeData(
              primarySwatch: Colors.deepPurple,
              accentColor: Colors.deepOrangeAccent,
              fontFamily: 'Lato',
            ),
            home: auth.isAuth
                ? ProductsOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SplashScreen();
                      }

                      return AuthScreen();
                    },
                  ),
            routes: {
              ProductDetailScreen.routeName: (_) => ProductDetailScreen(),
              CartScreen.routeName: (_) => CartScreen(),
              OrdersScreen.routeName: (_) => OrdersScreen(),
              UserProductsScreen.routeName: (_) => UserProductsScreen(),
              EditProductScreen.routeName: (_) => EditProductScreen(),
              AuthScreen.routeName: (_) => AuthScreen(),
            },
          );
        },
      ),
    );
  }
}
