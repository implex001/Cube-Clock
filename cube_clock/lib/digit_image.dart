import 'package:flutter/material.dart';

/// An animated image aligned to a custom grid
///
/// The [gridCoordinate] variable can be changed during runtime to move the image
/// to the new coordinate based on the animation curve defined in [curve].
class CubeImage extends StatelessWidget {
  CubeImage(
      {@required this.imagePath,
      @required this.gridCoordinate,
      @required this.grid,
      this.curve = Curves.elasticOut,
      this.imageGridRatio = 0.1374});

  /// The ratio between the size of the image and the custom grid
  final double imageGridRatio;

  /// Path to image asset
  final String imagePath;

  /// Two separate integers representing the x and y coordinates. x occupies the first section, y occupies the second
  final Coordinate gridCoordinate;

  /// The grid used to align the image to
  final OrthographicGrid grid;

  /// Animation curve to follow in the event of [gridCoordinate] changing
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    Offset realCoordinate = this.grid.getAlignment(gridCoordinate);

    return AnimatedAlign(
        alignment: Alignment(realCoordinate.dx, realCoordinate.dy),
        duration: Duration(milliseconds: 900),
        curve: curve,
        child: FractionallySizedBox(
          widthFactor: imageGridRatio,
          child: Image.asset(imagePath),
        ));
  }
}

/// A customisable grid
///
/// The cartesian plane or grid can be customised using transformations.
/// [offsetX] and [offsetY] are the origin point of the grid or translates.
/// [gradientX] and [gradientY] are the horizontal skew and vertical skew respectively.
/// [magnitudeX] and [magnitudeY] are the scale of the grid.
class OrthographicGrid {
  double offsetX;
  double offsetY;

  double gradientX;
  double gradientY;

  double magnitudeX;
  double magnitudeY;

  OrthographicGrid(this.offsetX, this.offsetY, this.magnitudeX, this.magnitudeY,
      this.gradientX, this.gradientY);

  getOrthographicX(Coordinate coordinates) {
    double isoX =
        offsetX + gradientY * coordinates.y + magnitudeX * coordinates.x;
    return isoX;
  }

  getOrthographicY(Coordinate coordinates) {
    double isoY =
        offsetY + gradientX * coordinates.x + magnitudeY * coordinates.y;
    return isoY;
  }

  /// Aligns given coordinate to the grid
  getAlignment(Coordinate coordinates) {
    return Offset(getOrthographicX(coordinates), getOrthographicY(coordinates));
  }
}

// A discrete representation of an object's position on a grid
class Coordinate {
  /// x coordinate
  int x;

  ///y coordinate
  int y;

  Coordinate(this.x, this.y);
}

/// A sequence of coordinates to animate through
class CoordinateSequence {
  List<Coordinate> path;
  int currentIteration;

  CoordinateSequence(this.path) {
    currentIteration = 0;
  }

  /// Iterates to the next coordinate in [path]
  void next() {
    if (currentIteration == path.length - 1) {
      currentIteration = 0;
    } else {
      currentIteration++;
    }
  }

  Coordinate currentCoordinate() {
    return path[currentIteration];
  }
}

/// Contains methods and paths to the images of digits and symbols
class ImageManager {
  static const List<String> _imageNumber = [
    'Zero.webp',
    'One.webp',
    'Two.webp',
    'Three.webp',
    'Four.webp',
    'Five.webp',
    'Six.webp',
    'Seven.webp',
    'Eight.webp',
    'Nine.webp'
  ];
  static const _specialCharacters = {
    'colon': 'Colon.webp',
    'cube': 'Cube.webp'
  };
  static const String imageDir = 'graphics/numbers/';

  /// Returns the asset image path given an integer or string
  ///
  /// If supplemented an integer, finds the respective image of the number in [_imageNumber]
  /// If supplemented a string, finds the special character in [_specialCharacters]
  static String getImagePath(dynamic characterName) {
    String imagePath;

    switch (characterName.runtimeType) {
      case int:
        {
          imagePath = _constructPath(_imageNumber[characterName]);
          break;
        }
      case String:
        {
          imagePath = _constructPath(_specialCharacters[characterName]);
          break;
        }
    }

    return imagePath;
  }

  /// Combines the directory path with the filename to create an image path
  static String _constructPath(String fileName) {
    return imageDir + fileName;
  }

  /// Caches all numbers in [_imageNumber]
  static void preCacheAllDigits(BuildContext context) {
    for (int i = 0; i < 9; i++) {
      precacheImage(Image.asset(getImagePath(i)).image, context);
    }
  }
}
