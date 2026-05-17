import 'package:flutter/foundation.dart';

/// Estado del contenedor principal (índice de pestaña, etc.).
class HomeController extends ChangeNotifier {
  int tabIndex = 1;

  void setTab(int i) {
    tabIndex = i;
    notifyListeners();
  }
}
