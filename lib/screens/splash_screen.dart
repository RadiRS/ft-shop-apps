import 'package:flutter/material.dart';
import 'package:shop_app/size_config.dart';

class SplashScreen extends StatelessWidget {
  final String routeName = '/splash';

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Center(
        child: Text('Loading...'),
      ),
    );
  }
}
