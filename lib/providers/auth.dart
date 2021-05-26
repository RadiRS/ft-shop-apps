import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth => token != null;

  String get userId => _userId;

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }

    return null;
  }

  Future<void> _authentication(
      String email, String password, String urlSegment) async {
    try {
      final Uri url = Uri.parse(
          'https://identitytoolkit.googleapis.com/v1/$urlSegment?key=AIzaSyCOQVDusSkIPjZqWl0Tt_aCkloQRVIhbw8');

      final res = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );

      final jsonDecode = json.decode(res.body);

      if (jsonDecode['error'] != null) {
        throw HttpException(jsonDecode['error']['message']);
      }

      _token = jsonDecode['idToken'];
      _userId = jsonDecode['localId'];
      _expiryDate = DateTime.now().add(Duration(
        seconds: int.parse(jsonDecode['expiresIn']),
      ));

      _autoLogout();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      // Convert json to string
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
      });

      prefs.setString('userData', userData);
    } catch (e) {
      throw e;
    }
  }

  // Future method to return nothing or other future method
  Future<void> signup(String email, String password) async {
    return _authentication(email, password, 'accounts:signUp');
  }

  Future<void> signin(String email, String password) async {
    return _authentication(email, password, 'accounts:signInWithPassword');
  }

  // Future method to return boolean
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('userData')) return false;

    // Get user data String and convert to the Map
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) return false;

    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;

    notifyListeners();
    _autoLogout();

    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;

    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    // prefs.remove('userData');
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }

    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
