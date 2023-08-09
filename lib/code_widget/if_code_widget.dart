import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_test/code_model/code_control.dart';
import 'package:ui_test/code_model/code_model.dart';
import 'package:ui_test/code_widget/code_theme.dart';
import 'package:ui_test/code_widget/code_widget_builder.dart';

class IfCodeWidget extends StatelessWidget {
  final Rx<IfCodeModel> codeRx;

  final RxBool isTargeted = false.obs;

  IfCodeWidget({super.key, required this.codeRx});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: () => Get.find<CodeController>()
              .setSelectedCode(codeRx.value, extra: 0),
          child: LongPressDraggable<CodeModel>(
            data: codeRx.value,
            feedback: const Text("if", style: buttonTextTheme),
            childWhenDragging: Text("----"),
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("if ("),
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
                          for (final code in codeRx.value.ifCode)
                            CodeWidgetBuilder.codeWidget(code),
                          ifCodeButton(),
                        ],
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Text("}"),
                      if (codeRx.value.elseCode.isNotEmpty) Text(" else {"),
                    ],
                  ),
                  if (codeRx.value.elseCode.isNotEmpty) ...[
                    Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final code in codeRx.value.elseCode)
                              CodeWidgetBuilder.codeWidget(code),
                            elseCodeButton(),
                          ],
                        )
                      ],
                    ),
                    Text("}")
                  ]
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

  Widget ifCodeButton() {
    return ElevatedButton(
      onPressed: () {
        Get.find<CodeController>().setSelectedCode(codeRx.value, extra: 2);
      },
      style: buttonTheme,
      child: const Text(
        'action',
        style: buttonTextTheme,
      ),
    );
  }

  Widget elseCodeButton() {
    return ElevatedButton(
      onPressed: () {
        Get.find<CodeController>().setSelectedCode(codeRx.value, extra: 3);
      },
      style: buttonTheme,
      child: const Text(
        'action',
        style: buttonTextTheme,
      ),
    );
  }
}
