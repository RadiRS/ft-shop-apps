import 'package:flutter/material.dart';

class EditProductScreen extends StatefulWidget {
  static String routeName = '/edit-product';

  EditProductScreen({Key key}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  // Added focus listeners to the input
  final _priceFocuseNode = FocusNode();

  @override
  void dispose() {
    // Clear the listeners to avoid memory leak
    _priceFocuseNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  // Set focus the next form input (manual step)
                  FocusScope.of(context).requestFocus(_priceFocuseNode);
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Price'),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocuseNode,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                keyboardType: TextInputType.multiline,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
