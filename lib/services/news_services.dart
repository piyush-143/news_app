import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/news_model.dart';

class NewsServices {
  Future<NewsResponseModel> fetchNews(String url) async {
    // Retry logic: Attempt up to 3 times
    for (int i = 0; i < 3; i++) {
      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          return NewsResponseModel.fromJson(jsonDecode(response.body));
        }

        // --- Error Mapping ---
        if (i == 2) {
          // Only throw on the last attempt
          switch (response.statusCode) {
            case 400:
              throw const SocketException(
                "Bad Request (400): Invalid request parameters.",
              );
            case 401:
              throw const SocketException(
                "Unauthorized (401): Invalid API Key. Please check your configuration.",
              );
            case 403:
              throw const SocketException(
                "Access Forbidden (403): You may have reached your plan limit or the resource is restricted.",
              );
            case 404:
              throw const SocketException(
                "Not Found (404): The requested news resource was not found.",
              );
            case 429:
              throw const SocketException(
                "Rate Limit Exceeded (429): Too many requests. Please wait a moment.",
              );
            case 500:
              throw const SocketException(
                "Server Error (500): Internal server error. Try again later.",
              );
            case 502:
              throw const SocketException(
                "Bad Gateway (502): The server received an invalid response.",
              );
            case 503:
              throw const SocketException(
                "Service Unavailable (503): The server is temporarily overloaded.",
              );
            default:
              throw SocketException(
                "Error (${response.statusCode}): An unexpected error occurred.",
              );
          }
        }

        // If it's a retryable server error or rate limit, wait and retry
        if (response.statusCode == 429 || response.statusCode >= 500) {
          await Future.delayed(const Duration(seconds: 2));
          continue;
        } else {
          // Client errors (4xx) usually shouldn't be retried blindly, but loop handles logic above
          // We break loop by throwing if not 200 and not retryable
          await Future.delayed(const Duration(seconds: 1));
        }
      } catch (e) {
        // Throw specific error message on last attempt
        if (i == 2) rethrow;
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    throw const SocketException(
      "Connection Timeout: Failed to fetch news after retries.",
    );
  }
}
