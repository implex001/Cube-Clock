// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'isogrid.dart';
import 'digit_image.dart';
import 'image_manager.dart';

enum _Element {
  background,
  text,
  shadow,
}

final _lightTheme = {
  _Element.background: Color(0xfff54242),
  _Element.text: Colors.white,
  _Element.shadow: Colors.black,
};

final _darkTheme = {
  _Element.background: Colors.black,
  _Element.text: Colors.white,
  _Element.shadow: Color(0xFF174EA6),
};

class CubeClock extends StatefulWidget {
  const CubeClock(this.model);

  final ClockModel model;

  @override
  _CubeClockState createState() => _CubeClockState();
}

class _CubeClockState extends State<CubeClock>
    with SingleTickerProviderStateMixin {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  Timer _resetPositionTimer;

  int digitAnimationBackwards = 3;
  int digitAnimationForwards = 3;
  List<int> secondAnimation = [0, 0];

  ImageManager imageManager = ImageManager();

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(CubeClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _resetPositionTimer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();

      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
      if (_dateTime.second == 59) {
        _pushDigitPosition();
      }

      if (secondAnimation[0] == 0 && secondAnimation[1] == 0) {
        secondAnimation = [18, 0];
      } else if (secondAnimation[0] == 18 && secondAnimation[1] == 0) {
        secondAnimation = [18, 6];
      } else if (secondAnimation[0] == 18 && secondAnimation[1] == 6) {
        secondAnimation = [0, 6];
      } else if (secondAnimation[0] == 0 && secondAnimation[1] == 6) {
        secondAnimation = [0, 0];
      }
    });
  }

  void _resetDigitPosition() {
    setState(() {
      digitAnimationBackwards = 3;
      digitAnimationForwards = 3;
    });
  }

  void _pushDigitPosition() {
    setState(() {
      digitAnimationBackwards = 5;
      digitAnimationForwards = 1;
      _resetPositionTimer = Timer(Duration(seconds: 1), _resetDigitPosition);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);

    final firstHourDigit = int.parse(hour.substring(0, 1));
    final secondHourDigit = int.parse(hour.substring(1, 2));
    final firstMinuteDigit = int.parse(minute.substring(0, 1));
    final secondMinuteDigit = int.parse(minute.substring(1, 2));

    final backgroundCubeImage = DecorationImage(
      image: AssetImage('graphics/FlutterRay2.png'),
      fit: BoxFit.cover,
    );

    //Isometric Grid Properties
    final double offsetX = -0.778;
    final double offsetY = 0.337;
    final double magnitudeX = 0.1064;
    final double magnitudeY = -0.1520;
    final double gradientX = -0.0313;
    final double gradientY = -0.022;

    final OrthographicGrid grid = OrthographicGrid(
        offsetX, offsetY, magnitudeX, magnitudeY, gradientX, gradientY);

    imageManager.preCacheAllDigits(context);

    return Container(
      //color: colors[_Element.background],
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(image: backgroundCubeImage, border: null),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.amber,
              gradient: LinearGradient(
                  colors: [Colors.blue[900], Colors.blue[200]],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              backgroundBlendMode: BlendMode.overlay,
              border: null,
            ),
          ),
          Stack(
            children: <Widget>[
              CubeImage(
                imagePath: imageManager.getImagePath('cube'),
                coordinate: secondAnimation,
                grid: grid,
                curve: Curves.bounceOut,
              ),
              CubeImage(
                  imagePath: imageManager.getImagePath(firstHourDigit),
                  coordinate: [1, this.digitAnimationForwards],
                  grid: grid),
              CubeImage(
                  imagePath: imageManager.getImagePath(secondHourDigit),
                  coordinate: [5, this.digitAnimationBackwards],
                  grid: grid),
              CubeImage(
                  imagePath: imageManager.getImagePath('colon'),
                  coordinate: [9, 3],
                  grid: grid),
              CubeImage(
                  imagePath: imageManager.getImagePath(firstMinuteDigit),
                  coordinate: [11, this.digitAnimationForwards],
                  grid: grid),
              CubeImage(
                  imagePath: imageManager.getImagePath(secondMinuteDigit),
                  coordinate: [15, this.digitAnimationBackwards],
                  grid: grid),
            ],
          )
        ],
      ),
    );
  }
}
