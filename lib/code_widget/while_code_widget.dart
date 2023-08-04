import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_test/code_model/code_control.dart';
import 'package:ui_test/code_model/code_model.dart';
import 'package:ui_test/code_widget/code_theme.dart';
import 'package:ui_test/code_widget/code_widget_builder.dart';

class WhileCodeWidget extends StatelessWidget {
  final Rx<WhileCodeModel> codeRx;

  const WhileCodeWidget({super.key, required this.codeRx});

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
                    Text("while ("),
                    codeRx.value.condition == null
                        ? conditionButton()
                        : Text(codeRx.value.condition!),
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
      ],
    );
  }

  Widget conditionButton() {
    return ElevatedButton(
      onPressed: () {
        Get.find<CodeController>().setSelectedCode(codeRx.value, extra: 1);
      },
      style: buttonTheme,
      child: const Text(
        'condition',
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
