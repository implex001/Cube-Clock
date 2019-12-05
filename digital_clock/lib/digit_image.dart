import 'package:flutter/material.dart';
import 'isogrid.dart';

class CubeImage extends StatelessWidget {
  //Size screenSize = MediaQuery.of(context).size;
  //final cubeRatio = screenSize.width * (11/240);
  CubeImage(
      {@required this.imagePath,
      @required this.coordinate,
      @required this.grid,
      this.curve});

  final double imageGridRatio = 0.0458;

  final dynamic imagePath;
  final List<int> coordinate;
  final OrthographicGrid grid;

  Curve curve;

  @override
  Widget build(BuildContext context) {
    if (curve == null) {
      curve = Curves.elasticOut;
    }

    return AnimatedAlign(
        alignment: Alignment(this.grid.getOrthographicX(coordinate),
            this.grid.getOrthographicY(coordinate)),
        duration: Duration(milliseconds: 900),
        curve: curve,
        child: FractionallySizedBox(
          widthFactor: imageGridRatio * 3,
          child: Image.asset(imagePath),
        ));
  }
}
