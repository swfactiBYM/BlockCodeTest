import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_test/code_model/code_control.dart';
import 'package:ui_test/flame/the_game.dart';

class GameController extends GetxController {
  final TheGame game;
  final codeController = Get.find<CodeController>();

  RxBool isGameFinished = false.obs;
  RxBool isGameRunning = false.obs;
  RxBool isCleared = false.obs;

  GameController(this.game);

  bool get isError => game.player.isInWall || game.player.isOutOfBounds;

  void startGame() async {
    isGameRunning.value = true;
    setBackgroundColor();
    await codeController.runCode();
    isCleared.value = game.map.checkSuccess(
        // mapState: [
        //   "1111111",
        //   "1000001",
        //   "1000001",
        //   "1000001",
        //   "1000001",
        //   "1000001",
        //   "1111111",
        // ],
        // inventoryCount: 3,
        );
    print(isCleared.value);
    isGameFinished.value = true;
    isGameRunning.value = false;
    setBackgroundColor();
  }

  void resetGame() {
    isGameFinished.value = false;
    isCleared.value = false;
    game.resetgame();
    setBackgroundColor();
  }

  void setBackgroundColor() {
    if (isGameFinished.value) {
      if (isCleared.value) {
        game.setColor(Colors.green);
      } else {
        game.setColor(Colors.red);
      }
    } else if (!isGameRunning.value) {
      game.setColor(Colors.black);
    } else {
      game.setColor(Colors.yellow);
    }
  }
}
