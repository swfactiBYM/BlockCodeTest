import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_test/code_model/code_control.dart';
import 'package:ui_test/code_model/code_model.dart';
import 'package:ui_test/code_widget/code_theme.dart';
import 'package:ui_test/code_widget/code_widget_builder.dart';
import 'package:ui_test/flame/game_controller.dart';
import 'package:ui_test/flame/the_game.dart';

class CodePage extends StatefulWidget {
  const CodePage({Key? key}) : super(key: key);

  @override
  State<CodePage> createState() => _CodePageState();
}

class _CodePageState extends State<CodePage> with TickerProviderStateMixin {
  final codeController = Get.put(CodeController());
  final gameController = Get.put(GameController(TheGame()));
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_onTabChange);
  }

  void _onTabChange() {
    if (_tabController.indexIsChanging) {
      // 탭이 바뀔 때마다 원하는 함수 호출
      codeController.isOnFuncDef.value = !codeController.isOnFuncDef.value;
      codeController.clearSelectedCode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Row(
        children: [
          // 코딩 부분
          codeSection(),
          // 게임 화면 부분
          flameSection(screenSize),
        ],
      ),
    );
  }

  // 코딩 부분
  Widget codeSection() {
    return Expanded(
      child: Column(
        children: [
          Container(
            color: Colors.black,
            child: mainFunctionTabBar(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                codeContainer(codeController.mainCode),
                codeContainer(codeController.funcDefCode),
              ],
            ),
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
    );
  }

  // 탭바 부분
  Widget mainFunctionTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Main',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        Tab(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Function', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  // 선택한 코드들을 보여주는 컨테이너
  Widget codeContainer(codeController) {
    return Container(
      height: context.height / 2,
      padding: const EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 18,
      ),
      child: Obx(
        () => ListView.builder(
          itemCount: codeController.length,
          itemBuilder: (context, idx) {
            CodeModel code = codeController[idx];
            return CodeWidgetBuilder.codeWidget(code);
          },
        ),
      ),
    );
  }

  // 게임 화면 부분
  Widget flameSection(Size screenSize) {
    return Expanded(
      child: Column(
        children: [
          runResetHeader(screenSize),
          gameBuilder(),
        ],
      ),
    );
  }

  // 게임 실행, 리셋 버튼 헤더
  Widget runResetHeader(Size screenSize) {
    return Container(
      color: Colors.black,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              gameController.resetGame();
            },
            child: const Text(
              'Reset',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: screenSize.width * 0.06,
            height: screenSize.height * 0.04,
            child: ElevatedButton(
              onPressed: () {
                gameController.startGame();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_arrow,
                    size: 20,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Run',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 실제 게임이 구동되는 부분
  Widget gameBuilder() {
    return Expanded(
      child: NotificationListener<SizeChangedLayoutNotification>(
        onNotification: (notif) {
          gameController.game.calScale();
          return false;
        },
        child: SizeChangedLayoutNotifier(
          child: GameWidget.controlled(
            gameFactory: () => gameController.game,
          ),
        ),
      ),
    );
  }

  Widget normalFunctions() {
    return Column(
      children: [
        DecoratedBox(
            decoration: const BoxDecoration(color: Color(0xffF0F0F0)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        icon: const Icon(Icons.delete))
                  ]),
            )),
        Flexible(
          child: ListView(
            children: [
              ListTile(
                title: const Text('move()'),
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
              const Divider(),
              ListTile(
                title: const Text('pickUpClam()'),
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
              const Divider(),
              ListTile(
                title: const Text('putDownClam()'),
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
              const Divider(),
              ListTile(
                title: const Text('turnRight()'),
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
              const Divider(),
              ListTile(
                title: const Text('turnLeft()'),
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
              const Divider(),
              ListTile(
                title: const Text('destroyThorns()'),
                onTap: () {
                  codeController.addCode(CodeModel(
                    "destoryThorns();",
                    callback: () async {
                      gameController.game.player.destroyObstacle();
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                  ));
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('pushMushroom()'),
                onTap: () {
                  codeController.addCode(CodeModel(
                    "pushMushroom();",
                    callback: () async {
                      gameController.game.player.pushPushable();
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                  ));
                },
              ),
              const Divider(),
              ListTile(
                title: const Text('pullLever()'),
                onTap: () {
                  codeController.addCode(CodeModel(
                    "pullLever();",
                    callback: () async {
                      gameController.game.player.pullLever();
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                  ));
                },
              ),
              const Divider(),
              ListTile(
                title: const Text("if"),
                onTap: () {
                  codeController.addCode(IfCodeModel());
                },
              ),
              const Divider(),
              if (codeController.selectedCode.value is IfCodeModel &&
                  (codeController.selectedCode.value as IfCodeModel)
                      .elseCode
                      .isEmpty)
                Column(
                  children: [
                    ListTile(
                      title: const Text("else"),
                      onTap: () {
                        (codeController.selectedCode.value as IfCodeModel)
                            .addElseCode(PlaceHolderCodeModel());
                        codeController.mainCode.refresh();
                      },
                    ),
                    const Divider(),
                  ],
                ),
              ListTile(
                title: const Text("for"),
                onTap: () {
                  codeController.addCode(ForCodeModel(0));
                },
              ),
              const Divider(),
              ListTile(
                title: const Text("while"),
                onTap: () {
                  codeController.addCode(WhileCodeModel());
                },
              ),
              const Divider(),
              for (final code
                  in codeController.funcDefCode.whereType<FunctionCodeModel>())
                Column(
                  children: [
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
                    const Divider(),
                  ],
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
                            icon: const Icon(Icons.arrow_back)),
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
                        icon: const Icon(Icons.delete))
                  ]),
            )),
        Flexible(
          child: ListView(
            children: [
              ListTile(
                title: const Text('isOnClam()'),
                onTap: () {
                  (codeController.selectedCode.value as HasCheck).check =
                      () => gameController.game.player.isOnItem();
                  codeController.setCondition('isOnClam()');
                  codeController.clearSelectedCode();
                },
              ),
              const Divider(),
              ListTile(
                title: const Text("hasClam()"),
                onTap: () {
                  (codeController.selectedCode.value as HasCheck).check =
                      () => gameController.game.player.hasItem();
                  codeController.setCondition('hasClam()');
                  codeController.clearSelectedCode();
                },
              ),
              const Divider(),
              ListTile(
                title: const Text("isOnFlag()"),
                onTap: () {
                  (codeController.selectedCode.value as HasCheck).check =
                      () => gameController.game.player.isOnDestination();
                  codeController.setCondition('isOnDestination()');
                  codeController.clearSelectedCode();
                },
              ),
              const Divider(),
              ListTile(
                title: const Text("isNotOnFlag()"),
                onTap: () {
                  (codeController.selectedCode.value as HasCheck).check =
                      () => !gameController.game.player.isOnDestination();
                  codeController.setCondition('isNotOnFlag()');
                  codeController.clearSelectedCode();
                },
              ),
              const Divider(),
              ListTile(
                title: const Text("frontIsWall()"),
                onTap: () {
                  (codeController.selectedCode.value as HasCheck).check =
                      () => gameController.game.player.frontIsWall();
                  codeController.setCondition('frontIsWall()');
                  codeController.clearSelectedCode();
                },
              ),
              const Divider(),
              ListTile(
                title: const Text("frontIsNotWall()"),
                onTap: () {
                  (codeController.selectedCode.value as HasCheck).check =
                      () => !gameController.game.player.frontIsWall();
                  codeController.setCondition('frontIsNotWall()');
                  codeController.clearSelectedCode();
                },
              ),
              const Divider(),
              ListTile(
                title: const Text("frontIsThorns()"),
                onTap: () {
                  (codeController.selectedCode.value as HasCheck).check =
                      () => gameController.game.player.frontIsObstacle();
                  codeController.setCondition('frontIsThorns()');
                  codeController.clearSelectedCode();
                },
              ),
              const Divider(),
              ListTile(
                title: const Text("frontIsMushroom()"),
                onTap: () {
                  (codeController.selectedCode.value as HasCheck).check =
                      () => gameController.game.player.frontIsPushable();
                  codeController.setCondition('frontIsMushroom()');
                  codeController.clearSelectedCode();
                },
              ),
              const Divider(),
              ListTile(
                title: const Text("isOnLever()"),
                onTap: () {
                  (codeController.selectedCode.value as HasCheck).check =
                      () => gameController.game.player.isOnLever();
                  codeController.setCondition('isOnLever()');
                  codeController.clearSelectedCode();
                },
              ),
              const Divider(),
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
                      icon: const Icon(Icons.delete))
                ]),
          ),
        ),
        Flexible(
          child: ListView(
            children: [
              ListTile(
                title: const Text('Function'),
                onTap: () {
                  // print(eval('2+2'));
                  codeController.addCode(FunctionCodeModel(''));
                },
              ),
              const Divider(),
            ],
          ),
        )
      ],
    );
  }
}
