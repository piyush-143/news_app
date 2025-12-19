class NewsResponseModel {
  final int totalArticles;
  final List<Article> articles;

  NewsResponseModel({required this.totalArticles, required this.articles});

  factory NewsResponseModel.fromJson(Map<String, dynamic> json) {
    return NewsResponseModel(
      totalArticles: json['totalArticles'] ?? 0,
      articles:
          (json['articles'] as List<dynamic>?)
              ?.map((e) => Article.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Article {
  final String title;
  final String description;
  final String content;
  final String url;
  final String image;
  final String publishedAt;
  final Source source;

  Article({
    required this.title,
    required this.description,
    required this.content,
    required this.url,
    required this.image,
    required this.publishedAt,
    required this.source,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      // Clean the content here
      content: _cleanContent(json['content']),
      url: json['url'] ?? '',
      image: json['image'] ?? 'https://via.placeholder.com/150',
      publishedAt: json['publishedAt'] ?? '',
      source: Source.fromJson(json['source'] ?? {}),
    );
  }

  /// Removes patterns like "[+1234 chars]" or "[326 char]" from the end of the string
  static String _cleanContent(String? content) {
    if (content == null) return '';
    // Regex explanation:
    // \s* -> Matches zero or more whitespaces
    // \[        -> Matches literal '['
    // .*?       -> Matches any character (non-greedy) to capture the number/symbol
    // chars?    -> Matches 'char' or 'chars'
    // \]        -> Matches literal ']'
    // $         -> Ensures it matches at the end of the string
    return content.replaceAll(RegExp(r'\s*\[.*?chars?\]$'), '');
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'url': url,
      'image': image,
      'publishedAt': publishedAt,
      'source': source.toJson(),
    };
  }
}

class Source {
  final String name;
  final String url;

  Source({required this.name, required this.url});

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(name: json['name'] ?? 'Unknown', url: json['url'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'url': url};
  }
}
