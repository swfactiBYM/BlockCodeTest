import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:ui_test/flame/functions.dart';
import 'package:ui_test/flame/manager/map.dart';
import 'package:ui_test/flame/the_game.dart';

class Background extends CustomPainterComponent with HasGameRef<TheGame> {
  Background(Vector2 pos) : super(position: pos);

  @override
  Future<void> onLoad() async {
    final image = await loadImage('assets/images/background_atlas.png');
    final width = gameRef.map.map[0].length;
    final height = gameRef.map.map.length;
    size = Vector2(width * 20, height * 20);

    scale = Vector2.all(MapManager.scaleFactor.toDouble());
    anchor = Anchor.center;
    painter = BackgroundPainter(img: image, map: gameRef.map.map);
    var flag = await gameRef.loadSprite('background_atlas.png',
        srcSize: Vector2(20, 20), srcPosition: Vector2(0, 40));
    add(SpriteComponent(
        sprite: flag,
        position: gameRef.map.destination.xy * 20 + Vector2(0, -4)));
  }
}

class BackgroundPainter extends CustomPainter {
  List<String> map;
  ui.Image img;
  int seed;
  BackgroundPainter({required this.img, required this.map})
      : seed = Random().nextInt(100);

  @override
  void paint(Canvas canvas, Size size) {
    final width = map[0].length;
    final height = map.length;
    final r = Random(seed);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, width * 20.0, height * 20.0),
      Paint()..color = Colors.green,
    );

    /// draw ground
    for (int i = 0; i < width; i++) {
      for (int j = 0; j < height; j++) {
        canvas.drawImageRect(
          img,
          Rect.fromLTWH(r.nextInt(2) * 20, r.nextInt(2) * 20, 20, 20),
          Rect.fromLTWH(i * 20, j * 20, 20.0, 20.0),
          Paint()..isAntiAlias = true,
        );
      }
    }

    /// draw objects
    for (int i = 0; i < width; i++) {
      for (int j = 0; j < height; j++) {
        final ri = r.nextInt(2);
        final rj = r.nextInt(3);
        if (map[j][i] == '0') continue;
        if (map[j][i] == '2') {
          canvas.drawImageRect(
            img,
            const Rect.fromLTWH(20, 40, 20, 20),
            Rect.fromLTWH(i * 20.0, j * 20.0, 20.0, 20.0),
            Paint()..isAntiAlias = true,
          );
          continue;
        }

        canvas.drawImageRect(
          img,
          Rect.fromLTWH(ri * 20 + 40, rj * 20, 20, 20),
          Rect.fromLTWH(i * 20.0, (j * 20.0 - 4.0), 20.0, 20.0),
          Paint()..isAntiAlias = true,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
