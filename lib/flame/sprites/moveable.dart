import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:ui_test/flame/functions.dart';
import 'package:ui_test/flame/manager/map.dart';
import 'package:ui_test/flame/the_game.dart';

class MovableSprite extends SpriteComponent with HasGameRef<TheGame> {
  Vector2 initPosition;
  Vector2 relPos = Vector2.zero();
  Vector2 destPos = Vector2.zero();

  Vector2 superPos;

  late Vector2 pivotPos;

  MovableSprite({
    required this.superPos,
    Vector2? initialPos,
  }) : initPosition = initialPos ?? Vector2.zero();

  bool get isMovingIntoWall =>
      MapManager.wallString.contains(gameRef.map.getElement(destPos)) ||
      isPushable(destPos);

  bool get isInWall =>
      MapManager.wallString.contains(gameRef.map.getElement(relPos)) ||
      isPushable(relPos);

  bool get isOutOfBounds =>
      relPos.y <= -0.5 ||
      relPos.y >= gameRef.map.height - 0.5 ||
      relPos.x <= -0.5 ||
      relPos.x >= gameRef.map.width - 0.5;

  bool get isMoving => relPos.absoluteError(destPos) > 0.01;

  bool isPushable(Vector2 pos) {
    return gameRef.map.getPushable(pos) != null &&
        gameRef.map.getPushable(pos) != this;
  }

  @override
  FutureOr<void> onLoad() async {
    anchor = Anchor.center;
    pivotPos = (gameRef.map.size - Vector2.all(1)) *
        10 *
        gameRef.map.scaleFactor.toDouble();
    scale = Vector2.all(gameRef.map.scaleFactor.toDouble());
    reset();
    await _loadSprites();
  }

  void rescale() {
    superPos = Vector2(gameRef.size.x / 2, gameRef.size.y / 2);
    pivotPos = (gameRef.map.size - Vector2.all(1)) *
        10 *
        gameRef.map.scaleFactor.toDouble();
    scale = Vector2.all(gameRef.map.scaleFactor.toDouble());
  }

  @override
  void update(double dt) {
    if (relPos != destPos && !isOutOfBounds && !isInWall) {
      if (relPos.absoluteError(destPos) < 0.01) {
        relPos = destPos.xy;
      }

      if (relPos.x > destPos.x) {
        relPos.x -= 2 * dt;
      } else if (relPos.x < destPos.x) {
        relPos.x += 2 * dt;
      }

      if (relPos.y > destPos.y) {
        relPos.y -= 2 * dt;
      } else if (relPos.y < destPos.y) {
        relPos.y += 2 * dt;
      }
    }
    position = superPos -
        pivotPos +
        relPos * 20 * gameRef.map.scaleFactor.toDouble() +
        Vector2(0, -4.0 * gameRef.map.scaleFactor);

    super.update(dt);
  }

  void reset() {
    scale = Vector2.all(gameRef.map.scaleFactor.toDouble());
    relPos = initPosition.xy;
    destPos = initPosition.xy;
  }

  void push(Vector2 offset) {
    destPos = destPos + offset;
    if (isMovingIntoWall) {
      destPos = destPos - offset;
      throw ObjectErrorException('Push error');
    }
  }

  Future<void> _loadSprites() async {
    final spriteSheet = SpriteSheet(
      image: await loadImage('assets/images/background_atlas.png'),
      srcSize: Vector2(20, 20),
    );

    sprite = spriteSheet.getSprite(2, 4);
  }
}

class ObjectErrorException implements Exception {
  String cause;
  ObjectErrorException([this.cause = 'Object Error']);
}
