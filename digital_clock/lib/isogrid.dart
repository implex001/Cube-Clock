
class OrthographicGrid{
  double offsetX;
  double offsetY;

  double gradientX;
  double gradientY;

  double magnitudeX;
  double magnitudeY;

  OrthographicGrid(this.offsetX, this.offsetY, this.magnitudeX, this.magnitudeY, this.gradientX, this.gradientY);

  getOrthographicX(List<int> coordinates) {
    double isoX = offsetX + gradientY  * coordinates[1] + magnitudeX * coordinates[0];
    return isoX;

  }

  getOrthographicY(List<int> coordinates){
    double isoY = offsetY + gradientX *  coordinates[0] + magnitudeY * coordinates[1];
    return isoY;
  }

  getCoordinates(List<int> coordinates){
    return [getOrthographicX(coordinates), getOrthographicY(coordinates)];
  }
}