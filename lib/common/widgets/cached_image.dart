import 'package:cached_network_image/cached_network_image.dart';
import 'package:ddi/di.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:the_flashcard/common/cached_image/file_cache.dart';
import 'package:the_flashcard/common/common.dart';

class CachedImage extends StatelessWidget {
  static FileCache cachedManager = DI.get("image_cache_manager");

  final double width;
  final double height;
  final Decoration decoration;
  final String url;
  final ImageWidgetBuilder imageBuilder;

  /// Widget displayed while the target [imageUrl] is loading.
  final PlaceholderWidgetBuilder placeholder;

  /// Widget displayed while the target [imageUrl] failed loading.
  final LoadingErrorWidgetBuilder errorWidget;

  const CachedImage({
    Key key,
    @required this.url,
    this.width,
    this.height,
    this.decoration,
    @required this.imageBuilder,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return this.url?.isNotEmpty == true
        ? CachedNetworkImage(
            width: width,
            height: height,
            cacheManager: cachedManager,
            imageUrl: this.url,
            imageBuilder: imageBuilder,
            placeholder: placeholder ?? (_, __) => _buildPlaceHolder(),
            errorWidget: errorWidget ?? (_, __, ___) => _buildError(),
          )
        : errorWidget != null
            ? errorWidget(context, null, 'url is null')
            : _buildError();
  }

  Widget _buildPlaceHolder() {
    return XImageLoading(
      child: Container(
        height: height,
        width: width,
        decoration: decoration,
        color: decoration == null ? XedColors.white : null,
      ),
    );
  }

  Widget _buildError() {
    return Container(
      height: height,
      width: width,
      decoration: decoration,
      color: decoration == null ? XedColors.paleGrey : null,
    );
  }
}

class XImageLoading extends StatelessWidget {
  final Widget child;

  const XImageLoading({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300],
      highlightColor: Colors.grey[100],
      child: child,
    );
  }
}
