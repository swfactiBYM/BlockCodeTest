import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:ui_test/flame/background.dart';
import 'package:ui_test/flame/manager/map.dart';
import 'package:ui_test/flame/sprites/player.dart';

class TheGame extends FlameGame {
  MapManager map = MapManager();
  late PlayerSprite player;
  late RectangleComponent backdrop;

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

    add(Background(pos));

    player = PlayerSprite(
      superPos: pos.xy,
      initialPosition: map.initialPlayerPosition,
    );
    add(player);

    overlays.add('startButton');
    overlays.add('resetButton');
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

  void resetgame() {
    map.changeMap([
      "1111111",
      "1000301",
      "1200021",
      "1300031",
      "1000001",
      "1020301",
      "1111111",
    ]);
    player.reset();
  }

  void setColor(Color color) {
    backdrop.setColor(color);
  }
}
