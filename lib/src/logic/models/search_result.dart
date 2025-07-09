class SearchResult {
  final String title;
  final String url;
  final String imageUrl;

  SearchResult({
    required this.title,
    required this.url,
    required this.imageUrl,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      title: json['title'],
      url: json['url'],
      imageUrl: json['image_url'],
    );
  }
}
