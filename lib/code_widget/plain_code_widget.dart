import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_test/code_model/code_control.dart';
import 'package:ui_test/code_model/code_model.dart';

import 'code_theme.dart';

class PlainCodeWidget extends StatelessWidget {
  final Rx<CodeModel> codeRx;
  final RxBool isTargeted = false.obs;

  PlainCodeWidget({super.key, required this.codeRx});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: () => Get.find<CodeController>()
              .setSelectedCode(codeRx.value, extra: 0),
          child: LongPressDraggable<CodeModel>(
            data: codeRx.value,
            feedback: Text(codeRx.value.getCode(), style: buttonTextTheme),
            childWhenDragging: Text("----"),
            child: Obx(() => Text(codeRx.value.getCode())),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: DragTarget<CodeModel>(
            builder: (context, candidate, reject) {
              return Obx(() => Container(
                    color: isTargeted.value ? Colors.blue : Colors.transparent,
                    height: 10,
                  ));
            },
            onAccept: (model) {
              isTargeted.value = false;
              final codeController = Get.find<CodeController>();
              codeController.moveCode(codeRx.value, model);
            },
            onWillAccept: (model) {
              return model != codeRx.value && model is! FunctionCodeModel;
            },
            onMove: (detail) {
              if (detail.data != codeRx.value) {
                isTargeted.value = true;
              }
            },
            onLeave: (data) {
              isTargeted.value = false;
            },
          ),
        ),
      ],
    );
  }
}
