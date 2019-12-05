
import 'package:flutter/widgets.dart';

class ImageManager{

  final List<String> _imageNumber = ['Zero.png', 'One.png', 'Two.png', 'Three.png', 'Four.png', 'Five.png', 'Six.png', 'Seven.png', 'Eight.png', 'Nine.png'];
  final _specialCharacters = {'colon': 'Colon.png', 'cube': 'Cube.png'};
  final String imageDir = 'graphics/numbers/';

  ImageManager();


  String getImagePath(dynamic characterName){

    String imagePath;

    switch (characterName.runtimeType) {
      case int: {
        imagePath = _constructPath(_imageNumber[characterName]);
        break;
      }
      case String: {
        imagePath = _constructPath(_specialCharacters[characterName]);
        break;
      }
    }

    return imagePath;
  }

  void preCacheAllDigits(BuildContext context){
    for(int i = 0; i < 9; i++){
      precacheImage(Image.asset(getImagePath(i)).image, context);
    }
  }

  String _constructPath(String fileName) {
    return imageDir + fileName;
  }

}