import 'package:flutter/material.dart';
import 'package:the_flashcard/common/common.dart';

class ButtonWhiteWidget extends StatelessWidget {
  final AssetImage icon;
  final double size;
  final VoidCallback onTap;

  const ButtonWhiteWidget({
    Key key,
    @required this.icon,
    this.size = 30,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: key,
      onTap: onTap != null ? () => XError.f0(onTap) : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 6,
                spreadRadius: 0,
                color: Color.fromARGB(25, 0, 0, 0),
              )
            ]),
        child: Container(
          margin: const EdgeInsets.all(5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: icon,
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
}
