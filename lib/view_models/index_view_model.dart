import 'package:flutter/material.dart';

class IndexViewModel with ChangeNotifier {
  // --- UI State: Bottom Navigation ---
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  void setTabIndex(int index) {
    if (_currentTabIndex == index) return;
    _currentTabIndex = index;
    notifyListeners();
  }

  // --- UI State: Carousel Slider ---
  int _sliderIndex = 0;
  int get sliderIndex => _sliderIndex;
  void setSliderIndex(int index) {
    _sliderIndex = index;
    notifyListeners();
  }

  // --- UI State: Category Selection ---
  int _selectedCategoryIndex = 0;
  int get selectedCategoryIndex => _selectedCategoryIndex;

  void setSelectedCategoryIndex(int index) {
    _selectedCategoryIndex = index;
    notifyListeners();
  }

  // call before exiting the app
  void reset() {
    _currentTabIndex = 0;
    _sliderIndex = 0;
    _selectedCategoryIndex = 0;
    notifyListeners();
  }
}
