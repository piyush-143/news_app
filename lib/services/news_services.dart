import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:news_app/models/news_model.dart';

class NewsServices {
  // Private constructor to enforce Singleton pattern (only one instance exists)
  NewsServices._();
  static final NewsServices instance = NewsServices._();

  // Limit request duration to 20 seconds
  static const Duration _timeout = Duration(seconds: 20);

  /// Fetches news data from the [url] with retry logic and error handling.
  Future<NewsResponseModel> fetchNews(String url) async {
    const int maxAttempts = 3;
    int attempt = 0;

    while (attempt < maxAttempts) {
      attempt++;
      try {
        final uri = Uri.parse(url);

        // Make the request with a strict timeout
        final response = await http.get(uri).timeout(_timeout);

        if (response.statusCode == 200) {
          return NewsResponseModel.fromJson(jsonDecode(response.body));
        }

        // Fail immediately on Client Errors (4xx) except for Rate Limits (429).
        // 4xx errors usually mean the request URL or params are wrong, so retrying won't help.
        if (response.statusCode >= 400 &&
            response.statusCode < 500 &&
            response.statusCode != 429) {
          throw _handleStatusCode(response.statusCode);
        }

        // If this was the last attempt, stop and throw the error.
        if (attempt == maxAttempts) {
          throw _handleStatusCode(response.statusCode);
        }

        // Exponential Backoff: Wait longer between retries (2s, 4s, etc.)
        // to give the server time to recover.
        await Future.delayed(Duration(seconds: attempt * 2));
      } on SocketException {
        // Handle Network Errors (No Internet)
        if (attempt == maxAttempts) {
          throw const SocketException(
            "No Internet Connection. Please check your data or wifi.",
          );
        }
        await Future.delayed(Duration(seconds: attempt * 2));
      } on TimeoutException {
        // Handle Request Timeouts
        if (attempt == maxAttempts) {
          throw const SocketException(
            "Connection Timed out. Server is taking too long to respond.",
          );
        }
        await Future.delayed(Duration(seconds: attempt * 2));
      } catch (e) {
        // Handle unexpected errors
        if (attempt == maxAttempts) rethrow;
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    throw const SocketException("Unexpected error occurred.");
  }

  /// Converts HTTP status codes into user-friendly error messages.
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
