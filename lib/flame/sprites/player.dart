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

Map<PlayerState?, Vector2> dirVec = {
  PlayerState.up: Vector2(0, -1),
  PlayerState.upMoving: Vector2(0, -1),
  PlayerState.down: Vector2(0, 1),
  PlayerState.downMoving: Vector2(0, 1),
  PlayerState.left: Vector2(-1, 0),
  PlayerState.leftMoving: Vector2(-1, 0),
  PlayerState.right: Vector2(1, 0),
  PlayerState.rightMoving: Vector2(1, 0),
  null: Vector2(0, 1),
};

class PlayerSprite extends SpriteAnimationGroupComponent<PlayerState>
    with HasGameRef<TheGame> {
  PlayerSprite({
    required this.superPos,
    Vector2? initialPosition,
  }) : initPosition = initialPosition ?? Vector2(0, 0);

  /// Normal Scale
  static final unflippedScale = Vector2.all(MapManager.scaleFactor.toDouble());

  /// Flipped Scale for [PlayeyrState.left] and [PlayerState.leftMoving]
  static final flippedScale = Vector2(
      -MapManager.scaleFactor.toDouble(), MapManager.scaleFactor.toDouble());

  /// Initial position of the player
  Vector2 initPosition;

  /// current index position of map
  Vector2 relPos = Vector2(0, 0);

  /// destination index position of map
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
    scale = unflippedScale;
    pivotPos = (gameRef.map.size - Vector2.all(1)) *
        10 *
        MapManager.scaleFactor.toDouble();
    reset();
    _loadSprites();
  }

  /// Check if player is moving
  bool get isMoving =>
      current == PlayerState.downMoving ||
      current == PlayerState.upMoving ||
      current == PlayerState.leftMoving ||
      current == PlayerState.rightMoving;

  bool get isMovingIntoWall =>
      gameRef.map.map[destPos.y.toInt()][destPos.x.toInt()] == '1';

  /// Check if player is inside of wall
  bool get isInWall =>
      gameRef.map.map[relPos.y.round()][relPos.x.round()] == '1';

  /// Check if player is outside of map
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

    /// switch state from stationary to moving
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

    /// switch state from moving to stationary
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

    /// move player
    if (relPos != destPos && !isOutOfBounds && !isInWall) {
      if ((relPos.x - destPos.x).abs() < 0.01) {
        relPos.x = destPos.x;
      } else if (relPos.x > destPos.x) {
        relPos.x -= 2 * dt;
      } else if (relPos.x < destPos.x) {
        relPos.x += 2 * dt;
      }

      if ((relPos.y - destPos.y).abs() < 0.01) {
        relPos.y = destPos.y;
      } else if (relPos.y > destPos.y) {
        relPos.y -= 2 * dt;
      } else if (relPos.y < destPos.y) {
        relPos.y += 2 * dt;
      }
    }

    /// calculate actual position of player
    position = superPos -
        pivotPos +
        relPos * 20 * MapManager.scaleFactor.toDouble() +
        Vector2(0, -4.0 * MapManager.scaleFactor);

    super.update(dt);
  }

  /// trigger movement
  ///
  /// sets [destPos] according to player direction
  void move() {
    destPos += dirVec[current]!;
  }

  /// turn player direction
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

  /// turn player direction
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

  /// Pick up item from map
  void pickUpItem() {
    if (!isOutOfBounds &&
        gameRef.map.map[relPos.y.round()][relPos.x.round()] == '2') {
      gameRef.map.setElement(relPos.x.round(), relPos.y.round(), 0);
      inventory++;
    }
  }

  /// Put down item on map
  void putDownItem() {
    if (inventory > 0 && !isOutOfBounds) {
      gameRef.map.setElement(relPos.x.round(), relPos.y.round(), 2);
      inventory--;
    }
  }

  /// Check if player has picked up item
  bool hasItem() => inventory > 0;

  /// Check if player is standing on item
  bool isOnItem() =>
      !isOutOfBounds &&
      gameRef.map.map[relPos.y.round()][relPos.x.round()] == '2';

  bool isInDestination() => destPos == gameRef.map.destination;

  bool frontIsWall() {
    final pos = destPos + dirVec[current]!;
    return gameRef.map.map[pos.y.toInt()][pos.x.toInt()] == '1';
  }

  void reset() {
    inventory = 0;
    current = PlayerState.down;
    relPos = initPosition.xy;
    destPos = initPosition.xy;
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
