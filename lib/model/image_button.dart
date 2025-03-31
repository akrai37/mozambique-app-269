class ImageButton {
  final String word;
  final String img;

  ImageButton({
    required this.word,
    required this.img,
  });

  factory ImageButton.fromJson(Map<String, dynamic> json) {
    return ImageButton(
      word: json['word'] as String,
      img: json['img'] as String,
    );
  }
}