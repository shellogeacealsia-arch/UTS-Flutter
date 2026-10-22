import 'package:flutter/foundation.dart';

/// Which bottom-navigation tab is selected (0 Home, 1 Favorite, 2 Cart).
class NavProvider extends ChangeNotifier {
  int _index = 0;

  int get index => _index;

  void setIndex(int value) {
    if (value == _index) return;
    _index = value;
    notifyListeners();
  }
}
