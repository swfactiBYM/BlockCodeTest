import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_test/code_model/code_control.dart';
import 'package:ui_test/code_widget/code_theme.dart';
import 'package:ui_test/code_widget/code_widget_builder.dart';
import 'package:ui_test/flame/game_controller.dart';
import 'package:ui_test/flame/the_game.dart';

import 'code_model/code_model.dart';

class TheApp extends StatelessWidget {
  final codeController = Get.put(CodeController());
  final gameController = Get.put(GameController(TheGame()));

  TheApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(children: [
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Container(
                child: Row(
                  children: [
                    Flexible(
                        child: TextButton(
                      style: buttonTheme,
                      child: const Text(
                        'main',
                        style: buttonTextTheme,
                      ),
                      onPressed: () {
                        codeController.isOnFuncDef.value = false;
                      },
                    )),
                    Flexible(
                        child: TextButton(
                      style: buttonTheme,
                      child: const Text(
                        'func',
                        style: buttonTextTheme,
                      ),
                      onPressed: () {
                        codeController.isOnFuncDef.value = true;
                      },
                    )),
                  ],
                ),
              ),
              SizedBox(
                height: context.height / 2,
                child: Obx(() => ListView.builder(
                      itemCount: codeController.isOnFuncDef.isFalse
                          ? codeController.mainCode.length
                          : codeController.funcDefCode.length,
                      itemBuilder: (context, idx) {
                        CodeModel code = codeController.isOnFuncDef.isFalse
                            ? codeController.mainCode[idx]
                            : codeController.funcDefCode[idx];
                        return CodeWidgetBuilder.codeWidget(code);
                      },
                    )),
              ),
              Flexible(
                child: Obx(
                  () => codeController.extra.value != 1
                      ? codeController.isOnFuncDef.value &&
                              codeController.extra.value != 2
                          ? functionFunctions()
                          : normalFunctions()
                      : contitionFunctions(),
                ),
              )
            ],
          ),
        ),
        Expanded(
          child: GameWidget.controlled(
            gameFactory: () => gameController.game,
            overlayBuilderMap: <String, Widget Function(BuildContext, Game)>{
              'startButton': (context, game) => Positioned(
                    top: context.height * 0.75,
                    child: ElevatedButton(
                      onPressed: () {
                        gameController.startGame();
                      },
                      child: Text('START'),
                    ),
                  ),
              'resetButton': (context, game) => Positioned(
                    top: context.height * 0.8,
                    child: ElevatedButton(
                      onPressed: () {
                        gameController.resetGame();
                      },
                      child: Text('Reset'),
                    ),
                  ),
            },
          ),
        )
      ]),
    );
  }

  Widget normalFunctions() {
    return Column(
      children: [
        DecoratedBox(
            decoration: const BoxDecoration(color: Color(0xffF0F0F0)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Select a Code",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                        onPressed: () {
                          codeController.removeRequest();
                        },
                        icon: Icon(Icons.delete))
                  ]),
            )),
        Flexible(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            children: [
              ListTile(
                title: Text('move()'),
                onTap: () {
                  codeController.addCode(CodeModel(
                    "move();",
                    callback: () async {
                      gameController.game.player.move();
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                  ));
                },
              ),
              ListTile(
                title: Text('pickUpClam()'),
                onTap: () {
                  codeController.addCode(CodeModel(
                    "pickUpClam();",
                    callback: () async {
                      gameController.game.player.pickUpItem();
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                  ));
                },
              ),
              ListTile(
                title: Text('putDownClam()'),
                onTap: () {
                  codeController.addCode(CodeModel(
                    "putDownClam();",
                    callback: () async {
                      gameController.game.player.putDownItem();
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                  ));
                },
              ),
              ListTile(
                title: Text('turnRight()'),
                onTap: () {
                  codeController.addCode(CodeModel(
                    "turnRight();",
                    callback: () async {
                      gameController.game.player.turnRight();
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                  ));
                },
              ),
              ListTile(
                title: Text('turnLeft()'),
                onTap: () {
                  codeController.addCode(CodeModel(
                    "turnLeft();",
                    callback: () async {
                      gameController.game.player.turnLeft();
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                  ));
                },
              ),
              ListTile(
                title: Text("if"),
                onTap: () {
                  codeController.addCode(IfCodeModel());
                },
              ),
              ListTile(
                title: Text("for"),
                onTap: () {
                  codeController.addCode(ForCodeModel(0));
                },
              ),
              for (final code
                  in codeController.funcDefCode.whereType<FunctionCodeModel>())
                ListTile(
                  title: Text('${code.name}()'),
                  onTap: () {
                    codeController.addCode(
                      CodeModel(
                        '${code.name}();',
                        callback: () async {
                          await codeController.runFunction(code);
                        },
                      ),
                    );
                  },
                ),
            ],
          ),
        )
      ],
    );
  }

  Widget contitionFunctions() {
    return Column(
      children: [
        DecoratedBox(
            decoration: const BoxDecoration(color: Color(0xffF0F0F0)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              codeController.extra.value = 0;
                              codeController.clearSelectedCode();
                            },
                            icon: Icon(Icons.arrow_back)),
                        const Text(
                          "Select a Condition",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                        onPressed: () {
                          codeController.removeRequest();
                        },
                        icon: Icon(Icons.delete))
                  ]),
            )),
        Flexible(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            children: [
              ListTile(
                title: Text('isOnClam()'),
                onTap: () {
                  (codeController.selectedCode.value as IfCodeModel).check =
                      () => gameController.game.player.isOnItem();
                  codeController.setCondition('isOnClam()');
                  codeController.clearSelectedCode();
                },
              ),
              ListTile(
                title: Text("hasClam()"),
                onTap: () {
                  (codeController.selectedCode.value as IfCodeModel).check =
                      () => gameController.game.player.hasItem();
                  codeController.setCondition('hasClam()');
                  codeController.clearSelectedCode();
                },
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget functionFunctions() {
    return Column(
      children: [
        DecoratedBox(
            decoration: const BoxDecoration(color: Color(0xffF0F0F0)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Select a Code",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                        onPressed: () {
                          codeController.removeRequest();
                        },
                        icon: Icon(Icons.delete))
                  ]),
            )),
        Flexible(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            children: [
              ListTile(
                title: Text('Function'),
                onTap: () {
                  codeController.addCode(FunctionCodeModel(''));
                },
              )
            ],
          ),
        )
      ],
    );
  }
}
