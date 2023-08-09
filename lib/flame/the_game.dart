import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_test/flame/background.dart';
import 'package:ui_test/flame/game_controller.dart';
import 'package:ui_test/flame/manager/map.dart';
import 'package:ui_test/flame/sprites/player.dart';

class TheGame extends FlameGame {
  MapManager map = MapManager();
  late PlayerSprite player;
  late RectangleComponent backdrop;
  late Background background;

  @override
  Future<void> onLoad() async {
    // this.debugMode = true;

    final pos = Vector2(size.x / 2, size.y / 2);
    add(map);

    backdrop = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.black,
    );
    add(backdrop);

    background = Background(pos);
    add(background);

    player = PlayerSprite(
      superPos: pos.xy,
      initialPosition: map.initialPlayerPosition,
    );
    add(player);

    overlays.add('startButton');
    overlays.add('resetButton');

    calScale();
  }

  void startGame() {
    List<void Function()> lst = [
      player.move,
      player.turnRight,
      player.move,
      player.move,
      player.move,
      player.turnLeft,
      player.move,
      player.move,
      player.move,
      player.pickUpItem,
      player.turnLeft,
      player.move,
      player.turnLeft,
      player.move,
      player.move,
      player.putDownItem,
    ];

    Future.delayed(Duration.zero, () async {
      for (final func in lst) {
        func();
        await Future.delayed(const Duration(milliseconds: 500));
        if (player.isOutOfBounds || player.isInWall) {
          print("PLAYER HAS MADE A WRONG MOVE!!");
          break;
        }
      }
    });
  }

  void calScale() {
    // if(size.x  map.width * 20);
    // print('${size.x} ${map.width * 20}');
    // print('${size.x / (map.width * 20)}');

    rescale(min(max((size.x / (map.width * 20)).floor() - 1, 1), 3));
  }

  void rescale(int scale) {
    backdrop.size = size;
    map.scaleFactor = scale;
    player.rescale();
    background.rescale();
    map.rescalePushable();
  }

  void resetgame() {
    final gmContrl = Get.find<GameController>();
    // map.changeMap([
    //   "WWWWWWW",
    //   "W000B0W",
    //   "WI000IW",
    //   "WB000BW",
    //   "W0PTT0W",
    //   "W0ILB0W",
    //   "WWWWWWW",
    // ]);
    map.changeMap(
        (gmContrl.gameData['map'] as List).map((e) => e.toString()).toList());
    map.resetPushable();
    player.reset();
  }

  void setColor(Color color) {
    backdrop.setColor(color);
  }
}
