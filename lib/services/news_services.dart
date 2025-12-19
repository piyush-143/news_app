import 'dart:async'; // Required for TimeoutException
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:news_app/models/news_model.dart';

class NewsServices {
  // Singleton Pattern
  NewsServices._();
  static final NewsServices instance = NewsServices._();

  // Timeout duration for requests
  static const Duration _timeout = Duration(seconds: 20);

  Future<NewsResponseModel> fetchNews(String url) async {
    const int maxAttempts = 3;
    int attempt = 0;

    while (attempt < maxAttempts) {
      attempt++;
      try {
        final uri = Uri.parse(url);

        // Added timeout to prevent app hanging on slow connections
        final response = await http.get(uri).timeout(_timeout);

        if (response.statusCode == 200) {
          return NewsResponseModel.fromJson(jsonDecode(response.body));
        }

        // OPTIMIZATION: Don't retry Client Errors (4xx) except 429.
        // A 404 or 401 will not fix itself on retry. Fail fast.
        if (response.statusCode >= 400 &&
            response.statusCode < 500 &&
            response.statusCode != 429) {
          throw _handleStatusCode(response.statusCode);
        }

        // If it's the last attempt, throw the error
        if (attempt == maxAttempts) {
          throw _handleStatusCode(response.statusCode);
        }

        // If Server Error (5xx) or Rate Limit (429), wait and retry.
        // Exponential backoff: 2s, 4s...
        await Future.delayed(Duration(seconds: attempt * 2));
      } on SocketException {
        // Network error (No Internet)
        if (attempt == maxAttempts) {
          throw const SocketException(
            "No Internet Connection. Please check your data or wifi.",
          );
        }
        await Future.delayed(Duration(seconds: attempt * 2));
      } on TimeoutException {
        // Connection Timed out
        if (attempt == maxAttempts) {
          throw const SocketException(
            "Connection Timed out. Server is taking too long to respond.",
          );
        }
        await Future.delayed(Duration(seconds: attempt * 2));
      } catch (e) {
        // Any other unknown error
        if (attempt == maxAttempts) rethrow;
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    throw const SocketException("Unexpected error occurred.");
  }

  // Extracted error mapping for cleaner code
  SocketException _handleStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return const SocketException(
          "Bad Request (400): Invalid request parameters.",
        );
      case 401:
        return const SocketException("Unauthorized (401): Invalid API Key.");
      case 403:
        return const SocketException(
          "Forbidden (403): Access denied or limit reached.",
        );
      case 404:
        return const SocketException("Not Found (404): Resource not found.");
      case 429:
        return const SocketException(
          "Rate Limit (429): Too many requests. Please wait.",
        );
      case 500:
        return const SocketException(
          "Server Error (500): Internal server error.",
        );
      case 502:
        return const SocketException(
          "Bad Gateway (502): Invalid response from upstream.",
        );
      case 503:
        return const SocketException(
          "Service Unavailable (503): Server overloaded.",
        );
      default:
        return SocketException(
          "Error ($statusCode): An unexpected error occurred.",
        );
    }
  }
}
