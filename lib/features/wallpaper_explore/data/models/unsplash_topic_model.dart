class UnsplashTopicModel {
  final String id;
  final String slug;
  final String title;
  final String? description;
  final String? coverPhotoUrl;

  const UnsplashTopicModel({
    required this.id,
    required this.slug,
    required this.title,
    this.description,
    this.coverPhotoUrl,
  });

  factory UnsplashTopicModel.fromJson(Map<String, dynamic> json) {
    final coverPhoto = json['cover_photo'] as Map<String, dynamic>?;
    final urls = coverPhoto != null ? coverPhoto['urls'] as Map<String, dynamic>? : null;

    return UnsplashTopicModel(
      id: json['id'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      coverPhotoUrl: urls != null ? (urls['small'] as String? ?? urls['thumb'] as String?) : null,
    );
  }
}
