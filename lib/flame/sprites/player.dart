import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:ui_test/flame/functions.dart';
import 'package:ui_test/flame/manager/map.dart';
import 'package:ui_test/flame/the_game.dart';

enum PlayerState {
  up,
  down,
  left,
  right,
  upMoving,
  downMoving,
  leftMoving,
  rightMoving
}

class PlayerSprite extends SpriteAnimationGroupComponent<PlayerState>
    with HasGameRef<TheGame> {
  PlayerSprite({
    required this.superPos,
    Vector2? initialPosition,
  }) : initPosition = initialPosition ?? Vector2(0, 0);

  static final unflippedScale = Vector2.all(MapManager.scaleFactor.toDouble());
  static final flippedScale = Vector2(
      -MapManager.scaleFactor.toDouble(), MapManager.scaleFactor.toDouble());

  Vector2 initPosition;

  /// index position of map
  Vector2 relPos = Vector2(0, 0);
  Vector2 destPos = Vector2(0, 0);

  /// position of background
  final Vector2 superPos;

  /// position of top left corner
  late final Vector2 pivotPos;

  /// items picked up
  int inventory = 0;

  @override
  FutureOr<void> onLoad() {
    current = PlayerState.down;
    anchor = Anchor.center;
    super.scale = unflippedScale;
    pivotPos = (gameRef.map.size - Vector2.all(1)) *
        10 *
        MapManager.scaleFactor.toDouble();
    reset();
    _loadSprites();
  }

  bool get isMoving =>
      current == PlayerState.downMoving ||
      current == PlayerState.upMoving ||
      current == PlayerState.leftMoving ||
      current == PlayerState.rightMoving;

  bool get isMovingIntoWall =>
      gameRef.map.map[destPos.y.toInt()][destPos.x.toInt()] == '1';
  bool get isInWall =>
      gameRef.map.map[relPos.y.round()][relPos.x.round()] == '1';

  bool get isOutOfBounds =>
      relPos.y <= -0.5 ||
      relPos.y >= gameRef.map.height - 0.5 ||
      relPos.x <= -0.5 ||
      relPos.x >= gameRef.map.width - 0.5;

  @override
  void update(double dt) {
    /// flip image when viewing left
    if (current == PlayerState.left || current == PlayerState.leftMoving) {
      if (scale == unflippedScale) {
        scale = flippedScale;
      }
    } else {
      if (scale == flippedScale) {
        scale = unflippedScale;
      }
    }

    if (destPos != relPos && !isMoving) {
      switch (current ?? PlayerState.down) {
        case PlayerState.down:
          current = PlayerState.downMoving;
          break;
        case PlayerState.up:
          current = PlayerState.upMoving;
          break;
        case PlayerState.left:
          current = PlayerState.leftMoving;
          break;
        case PlayerState.right:
          current = PlayerState.rightMoving;
          break;
        case PlayerState.downMoving:
        case PlayerState.upMoving:
        case PlayerState.leftMoving:
        case PlayerState.rightMoving:
          break;
      }
    }

    if ((isMoving && destPos == relPos) || isOutOfBounds || isInWall) {
      switch (current ?? PlayerState.down) {
        case PlayerState.downMoving:
          current = PlayerState.down;
          break;
        case PlayerState.upMoving:
          current = PlayerState.up;
          break;
        case PlayerState.leftMoving:
          current = PlayerState.left;
          break;
        case PlayerState.rightMoving:
          current = PlayerState.right;
          break;
        case PlayerState.down:
        case PlayerState.up:
        case PlayerState.left:
        case PlayerState.right:
          break;
      }
    }

    if (relPos != destPos && !isOutOfBounds && !isInWall) {
      if (relPos.x > destPos.x) {
        relPos.x -= 0.03125;
      } else if (relPos.x < destPos.x) {
        relPos.x += 0.03125;
      } else if ((relPos.x - destPos.x).abs() < 0.1) {
        relPos.x = destPos.x;
      }

      if (relPos.y > destPos.y) {
        relPos.y -= 0.03125;
      } else if (relPos.y < destPos.y) {
        relPos.y += 0.03125;
      } else if ((relPos.y - destPos.y).abs() < 0.1) {
        relPos.y = destPos.y;
      }
    }

    position = superPos -
        pivotPos +
        relPos * 20 * MapManager.scaleFactor.toDouble() +
        Vector2(0, -4.0 * MapManager.scaleFactor);

    super.update(dt);
  }

  void move() {
    switch (current ?? PlayerState.down) {
      case PlayerState.down:
      case PlayerState.downMoving:
        destPos += Vector2(0, 1);
        break;
      case PlayerState.up:
      case PlayerState.upMoving:
        destPos += Vector2(0, -1);
        break;
      case PlayerState.left:
      case PlayerState.leftMoving:
        destPos += Vector2(-1, 0);
        break;
      case PlayerState.right:
      case PlayerState.rightMoving:
        destPos += Vector2(1, 0);
        break;
    }
  }

  void turnRight() {
    switch (current ?? PlayerState.down) {
      case PlayerState.down:
      case PlayerState.downMoving:
        current = PlayerState.right;
        break;
      case PlayerState.up:
      case PlayerState.upMoving:
        current = PlayerState.left;
        break;
      case PlayerState.left:
      case PlayerState.leftMoving:
        current = PlayerState.down;
        break;
      case PlayerState.right:
      case PlayerState.rightMoving:
        current = PlayerState.up;
        break;
    }
  }

  void turnLeft() {
    switch (current ?? PlayerState.down) {
      case PlayerState.down:
      case PlayerState.downMoving:
        current = PlayerState.left;
        break;
      case PlayerState.up:
      case PlayerState.upMoving:
        current = PlayerState.right;
        break;
      case PlayerState.left:
      case PlayerState.leftMoving:
        current = PlayerState.up;
        break;
      case PlayerState.right:
      case PlayerState.rightMoving:
        current = PlayerState.down;
        break;
    }
  }

  void pickUpItem() {
    if (!isOutOfBounds &&
        gameRef.map.map[relPos.y.round()][relPos.x.round()] == '2') {
      gameRef.map.setElement(relPos.x.round(), relPos.y.round(), 0);
      inventory++;
    }
  }

  void putDownItem() {
    if (inventory > 0 && !isOutOfBounds) {
      gameRef.map.setElement(relPos.x.round(), relPos.y.round(), 2);
      inventory--;
    }
  }

  bool hasItem() => inventory > 0;

  bool isOnItem() =>
      !isOutOfBounds &&
      gameRef.map.map[relPos.y.round()][relPos.x.round()] == '2';

  bool isInDestination() => relPos == gameRef.map.destination;

  void reset() {
    inventory = 0;
    current = PlayerState.down;
    relPos = initPosition.xy;
    destPos = relPos.xy;
  }

  Future<void> _loadSprites() async {
    final spriteSheet = SpriteSheet(
      image: await loadImage('assets/images/player_atlas.png'),
      srcSize: Vector2(20, 20),
    );

    final up = spriteSheet.createAnimation(row: 1, stepTime: 1, to: 1);
    final down = spriteSheet.createAnimation(row: 0, stepTime: 1, to: 1);
    final side = spriteSheet.createAnimation(row: 2, stepTime: 1, to: 1);

    final upMoving =
        spriteSheet.createAnimation(row: 1, stepTime: 0.2, from: 1, to: 3);
    final downMoving =
        spriteSheet.createAnimation(row: 0, stepTime: 0.2, from: 1, to: 3);
    final sideMoving =
        spriteSheet.createAnimation(row: 2, stepTime: 0.2, from: 1, to: 3);

    animations = <PlayerState, SpriteAnimation>{
      PlayerState.up: up,
      PlayerState.down: down,
      PlayerState.left: side,
      PlayerState.right: side,
      PlayerState.upMoving: upMoving,
      PlayerState.downMoving: downMoving,
      PlayerState.leftMoving: sideMoving,
      PlayerState.rightMoving: sideMoving,
    };
  }
}
