class AppUrls {
  AppUrls._();
  // Key 1: piyush137.yt@gmail,com
  static const String apiKey1 = "f30ea56f80960f899e470e0224104153";
  // Key 2: piyushdewangan218@gmail.com
  static const String apiKey2 = "83bd6d4f8b3a36967e6c25322312c919";
  // Key 3:pdinspire.yt@gamil.com
  static const String apiKey3 = "8da6659444afe897a93038ad8e0d8340";
  // Key 4:nullserver143@gmail.com
  static const String apiKey4 = "05f37a41796c6ca964e6701bb6c0ebca";

  // base url for gNews.io
  static const String baseUrl = "https://gnews.io/api/v4";

  // Search endpoints
  static const String featured =
      "$baseUrl/search?q=featured&lang=en&country=in&apikey=$apiKey1";
  static const String trending =
      "$baseUrl/search?q=trending&lang=en&country=in&apikey=$apiKey1";
  static const String breaking =
      "$baseUrl/search?q=breaking&lang=en&country=in&apikey=$apiKey1";
  static const String business =
      "$baseUrl/top-headlines?category=business&lang=en&country=in&apikey=$apiKey1";
  static const String sports =
      "$baseUrl/top-headlines?category=sports&lang=en&country=in&apikey=$apiKey2";
  static const String gaming =
      "$baseUrl/search?q=gaming&lang=en&country=in&apikey=$apiKey2";

  // top-headlines endpoints
  static const String recent =
      "$baseUrl/top-headlines?category=general&lang=en&country=in&apikey=$apiKey2";
  static const String technology =
      "$baseUrl/top-headlines?category=technology&lang=en&country=in&apikey=$apiKey3";
  static const String science =
      "$baseUrl/top-headlines?category=science&lang=en&country=in&apikey=$apiKey3";
  static const String health =
      "$baseUrl/top-headlines?category=health&lang=en&country=in&apikey=$apiKey3";
  static const String entertainment =
      "$baseUrl/top-headlines?category=entertainment&lang=en&country=in&apikey=$apiKey4";
  static const String nation =
      "$baseUrl/top-headlines?category=nation&lang=en&country=in&apikey=$apiKey4";
  static const String world =
      "$baseUrl/top-headlines?category=world&lang=en&country=in&apikey=$apiKey4";

  static String search(String query) {
    return "$baseUrl/search?q=$query&lang=en&country=in&apikey=$apiKey1";
  }
}
