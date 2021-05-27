// import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static String routeName = '/edit-product';

  EditProductScreen({Key key}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  // Added focus listeners to the input
  final picker = ImagePicker();
  final _priceFocuseNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  // Set global key form to access the state of Form widget
  final _form = GlobalKey<FormState>();
  File _image;
  bool _isLoaded = false;
  bool _isLoading = false;

  Product _editedProduct = Product(
    id: null,
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );

  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  @override
  void initState() {
    // Set add listeners image url focus
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _initialState();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // Clear the listeners to avoid memory leak
    _imageUrlController.removeListener(_updateImageUrl);
    _priceFocuseNode.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _initialState() {
    if (_isLoaded == true) return;

    final productId = ModalRoute.of(context).settings.arguments as String;

    if (productId != null) {
      _editedProduct = Provider.of<Products>(context).findBydId(productId);
      _initValues = {
        'title': _editedProduct.title,
        'description': _editedProduct.description,
        'price': _editedProduct.price.toString(),
        // 'imageUrl': _editedProduct.imageUrl,
      };

      // Set the initial value for image url input via the controller
      _imageUrlController.text = _editedProduct.imageUrl;
    }

    _imageUrlController.text = 'https://source.unsplash.com/random';

    _isLoaded = true;
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      var urlPattern =
          r"(https?|ftp)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
      var result = new RegExp(urlPattern, caseSensitive: false)
          .hasMatch(_imageUrlController.text);

      if (!result) return;
      // if (!result ||
      //     (!_imageUrlController.text.endsWith('.png') &&
      //         !_imageUrlController.text.endsWith('.jpg') &&
      //         !_imageUrlController.text.endsWith('.jpeg'))) return;

      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    // Dismiss soft keyboard
    FocusScope.of(context).unfocus();

    // Validate the form and is valid or not
    final isValid = _form.currentState.validate();

    if (!isValid) return;

    // Save product to form state
    _form.currentState.save();

    setState(() => _isLoading = true);

    // Check if has a product id then update the product other wise created new product
    if (_editedProduct.id != null) {
      await Provider.of<Products>(context, listen: false).updateProduct(
        _editedProduct.id,
        _editedProduct,
      );
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (err) {
        await showDialog<Null>(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text('An error accured'),
              content: Text('Something went wrong.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Okey'),
                )
              ],
            );
          },
        );
      }
      // finally {
      //   setState(() => _isLoading = false);
      //   Navigator.of(context).pop();
      // }
    }

    setState(() => _isLoading = false);

    Navigator.of(context).pop();
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final imageFile = await picker.getImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      imageQuality: 0,
    );

    setState(() {
      if (imageFile != null) _image = File(imageFile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                // autovalidateMode: AutovalidateMode.always,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: const InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      onFieldSubmitted: (_) {
                        // Set focus the next form input (manual step)
                        FocusScope.of(context).requestFocus(_priceFocuseNode);
                      },
                      validator: (value) {
                        if (value.isEmpty) return 'Please enter a title.';

                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                          title: value,
                          description: _editedProduct.description,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      decoration: const InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      focusNode: _priceFocuseNode,
                      validator: (value) {
                        if (value.isEmpty) return 'Please enter a price';

                        if (double.tryParse(value) == null)
                          return 'Please enter a valid number';

                        if (double.parse(value) <= 0)
                          return 'Please enter a number greater than zero';

                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                          title: _editedProduct.title,
                          description: _editedProduct.description,
                          price: double.parse(value),
                          imageUrl: _editedProduct.imageUrl,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      validator: (value) {
                        if (value.isEmpty) return 'Please enter a description';

                        if (value.length < 10)
                          return 'Should at lest 10 characters long';

                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          isFavorite: _editedProduct.isFavorite,
                          title: _editedProduct.title,
                          description: value,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: _takePicture,
                          child: Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(
                              top: 8,
                              right: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.grey,
                              ),
                            ),
                            child: _imageUrlController.text.isEmpty
                                ? const Text('Enter a URL or Select Image')
                                : FittedBox(
                                    child: _image != null
                                        ? Image.file(_image)
                                        : Image.network(
                                            _imageUrlController.text,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller:
                                _imageUrlController, // if using controller input can't set initial value
                            focusNode: _imageUrlFocusNode,
                            validator: (value) {
                              if (value.isEmpty)
                                return 'Please enter an image URL';

                              var urlPattern =
                                  r"(https?|ftp)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
                              var result =
                                  new RegExp(urlPattern, caseSensitive: false)
                                      .hasMatch(value);

                              if (!result) return 'Please enter a valid URL';

                              // if (!value.endsWith('.png') &&
                              //     !value.endsWith('.jpg') &&
                              //     !value.endsWith('.jpeg'))
                              //   return 'Please enter a valid Image URL';

                              return null;
                            },
                            onEditingComplete: () {
                              // Rebuild the widget to display an image
                              setState(() {});
                            },
                            onFieldSubmitted: (_) => _saveForm(),
                            onSaved: (value) {
                              _editedProduct = Product(
                                id: _editedProduct.id,
                                isFavorite: _editedProduct.isFavorite,
                                title: _editedProduct.title,
                                description: _editedProduct.description,
                                price: _editedProduct.price,
                                imageUrl: value,
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
