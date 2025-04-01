class ImageButton {
  final String word;
  final String img;
  final String audio;

  ImageButton({
    required this.word,
    required this.img,
    required this.audio,
  });

  factory ImageButton.fromJson(Map<String, dynamic> json) {
    return ImageButton(
      word: json['word'] as String,
      img: json['img'] as String,
      audio: json['audio'] as String,
    );
  }
}