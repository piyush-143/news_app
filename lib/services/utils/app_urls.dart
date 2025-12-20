class AppUrls {
  // Private constructor to prevent instantiation
  AppUrls._();

  // --- API Keys ---
  // 137
  static const String _apiKey1 = "f30ea56f80960f899e470e0224104153";
  //218
  static const String _apiKey2 = "83bd6d4f8b3a36967e6c25322312c919";
  //inspire
  static const String _apiKey3 = "8da6659444afe897a93038ad8e0d8340";
  //null
  static const String _apiKey4 = "05f37a41796c6ca964e6701bb6c0ebca";

  // Base URL for the GNews API
  static const String baseUrl = "https://gnews.io/api/v4";

  // --- Search Endpoints (Custom Queries) ---
  // Using Key 1
  static const String featured =
      "$baseUrl/search?q=featured&lang=en&country=in&apikey=$_apiKey1";
  static const String trending =
      "$baseUrl/search?q=trending&lang=en&country=in&apikey=$_apiKey1";
  static const String breaking =
      "$baseUrl/search?q=breaking&lang=en&country=in&apikey=$_apiKey1";
  static const String gaming =
      "$baseUrl/search?q=gaming&lang=en&country=in&apikey=$_apiKey1";

  // --- Top Headlines Endpoints (Category Based) ---

  // Using Key 2
  static const String business =
      "$baseUrl/top-headlines?category=business&lang=en&country=in&apikey=$_apiKey2";
  static const String sports =
      "$baseUrl/top-headlines?category=sports&lang=en&country=in&apikey=$_apiKey2";
  static const String recent =
      "$baseUrl/top-headlines?category=general&lang=en&country=in&apikey=$_apiKey2";

  // Using Key 3
  static const String technology =
      "$baseUrl/top-headlines?category=technology&lang=en&country=in&apikey=$_apiKey3";
  static const String science =
      "$baseUrl/top-headlines?category=science&lang=en&country=in&apikey=$_apiKey3";
  static const String health =
      "$baseUrl/top-headlines?category=health&lang=en&country=in&apikey=$_apiKey3";

  // Using Key 4
  static const String entertainment =
      "$baseUrl/top-headlines?category=entertainment&lang=en&country=in&apikey=$_apiKey4";
  static const String nation =
      "$baseUrl/top-headlines?category=nation&lang=en&country=in&apikey=$_apiKey4";
  static const String world =
      "$baseUrl/top-headlines?category=world&lang=en&country=in&apikey=$_apiKey4";

  // --- Dynamic Search ---

  /// specific query using the backup key (Key 4)
  static String search(String query) {
    return "$baseUrl/search?q=$query&lang=en&country=in&apikey=$_apiKey4";
  }
}
