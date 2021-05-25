import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/auth.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // * Long version of code to return type of first argument
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    // * Simplify code using .. to return same format as above
    // Matrix4.rotationZ(-8 * pi / 180)..translate(-10.0);

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(21, 117, 255, 1).withOpacity(0.5),
                  Color.fromRGBO(25, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 60.0),
                      padding: EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 80.0,
                      ),
                      transform: Matrix4.rotationZ(10 * pi / 180)
                        ..translate(10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'Shooppe',
                        style: TextStyle(
                          color:
                              Theme.of(context).accentTextTheme.headline6.color,
                          fontSize: 50,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  void _shoErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('An Error Occured'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Okay'),
            )
          ],
        );
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) return;

    _formKey.currentState.save();

    setState(() => _isLoading = true);

    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<Auth>(context, listen: false).signin(
          _authData['email'],
          _authData['password'],
        );
      } else {
        await Provider.of<Auth>(context, listen: false).signup(
          _authData['email'],
          _authData['password'],
        );
      }
    } on HttpException catch (e) {
      String errorMesage = 'Authentication failed';

      if (e.message == 'EMAIL_EXISTS') {
        errorMesage = 'This email address is already in use.';
      } else if (e.message == 'INVALID_EMAIL') {
        errorMesage = 'This is not a valid email address.';
      } else if (e.message == 'WEAK_PASSWORD') {
        errorMesage = 'This password is to weak.';
      } else if (e.message == 'EMAIL_NOT_FOUND') {
        errorMesage = 'could not find a user with that email.';
      } else if (e.message == 'INVALID_PASSWORD') {
        errorMesage = 'Invalid password';
      }

      _shoErrorDialog(errorMesage);
    } catch (e) {
      print(e);
      const String errorMesage = 'Authentication failed';

      _shoErrorDialog(errorMesage);
    }

    setState(() => _isLoading = false);
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() => _authMode = AuthMode.Signup);
    } else {
      setState(() => _authMode = AuthMode.Login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        height: _authMode == AuthMode.Signup ? 320 : 260,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }

                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }

                    return null;
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                  },
                ),
                if (_authMode == AuthMode.Signup)
                  TextFormField(
                    enabled: _authMode == AuthMode.Signup,
                    decoration: InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                    validator: _authMode == AuthMode.Signup
                        ? (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match!';
                            }

                            return null;
                          }
                        : null,
                  ),
                SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    child: Text(
                      _authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP',
                      style: TextStyle(
                        color: Theme.of(context).primaryTextTheme.button.color,
                      ),
                    ),
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 8.0,
                      ),
                      primary: Theme.of(context).primaryColor,
                    ),
                    // shape: RoundedRectangleBorder(
                    //   borderRadius: BorderRadius.circular(30),
                    // ),
                    // padding:
                    //     EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    // color: Theme.of(context).primaryColor,
                    // textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),
                TextButton(
                  child: Text(
                    '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  onPressed: _switchAuthMode,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                      vertical: 4,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  // padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  // textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
