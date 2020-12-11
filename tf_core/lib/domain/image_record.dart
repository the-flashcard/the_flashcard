class ImageRecord {
  final String thumbnail;
  final String url;
  final double height;
  final double width;

  ImageRecord(this.url, this.thumbnail, {this.height = 0, this.width = 0});
}
