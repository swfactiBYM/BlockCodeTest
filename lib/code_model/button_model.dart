import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:ui_test/code_model/code_control.dart';
import 'package:ui_test/code_model/code_model.dart';

class ButtonModel extends StatelessWidget {
  final codeController = Get.find<CodeController>();
  @override
  Widget build(BuildContext context) {
    switch (codeController.mode) {
      case MODE.basic:
        return basic();
      case MODE.ifAction:
        return ifAction();
      case MODE.ifCondition:
        return ifCondition();
    }
  }
}

Widget basic() {
  return Column(
    children: [
      ListTile(
        title: const Text('move'),
        onTap: () {
          codeController.add(CodeModel('move();'));
        },
      ),
      ListTile(
        title: const Text('if'),
        onTap: () {
          codeController.add(IfCodeModel());
        },
      )
    ],
  );
}

Widget ifAction() {
  return Column(
    children: [
      ListTile(
        title: const Text('move'),
        onTap: () {
          if (codeController.selected.runtimeType == IfCodeModel) {
            codeController.addAction(
                (codeController.selected as IfCodeModel), CodeModel('move();'));
          }
        },
      ),
    ],
  );
}

Widget ifCondition() {
  return Column(
    children: [
      ListTile(
        title: const Text('isCalm()'),
        onTap: () {
          if (codeController.selected.runtimeType == IfCodeModel) {
            codeController.setCondition(
                (codeController.selected as IfCodeModel), 'isCalm()');
          }
        },
      ),
      ListTile(
        title: const Text('hasCalm()'),
        onTap: () {
          if (codeController.selected.runtimeType == IfCodeModel) {
            codeController.setCondition(
                (codeController.selected as IfCodeModel), 'hasCalm()');
          }
        },
      )
    ],
  );
}
