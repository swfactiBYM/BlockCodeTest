import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_test/code_model/code_control.dart';
import 'package:ui_test/code_model/code_model.dart';
import 'package:ui_test/code_widget/code_theme.dart';
import 'package:ui_test/code_widget/code_widget_builder.dart';

class IfCodeWidget extends StatelessWidget {
  final Rx<IfCodeModel> codeRx;

  IfCodeWidget({super.key, required this.codeRx});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: () => Get.find<CodeController>()
              .setSelectedCode(codeRx.value, extra: 0),
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
