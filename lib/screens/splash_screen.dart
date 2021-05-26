import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  final String routeName = '/splash';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Loading...'),
      ),
    );
  }
}
