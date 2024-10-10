import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:online_food_order_app/models/user.dart';

class AuthNotifier extends ChangeNotifier {
  User? _user;

  User? get user {
    return _user;
  }

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  // Test
  UserModel? _userDetails;

  UserModel? get userDetails => _userDetails;

  setUserDetails(UserModel user) {
    _userDetails = user;
    notifyListeners();
  }
}
