// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'digit_image.dart';

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

  CoordinateSequence secondCubeSequence = new CoordinateSequence([
    Coordinate(0, 0),
    Coordinate(18, 0),
    Coordinate(18, 6),
    Coordinate(0, 6)
  ]);

  //OrthographicGrid Properties
  static const double offsetX = -0.778;
  static const double offsetY = 0.337;
  static const double magnitudeX = 0.1064;
  static const double magnitudeY = -0.1520;
  static const double gradientX = -0.0313;
  static const double gradientY = -0.022;

  final OrthographicGrid grid = OrthographicGrid(
      offsetX, offsetY, magnitudeX, magnitudeY, gradientX, gradientY);

  final backgroundCubeImage = DecorationImage(
    image: AssetImage('graphics/GridBackground.webp'),
    fit: BoxFit.cover,
  );

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

      secondCubeSequence.next();
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

  // TODO: optimise build
  @override
  Widget build(BuildContext context) {
    ImageManager.preCacheAllDigits(context);
    final hour =
        DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);

    final firstHourDigit = int.parse(hour.substring(0, 1));
    final secondHourDigit = int.parse(hour.substring(1, 2));
    final firstMinuteDigit = int.parse(minute.substring(0, 1));
    final secondMinuteDigit = int.parse(minute.substring(1, 2));

    return Container(
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(image: backgroundCubeImage, border: null),
          ),
          Container(
            decoration: BoxDecoration(
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
                imagePath: ImageManager.getImagePath('cube'),
                gridCoordinate: secondCubeSequence.currentCoordinate(),
                grid: grid,
                curve: Curves.bounceOut,
              ),
              CubeImage(
                  imagePath: ImageManager.getImagePath(firstHourDigit),
                  gridCoordinate: Coordinate(1, this.digitAnimationForwards),
                  grid: grid),
              CubeImage(
                  imagePath: ImageManager.getImagePath(secondHourDigit),
                  gridCoordinate: Coordinate(5, this.digitAnimationBackwards),
                  grid: grid),
              CubeImage(
                  imagePath: ImageManager.getImagePath('colon'),
                  gridCoordinate: Coordinate(9, 3),
                  grid: grid),
              CubeImage(
                  imagePath: ImageManager.getImagePath(firstMinuteDigit),
                  gridCoordinate: Coordinate(11, this.digitAnimationForwards),
                  grid: grid),
              CubeImage(
                  imagePath: ImageManager.getImagePath(secondMinuteDigit),
                  gridCoordinate: Coordinate(15, this.digitAnimationBackwards),
                  grid: grid),
            ],
          )
        ],
      ),
    );
  }
}
