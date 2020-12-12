import 'package:flutter/material.dart';

class XedShadows {
  XedShadows._();

  static const shadow5 = BoxShadow(
    color: Color.fromARGB(13, 0, 0, 0),
    offset: Offset(0.0, 2.0),
    blurRadius: 4.0,
  );

  static const shadow10 = BoxShadow(
    color: Color.fromARGB(25, 0, 0, 0),
    offset: Offset(-5.0, 5.0),
    blurRadius: 10.0,
  );
  static const shadow10WithoutOffset = BoxShadow(
    color: Color.fromARGB(25, 0, 0, 0),
    offset: Offset(0.0, 0.0),
    blurRadius: 10.0,
  );
  static const shadow4 = BoxShadow(
    color: Color.fromARGB(77, 0, 0, 0),
    offset: Offset(0.0, 2.0),
    blurRadius: 4.0,
  );
}
