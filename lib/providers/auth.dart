import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  // String _token;
  // DateTime _expiryDate;
  // String _userId;

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

      print(json.decode(res.body));
    } catch (e) {
      throw e;
    }
  }

  Future<void> signup(String email, String password) async {
    try {
      return _authentication(email, password, 'accounts:signUp');
    } catch (e) {
      throw e;
    }
  }

  Future<void> signin(String email, String password) async {
    try {
      return _authentication(email, password, 'accounts:signInWithPassword');
    } catch (e) {
      throw e;
    }
  }
}
