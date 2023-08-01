import 'package:flame/components.dart';
import 'package:ui_test/flame/the_game.dart';

class MapManager extends Component with HasGameRef<TheGame> {
  List<String> map = [
    "1111111",
    "1000001",
    "1200021",
    "1000001",
    "1000001",
    "1020001",
    "1111111"
  ];
  int get width => map[0].length;
  int get height => map.length;
  Vector2 get size => Vector2(width.toDouble(), height.toDouble());
  Vector2 initialPlayerPosition = Vector2(1, 1);
  Vector2 destination = Vector2(2, 1);

  static const int scaleFactor = 3;

  void changeMap(List<String> newMap) {
    map.clear();
    map.addAll(newMap);
  }

  void setElement(int x, int y, int element) {
    final l = map[y].substring(0, x);
    final r = map[y].substring(x + 1);
    map[y] = l + element.toString() + r;
  }
}
