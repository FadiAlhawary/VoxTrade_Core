class News {
  final String category;
  final String headline;
  final int datetime;
  final int id;
  final String image;
  final String? related;
  final String source;
  final String summary;
  final String url;

  News({
    required this.id,
    required this.category,
    required this.datetime,
    required this.image,
    required this.related,
    required this.source,
    required this.summary,
    required this.url,
    required this.headline,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      category: json['category'],
      datetime: json['datetime'],
      id: json['id'],
      image: json['image'],
      related: json['related'],
      source: json['source'],
      summary: json['summary'],
      url: json['url'],
      headline: json['headline'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'datetime': datetime,
      'id': id,
      'image': image,
      'related': related,
      'source': source,
      'summary': summary,
      'url': url,
      'headline': headline,
    };
  }
}
