import 'package:flutter/material.dart';

class PageCtrl with ChangeNotifier {
  int _currentIndex = 1;

  PageController pageController = PageController(initialPage: 1);

  int get currentIndex {
    return _currentIndex;
  }

  void changeIndex(index) {
    _currentIndex = index;
    print(index);
    pageController.animateToPage(index,
        duration: Duration(milliseconds: 200), curve: Curves.ease);
//    notifyListeners();
  }
}
