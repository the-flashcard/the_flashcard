import 'dart:ui';

import 'package:flutter/material.dart';

class XLinearGradient extends LinearGradient {
  const XLinearGradient(List<Color> colors, List<double> stops)
      : super(
          colors: colors,
          stops: stops,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
}

Gradient getGradientFromGradient(Gradient gradient) {
  return gradient.colors.length > 1
      ? LinearGradient(
          colors: [gradient.colors.first],
          stops: [1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
      : gradient;
}

const List<LinearGradient> gradients = const <LinearGradient>[
  XLinearGradient(
    [Colors.white],
    [1],
  ),
  XLinearGradient(
    [
      Color.fromARGB(255, 206, 159, 252),
      Color.fromARGB(255, 115, 103, 240),
    ],
    [0.1, 1],
  ),
  XLinearGradient(
    [
      Color.fromARGB(255, 255, 246, 183),
      Color.fromARGB(255, 246, 65, 108),
    ],
    [0.1, 1],
  ),
  XLinearGradient(
    [
      Color.fromARGB(255, 249, 119, 148),
      Color.fromARGB(255, 98, 58, 162),
    ],
    [0.1, 1],
  ),
  XLinearGradient(
    [
      Color.fromARGB(255, 67, 203, 255),
      Color.fromARGB(255, 151, 8, 204),
    ],
    [0.1, 1],
  ),
  XLinearGradient(
    [
      Color.fromARGB(255, 250, 215, 161),
      Color.fromARGB(255, 233, 109, 113),
    ],
    [0.1, 1],
  ),
  XLinearGradient(
    [
      Color.fromARGB(255, 255, 210, 111),
      Color.fromARGB(255, 54, 119, 255),
    ],
    [0.1, 1],
  ),
  XLinearGradient(
    [
      Color.fromARGB(255, 146, 255, 192),
      Color.fromARGB(255, 0, 38, 97),
    ],
    [0.1, 1],
  ),
  XLinearGradient(
    [
      Color.fromARGB(255, 238, 173, 146),
      Color.fromARGB(255, 96, 24, 220),
    ],
    [0.1, 1],
  ),
  XLinearGradient(
    [
      Color.fromARGB(255, 246, 206, 236),
      Color.fromARGB(255, 217, 57, 205),
    ],
    [0.1, 1],
  ),
  XLinearGradient(
    [
      Color.fromARGB(255, 82, 229, 231),
      Color.fromARGB(255, 19, 12, 183),
    ],
    [0.1, 1],
  ),
  XLinearGradient(
    [
      Color.fromARGB(255, 241, 202, 116),
      Color.fromARGB(255, 166, 77, 182),
    ],
    [0.1, 1],
  ),
  XLinearGradient(
    [
      Color.fromARGB(255, 232, 208, 122),
      Color.fromARGB(255, 83, 18, 214),
    ],
    [0.1, 1],
  ),
  XLinearGradient(
    [
      Color.fromARGB(255, 255, 243, 176),
      Color.fromARGB(255, 202, 38, 255),
    ],
    [0.1, 1],
  ),
  XLinearGradient(
    [
      Color.fromARGB(255, 255, 245, 195),
      Color.fromARGB(255, 148, 82, 165),
    ],
    [0.1, 1],
  ),
  XLinearGradient(
    [
      Color.fromARGB(255, 240, 95, 87),
      Color.fromARGB(255, 54, 9, 64),
    ],
    [0.1, 1],
  ),
  XLinearGradient(
    [
      Color.fromARGB(255, 255, 248, 134),
      Color.fromARGB(255, 240, 114, 182),
    ],
    [0.1, 1],
  ),
  XLinearGradient(
    [
      Color.fromARGB(255, 151, 171, 255),
      Color.fromARGB(255, 18, 53, 151),
    ],
    [0.1, 1],
  ),
  XLinearGradient(
    [
      Color.fromARGB(255, 255, 111, 216),
      Color.fromARGB(255, 56, 19, 194),
    ],
    [0.1, 1],
  ),
  XLinearGradient(
    [
      Color.fromARGB(255, 238, 154, 229),
      Color.fromARGB(255, 89, 97, 249),
    ],
    [0.1, 1],
  ),
  XLinearGradient(
    [
      Color.fromARGB(255, 255, 211, 165),
      Color.fromARGB(255, 253, 101, 133),
    ],
    [0.1, 1],
  ),
  XLinearGradient(
    [
      Color.fromARGB(255, 253, 101, 133),
      Color.fromARGB(255, 13, 37, 185),
    ],
    [0.1, 1],
  ),
  XLinearGradient(
    [
      Color.fromARGB(255, 255, 166, 183),
      Color.fromARGB(255, 30, 42, 210),
    ],
    [0.1, 1],
  ),
  XLinearGradient(
    [
      Color.fromARGB(255, 59, 38, 103),
      Color.fromARGB(255, 188, 120, 236),
    ],
    [0.1, 1],
  ),
  XLinearGradient(
    [
      Color.fromARGB(255, 60, 140, 231),
      Color.fromARGB(255, 0, 234, 255),
    ],
    [0.1, 1],
  ),
  XLinearGradient(
    [
      Color.fromARGB(255, 250, 178, 255),
      Color.fromARGB(255, 25, 4, 229),
    ],
    [0.1, 1],
  ),
  XLinearGradient(
    [
      Color.fromARGB(255, 129, 255, 239),
      Color.fromARGB(255, 240, 103, 180),
    ],
    [0.1, 1],
  ),
  XLinearGradient(
    [
      Color.fromARGB(255, 255, 207, 113),
      Color.fromARGB(255, 35, 118, 221),
    ],
    [0.1, 1],
  ),
];
