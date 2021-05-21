import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/orders.dart' show Orders;
import 'package:shop_app/widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  static String routeName = '/orders';

  const OrdersScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ordersProv = Provider.of<Orders>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      body: ListView.builder(
        itemCount: ordersProv.orders.length,
        itemBuilder: (BuildContext context, int index) {
          return OrderItem(order: ordersProv.orders[index]);
        },
      ),
    );
  }
}
