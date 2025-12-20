import 'package:flutter/material.dart';

/// ViewModel responsible for managing transient UI state for the main screen,
/// such as the active tab, carousel position, and selected news category.
class IndexViewModel with ChangeNotifier {
  // --- Bottom Navigation State ---
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  /// Updates the active tab index.
  /// Includes a check to prevent unnecessary rebuilds if the index hasn't changed.
  void setTabIndex(int index) {
    if (_currentTabIndex == index) return;
    _currentTabIndex = index;
    notifyListeners();
  }

  // --- Carousel Slider State ---
  int _sliderIndex = 0;
  int get sliderIndex => _sliderIndex;

  /// Updates the current page index of the news carousel.
  void setSliderIndex(int index) {
    _sliderIndex = index;
    notifyListeners();
  }

  // --- News Category Selection State ---
  int _selectedCategoryIndex = 0;
  int get selectedCategoryIndex => _selectedCategoryIndex;

  /// Updates the currently selected news category filter.
  void setSelectedCategoryIndex(int index) {
    _selectedCategoryIndex = index;
    notifyListeners();
  }

  /// Resets all UI state to default values.
  /// Call this when the user logs out or the app needs a fresh start.
  void reset() {
    _currentTabIndex = 0;
    _sliderIndex = 0;
    _selectedCategoryIndex = 0;
    notifyListeners();
  }
}
