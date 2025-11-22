import 'package:flutter/material.dart';
import '../../../../data/repositories/auth_repository.dart';

class LoginController with ChangeNotifier {
  final AuthRepository _repo = AuthRepository();

  bool isLoading = false;

  bool isValidEmail(String email) {
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z]+\.((student)|(lecture))\.pens\.ac\.id$',
    );
    return regex.hasMatch(email);
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    final result = await _repo.login(email, password);

    isLoading = false;
    notifyListeners();

    return result;
  }
}
