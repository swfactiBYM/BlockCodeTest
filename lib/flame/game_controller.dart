import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ui_test/code_model/code_control.dart';
import 'package:ui_test/flame/the_game.dart';

class GameController extends GetxController {
  final TheGame game;
  final codeController = Get.find<CodeController>();

  RxBool isGameFinished = false.obs;
  RxBool isGameRunning = false.obs;
  RxBool isCleared = false.obs;

  late Map<String, dynamic> gameData;

  GameController(this.game);

  @override
  void onInit() async {
    await loadJson();
    game.map.loadData(gameData);
    game.resetgame();
    game.calScale();
    super.onInit();
  }

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
      inventoryCount: gameData['objective']?['inventory'],
    );
    // print(isCleared.value);
    /// 강제 종료 여부 체크
    if (isGameRunning.isTrue) {
      isGameFinished.value = true;
      isGameRunning.value = false;
      setBackgroundColor();
    }
  }

  void resetGame() {
    /// 게임 중간 강제 리셋용
    isGameRunning.value = false;

    /// 정상 리셋 과정
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

  Future<void> loadJson() async {
    final str = await rootBundle.loadString('assets/json/map2.json');
    gameData = await jsonDecode(str);
  }
}
