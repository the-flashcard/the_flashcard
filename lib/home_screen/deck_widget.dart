import 'package:flutter/material.dart';
import 'package:the_flashcard/common/cached_image/x_cached_image_widget.dart';
import 'package:the_flashcard/common/common.dart';
import 'package:the_flashcard/common/resources/dimens.dart';

class DeckWidget extends StatelessWidget {
  final String title;
  final int favorite;
  final int seen;
  final String thumbnail;
  final Image authorAvatar;

  DeckWidget(
      {@required this.title,
      this.favorite,
      this.seen,
      this.thumbnail,
      this.authorAvatar})
      : assert(title != null);

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(left: wp(10), right: wp(10)),
      height: hp(218),
      width: wp(167),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              margin: EdgeInsets.only(bottom: hp(5), right: wp(5)),
              height: hp(205),
              width: wp(154),
              decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 255, 255, 0.9),
                  border: Border.all(color: Color.fromRGBO(0, 0, 0, 0.1)),
                  borderRadius: BorderRadius.all(
                    Radius.circular(15),
                  )),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              margin: EdgeInsets.only(bottom: hp(9), right: wp(9)),
              height: hp(205),
              width: wp(154),
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 0.9),
                border: Border.all(color: Color.fromRGBO(0, 0, 0, 0.1)),
                borderRadius: BorderRadius.all(
                  Radius.circular(15),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              margin: EdgeInsets.only(bottom: hp(13), right: wp(13)),
              height: hp(205),
              width: wp(154),
              child: Stack(
                alignment: FractionalOffset.bottomLeft,
                children: <Widget>[
                  thumbnail != null
                      ? XCachedImageWidget(
                          url: thumbnail,
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                            color: Colors.white,
                          ),
                          imageBuilder: (_, ImageProvider imageProvider) {
                            return Container(
                              height: double.infinity,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: imageProvider,
                                ),
                                border: Border.all(
                                  color: Color.fromRGBO(0, 0, 0, 0.1),
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                            );
                          },
                        )
                      : SizedBox(),
                  Container(
                    child: FittedBox(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: ColorTextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    alignment: Alignment.bottomLeft,
                    margin: EdgeInsets.only(
                        bottom: hp(40), left: wp(10), right: wp(10)),
                  ),
                  Container(
                    alignment: Alignment.bottomLeft,
                    margin: EdgeInsets.only(left: wp(10)),
                    child: Row(
                      children: <Widget>[
                        _iconNumber(height, width, Icons.favorite, favorite),
                        Spacer(
                          flex: 5,
                        ),
                        seen != null
                            ? _iconNumber(
                                height, width, Icons.remove_red_eye, seen)
                            : null,
                        Spacer(
                          flex: 20,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              height: hp(30),
              width: wp(30),
              child: CircleAvatar(
                backgroundColor: Color.fromRGBO(255, 123, 150, 1),
                child: authorAvatar == null
                    ? Icon(
                        Icons.person,
                        color: Colors.white,
                      )
                    : authorAvatar,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _iconNumber(double height, double width, IconData icon, int number) {
    return Row(
      children: <Widget>[
        Container(
          height: hp(14),
          width: wp(14),
          margin: EdgeInsets.only(bottom: hp(10)),
          child: Icon(
            icon,
            size: 14,
            color: Color.fromRGBO(220, 221, 221, 1),
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: hp(7), left: wp(3)),
          child: Text(
            number.toString(),
            style: ColorTextStyle(
              color: Color.fromRGBO(220, 221, 221, 1),
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
