import 'package:flutter/material.dart';
import 'package:news_app/services/news_services.dart';

import '../models/news_model.dart';

class NewsViewModel with ChangeNotifier {
  final NewsServices _newsServices = NewsServices();

  // --- UI State: Bottom Navigation ---
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  void setTabIndex(int index) {
    if (_currentTabIndex == index) return;
    _currentTabIndex = index;
    notifyListeners();
  }

  // --- UI State: Category Selection ---
  int _selectedCategoryIndex = 0;
  int get selectedCategoryIndex => _selectedCategoryIndex;

  void setSelectedCategoryIndex(int index) {
    _selectedCategoryIndex = index;
    notifyListeners();
  }

  // --- State Variables ---
  NewsResponseModel? _featuredNewsList;
  NewsResponseModel? _recentNewsList;
  NewsResponseModel? _trendingNews;
  NewsResponseModel? _breakingNews;
  NewsResponseModel? _technologyNews;
  NewsResponseModel? _healthNews;
  NewsResponseModel? _sportsNews;
  NewsResponseModel? _scienceNews;
  NewsResponseModel? _gamingNews;
  NewsResponseModel? _businessNews;
  NewsResponseModel? _entertainmentNews;
  NewsResponseModel? _nationNews;
  NewsResponseModel? _worldNews;

  // --- Getters ---
  NewsResponseModel? get featuredNewsList => _featuredNewsList;
  NewsResponseModel? get recentNewsList => _recentNewsList;
  NewsResponseModel? get trendingNews => _trendingNews;
  NewsResponseModel? get breakingNews => _breakingNews;
  NewsResponseModel? get technologyNews => _technologyNews;
  NewsResponseModel? get healthNews => _healthNews;
  NewsResponseModel? get sportsNews => _sportsNews;
  NewsResponseModel? get scienceNews => _scienceNews;
  NewsResponseModel? get gamingNews => _gamingNews;
  NewsResponseModel? get businessNews => _businessNews;
  NewsResponseModel? get entertainmentNews => _entertainmentNews;
  NewsResponseModel? get nationNews => _nationNews;
  NewsResponseModel? get worldNews => _worldNews;

  bool loading = false;

  // Map to store errors per category key
  final Map<String, String> _categoryErrors = {};

  String? getErrorForCategory(String category) {
    return _categoryErrors[category.toLowerCase()];
  }

  List<String> categories = [
    "All",
    "Tech",
    "Health",
    "Science",
    "Gaming",
    "Business",
    "Entertainment",
    "Sports",
  ];

  // --- Fetching Logic ---

  NewsResponseModel? getNewsByCategory(String category) {
    switch (category.toLowerCase()) {
      case "all":
        return _recentNewsList;
      case "tech":
        return _technologyNews;
      case "health":
        return _healthNews;
      case "science":
        return _scienceNews;
      case "gaming":
        return _gamingNews;
      case "business":
        return _businessNews;
      case "entertainment":
        return _entertainmentNews;
      case "sports":
        return _sportsNews;
      default:
        return _recentNewsList;
    }
  }

  Future<void> getNews(String url, String category) async {
    final key = category.toLowerCase();

    // 1. Clear previous errors immediately
    _categoryErrors.remove(key);

    // 2. Set loading state for main categories
    if (key == "featured" || key == "recent") {
      loading = true;
    }

    // 3. Reset specific data to trigger "Loading" state in UI (since data becomes null)
    _resetDataByCategory(key);

    // 4. CRITICAL: Notify listeners HERE to update UI immediately to "Loading" state
    notifyListeners();

    try {
      final data = await _newsServices.fetchNews(url);
      _setDataByCategory(key, data);
    } catch (e) {
      _categoryErrors[key] = e.toString().replaceAll("Exception: ", "");
      debugPrint("Error fetching $key: $e");
    } finally {
      if (key == "featured" || key == "recent") {
        loading = false;
      }
      // Notify again when data arrives or error occurs
      notifyListeners();
    }
  }

  void _resetDataByCategory(String category) {
    switch (category) {
      case "featured":
        _featuredNewsList = null;
        break;
      case "recent":
        _recentNewsList = null;
        break;
      case "trending":
        _trendingNews = null;
        break;
      case "breaking":
        _breakingNews = null;
        break;
      case "technology":
        _technologyNews = null;
        break;
      case "health":
        _healthNews = null;
        break;
      case "sports":
        _sportsNews = null;
        break;
      case "science":
        _scienceNews = null;
        break;
      case "gaming":
        _gamingNews = null;
        break;
      case "business":
        _businessNews = null;
        break;
      case "entertainment":
        _entertainmentNews = null;
        break;
      case "nation":
        _nationNews = null;
        break;
      case "world":
        _worldNews = null;
        break;
    }
  }

  void _setDataByCategory(String category, NewsResponseModel data) {
    switch (category) {
      case "featured":
        _featuredNewsList = data;
        break;
      case "recent":
        _recentNewsList = data;
        break;
      case "trending":
        _trendingNews = data;
        break;
      case "breaking":
        _breakingNews = data;
        break;
      case "technology":
        _technologyNews = data;
        break;
      case "health":
        _healthNews = data;
        break;
      case "sports":
        _sportsNews = data;
        break;
      case "science":
        _scienceNews = data;
        break;
      case "gaming":
        _gamingNews = data;
        break;
      case "business":
        _businessNews = data;
        break;
      case "entertainment":
        _entertainmentNews = data;
        break;
      case "nation":
        _nationNews = data;
        break;
      case "world":
        _worldNews = data;
        break;
    }
  }
}
