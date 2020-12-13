part of answer_option;

class _ImageView extends StatelessWidget {
  final String url;
  final double height;
  final double width;
  final double radius;
  final BoxFit fit;

  _ImageView(
      {this.url,
      this.height = 50,
      this.width,
      this.radius = 15,
      this.fit = BoxFit.contain});

  @override
  Widget build(BuildContext context) {
    return url == null || url.trim().isEmpty
        ? _defaultImage()
        : CachedImage(
            url: url,
            width: width,
            height: height,
            imageBuilder: (_, ImageProvider imageProvider) {
              return Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  color: XedColors.paleGrey,
                  image: DecorationImage(
                    image: imageProvider,
                    alignment: Alignment.center,
                    fit: fit,
                  ),
                ),
              );
            },
            placeholder: (_, __) {
              return XImageLoading(
                child: Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    color: XedColors.white255,
                  ),
                ),
              );
            },
            errorWidget: (_, __, ___) => _defaultImage(),
          );
  }

  Widget _defaultImage() {
    return Stack(
      children: <Widget>[
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: XedColors.paleGrey,
          ),
        ),
        Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(0, 0, 0, 0),
                Color.fromARGB(25, 0, 0, 0),
                Color.fromARGB(75, 0, 0, 0),
              ],
              stops: [0.5, 0.68, 1.0],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        )
      ],
    );
  }
}
