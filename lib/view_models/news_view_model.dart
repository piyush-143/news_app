import 'package:flutter/material.dart';
import 'package:news_app/services/news_services.dart';

import '../models/news_model.dart';

/// ViewModel responsible for fetching, caching, and managing state for
/// various news categories independently.
class NewsViewModel with ChangeNotifier {
  final NewsServices _newsServices = NewsServices.instance;

  // --- State Variables (Cached Data) ---
  // Storing each category separately prevents re-fetching data when the user
  // switches tabs back and forth.
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

  // --- Public Getters ---
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

  // Global loading state (primarily for the initial dashboard load)
  bool loading = false;

  // --- Error Handling State ---
  // We map errors to specific categories. This ensures that if "Sports" fails,
  // the "Tech" tab can still show its data without being affected.
  final Map<String, String> _categoryErrors = {};

  String? getErrorForCategory(String category) =>
      _categoryErrors[category.toLowerCase()];

  // List of available categories for the UI TabBar or Filter Chips
  List<String> categories = [
    "All",
    "Tech",
    "Health",
    "Science",
    // "Gaming",
    "Business",
    "Entertainment",
    "Sports",
  ];

  // --- Data Access Helpers ---

  /// Helper to dynamically retrieve the correct cached data based on the UI category name.
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

  // --- Fetching Logic ---

  /// Generic fetch method that handles loading states, error capturing,
  /// and data assignment for any given category.
  Future<void> getNews(String url, String category) async {
    final key = category.toLowerCase();

    // Clear previous errors for this specific category before retrying
    _categoryErrors.remove(key);

    // Only trigger the global full-screen loader for primary sections.
    // Inner categories usually rely on their own skeleton loaders.
    if (key == "featured" || key == "recent") {
      loading = true;
    }

    // Clear old data to trigger a UI refresh (skeleton loading state)
    _resetDataByCategory(key);
    notifyListeners();

    try {
      final data = await _newsServices.fetchNews(url);
      _setDataByCategory(key, data);
    } catch (e) {
      // Clean up the error message and store it for this specific category
      _categoryErrors[key] = e.toString().replaceAll("Exception: ", "");
      debugPrint("Error fetching $key: $e");
    } finally {
      // Turn off global loader
      if (key == "featured" || key == "recent") {
        loading = false;
      }
      notifyListeners();
    }
  }

  // --- Internal State Management ---

  /// Clears the cached data for a specific category to force a UI reload.
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

  /// Assigns the fetched data to the correct state variable.
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
