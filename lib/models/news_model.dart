class NewsModel {
  final String title;
  final String description;
  final String imageUrl;
  final String source;
  final String? link;
  final DateTime? pubDate;

  NewsModel({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.source,
    this.link,
    this.pubDate,
  });

  // Para cache local
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'source': source,
      'link': link,
      'pubDate': pubDate?.millisecondsSinceEpoch,
    };
  }

  factory NewsModel.fromMap(Map<String, dynamic> map) {
    return NewsModel(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      source: map['source'] ?? '',
      link: map['link'],
      pubDate: map['pubDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['pubDate'])
          : null,
    );
  }
}