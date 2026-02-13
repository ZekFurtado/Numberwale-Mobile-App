import 'package:flutter/cupertino.dart';
import 'package:numberwale/src/authentication/domain/entities/local_user.dart';

class UserProvider extends ChangeNotifier {
  LocalUser? _user;

  LocalUser? get user => _user;

  void initUser(LocalUser? user) {
    if (_user != user) _user = user;
  }

  set user(LocalUser? user) {
    if (_user != user) {
      _user = user;
    }
    // Future.delayed(Duration.zero, notifyListeners);
  }

  void updateUserCoins(int newCoinBalance) {
    if (_user != null) {
      _user = LocalUser(
        uid: _user!.uid,
        name: _user!.name,
        firstName: _user!.firstName,
        lastName: _user!.lastName,
        email: _user!.email,
        phone: _user!.phone,
        profilePic: _user!.profilePic,
        role: _user!.role,
        coins: newCoinBalance,
        isFirstTime: _user!.isFirstTime,
      );
      notifyListeners();
    }
  }

  void updateUser(LocalUser newUser) {
    if (_user != newUser) {
      _user = newUser;
      notifyListeners();
    }
  }
}
