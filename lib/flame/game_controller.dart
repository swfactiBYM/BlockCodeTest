import 'package:get/get.dart';
import 'package:ui_test/code_model/code_control.dart';
import 'package:ui_test/flame/the_game.dart';

class GameController extends GetxController {
  final TheGame game;
  final codeController = Get.find<CodeController>();

  RxBool isGameRunning = false.obs;
  RxBool isCleared = false.obs;

  GameController(this.game);

  bool get isError => game.player.isInWall || game.player.isOutOfBounds;

  void startGame() {
    codeController.runCode();
  }

  void resetGame() {
    game.resetgame();
  }
}
