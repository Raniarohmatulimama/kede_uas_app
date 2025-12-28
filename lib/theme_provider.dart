import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isLight = true;
  Color _primaryColor = const Color(0xFF007AFF);

  bool get isLight => _isLight;
  Color get primaryColor => _primaryColor;

  void setIsLight(bool value) {
    _isLight = value;
    notifyListeners();
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
  }
}
