import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/orders.dart' show Orders;
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static String routeName = '/orders';

  const OrdersScreen({Key key}) : super(key: key);

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  // bool _isLoading = false;

  @override
  void initState() {
    // initialRequest();
    super.initState();
  }

  // Future<void> initialRequest() async {
  //   this.setState(() => _isLoading = true);

  //   await Provider.of<Orders>(context, listen: false).fetchAndSetOrders();

  //   this.setState(() => _isLoading = false);
  // }

  @override
  Widget build(BuildContext context) {
    // final ordersProv = Provider.of<Orders>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      // Using a FutureBuilder widget only if the screen no needed to rebuild again
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
        // initialData: InitialData,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator.adaptive());
          } else {
            if (snapshot.error != null) {
              return Center(child: Text('An error accured'));
            } else {
              return Consumer<Orders>(builder: (_, ordersProv, child) {
                return ListView.builder(
                  itemCount: ordersProv.orders.length,
                  itemBuilder: (BuildContext context, int index) {
                    return OrderItem(order: ordersProv.orders[index]);
                  },
                );
              });
            }
          }
        },
      ),
      // body: _isLoading
      //     ? Center(child: CircularProgressIndicator.adaptive())
      //     : ListView.builder(
      //         itemCount: ordersProv.orders.length,
      //         itemBuilder: (BuildContext context, int index) {
      //           return OrderItem(order: ordersProv.orders[index]);
      //         },
      //       ),
      drawer: AppDrawer(),
    );
  }
}
