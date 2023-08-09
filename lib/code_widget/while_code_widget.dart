import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_test/code_model/code_control.dart';
import 'package:ui_test/code_model/code_model.dart';
import 'package:ui_test/code_widget/code_theme.dart';
import 'package:ui_test/code_widget/code_widget_builder.dart';

class WhileCodeWidget extends StatelessWidget {
  final Rx<WhileCodeModel> codeRx;
  final RxBool isTargeted = false.obs;

  WhileCodeWidget({super.key, required this.codeRx});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: () => Get.find<CodeController>()
              .setSelectedCode(codeRx.value, extra: 0),
          child: LongPressDraggable<CodeModel>(
            data: codeRx.value,
            feedback: const Text("while", style: buttonTextTheme),
            childWhenDragging: Text("----"),
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("while ("),
                      conditionButton(codeRx.value.condition),
                      Text(") {"),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final code in codeRx.value.subCode)
                            CodeWidgetBuilder.codeWidget(code),
                          subCodeButton(),
                        ],
                      )
                    ],
                  ),
                  Text("}"),
                ],
              ),
            ),
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

  Widget conditionButton([String? txt]) {
    return ElevatedButton(
      onPressed: () {
        Get.find<CodeController>().setSelectedCode(codeRx.value, extra: 1);
      },
      style: buttonTheme,
      child: Text(
        txt ?? 'condition',
        style: buttonTextTheme,
      ),
    );
  }

  Widget subCodeButton() {
    return ElevatedButton(
      child: Text(
        'action',
        style: buttonTextTheme,
      ),
      onPressed: () {
        Get.find<CodeController>().setSelectedCode(codeRx.value, extra: 2);
      },
      style: buttonTheme,
    );
  }
}
