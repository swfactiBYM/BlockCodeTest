import 'dart:async';

import 'package:flame/components.dart';
import 'package:ui_test/flame/the_game.dart';

import '../sprites/moveable.dart';

class MapManager extends Component with HasGameRef<TheGame> {
  /// Map objects
  ///
  /// - W wall
  /// - I item
  /// - 0 air
  /// - B breakable
  /// - P pushable
  /// - T transformable
  /// - L lever
  List<String> map = [
    "WWWWWWW",
    "W000B0W",
    "WI000IW",
    "WB000BW",
    "W0PTT0W",
    "W0ILB0W",
    "WWWWWWW",
  ];

  final List<MovableSprite> pushables = [];

  int get width => map[0].length;
  int get height => map.length;
  Vector2 get size => Vector2(width.toDouble(), height.toDouble());

  /// Initial player position
  Vector2 initialPlayerPosition = Vector2(1, 1);

  /// Objective position for clearing game
  Vector2 destination = Vector2(2, 1);

  /// Sprite scale
  int scaleFactor = 3;

  static const List<String> wallString = ['W', 'B', 'T'];

  @override
  FutureOr<void> onLoad() {}

  void loadData(Map<String, dynamic> data) {
    map.clear();
    map.addAll((data['map'] as List).map((str) => str.toString()));

    final dst = data['destination'] as Map;
    destination = Vector2(dst['x'], dst['y']);

    final ini = data['initialPosition'] as Map;
    initialPlayerPosition = Vector2(ini['x'], ini['y']);
    gameRef.player.initPosition = initialPlayerPosition.xy;
  }

  /// Change map
  void changeMap(List<String> newMap) {
    map.clear();
    map.addAll(newMap);
  }

  /// Set map element
  void setElement(Vector2 pos, String element) {
    final l = map[pos.y.round()].substring(0, pos.x.round());
    final r = map[pos.y.round()].substring(pos.x.round() + 1);
    map[pos.y.round()] = '$l$element$r';
  }

  String getElement(Vector2 pos) {
    return map[pos.y.round()][pos.x.round()];
  }

  /// Check if game is cleared
  bool checkSuccess({List<String>? mapState, int? inventoryCount}) {
    var mapSuccess = true;
    var invSuccess = true;
    final destSuccess = gameRef.player.isInDestination();

    if (mapState != null) {
      for (int i = 0; i < mapState.length; i++) {
        if (mapState[i] != map[i]) {
          mapSuccess = false;
          break;
        }
      }
    }
    if (inventoryCount != null) {
      invSuccess = gameRef.player.inventory == inventoryCount;
    }

    // print('$mapSuccess $invSuccess $destSuccess');
    return mapSuccess && invSuccess && destSuccess;
  }

  MovableSprite? getPushable(Vector2 pos) {
    final iter = pushables.where((element) => element.destPos == pos);
    return iter.isNotEmpty ? iter.first : null;
  }

  void resetPushable() {
    for (final push in pushables) {
      push.reset();
    }
  }

  void rescalePushable() {
    for (final push in pushables) {
      push.rescale();
    }
  }
}
