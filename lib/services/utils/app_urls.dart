class AppUrls {
  // --- API KEYS ---
  // Use two different keys to distribute the load and avoid Rate Limiting (429)

  // Key 1: For Search Endpoints + Business + Sports
  // piyush137.yt@gmail.com
  static const String apiKeySearch = "f30ea56f80960f899e470e0224104153";

  // Key 2: For Category/Headline Endpoints (Tech, Nation, etc.)
  // piyushdewangan218@gmail.com
  static const String apiKeyHeadlines = "83bd6d4f8b3a36967e6c25322312c919";

  // Base URL
  static const String baseUrl = "https://gnews.io/api/v4";

  // --- KEY 1 ENDPOINTS (apiKeySearch) ---

  static const String featured =
      "$baseUrl/search?q=featured&lang=en&country=in&apikey=$apiKeySearch";

  static const String trending =
      "$baseUrl/search?q=trending&lang=en&country=in&apikey=$apiKeySearch";

  static const String breaking =
      "$baseUrl/search?q=breaking&lang=en&country=in&apikey=$apiKeySearch";

  static const String gaming =
      "$baseUrl/search?q=gaming&lang=en&country=in&apikey=$apiKeySearch";

  // Moved Business to Key 1
  static const String business =
      "$baseUrl/top-headlines?category=business&lang=en&country=in&apikey=$apiKeySearch";

  // Moved Sports to Key 1
  static const String sports =
      "$baseUrl/top-headlines?category=sports&lang=en&country=in&apikey=$apiKeySearch";

  static String search(String query) {
    return "$baseUrl/search?q=$query&lang=en&country=in&apikey=$apiKeySearch";
  }

  // --- KEY 2 ENDPOINTS (apiKeyHeadlines) ---

  // Using 'general' category often yields better results for 'recent' than a keyword search
  static const String recent =
      "$baseUrl/top-headlines?category=general&lang=en&country=in&apikey=$apiKeyHeadlines";

  static const String technology =
      "$baseUrl/top-headlines?category=technology&lang=en&country=in&apikey=$apiKeyHeadlines";

  static const String science =
      "$baseUrl/top-headlines?category=science&lang=en&country=in&apikey=$apiKeyHeadlines";

  static const String health =
      "$baseUrl/top-headlines?category=health&lang=en&country=in&apikey=$apiKeyHeadlines";

  static const String entertainment =
      "$baseUrl/top-headlines?category=entertainment&lang=en&country=in&apikey=$apiKeyHeadlines";

  static const String nation =
      "$baseUrl/top-headlines?category=nation&lang=en&country=in&apikey=$apiKeyHeadlines";

  static const String world =
      "$baseUrl/top-headlines?category=world&lang=en&country=in&apikey=$apiKeyHeadlines";
}
