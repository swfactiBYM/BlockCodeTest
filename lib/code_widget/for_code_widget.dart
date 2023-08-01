import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ui_test/code_model/code_control.dart';
import 'package:ui_test/code_model/code_model.dart';
import 'package:ui_test/code_widget/code_widget_builder.dart';

import 'code_theme.dart';

class ForCodeWidget extends StatelessWidget {
  final Rx<ForCodeModel> codeRx;
  final TextEditingController editor = TextEditingController(text: '0');

  ForCodeWidget({super.key, required this.codeRx});

  @override
  Widget build(BuildContext context) {
    editor.text = codeRx.value.iterCount.toString();
    return Stack(
      children: [
        GestureDetector(
          onTap: () => Get.find<CodeController>()
              .setSelectedCode(codeRx.value, extra: 0),
          child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("for (int i = 0; i<"),
                      SizedBox(
                        width: 40,
                        child: TextField(
                          cursorColor: Color(0xff606060),
                          cursorHeight: 20,
                          cursorWidth: 1.1,
                          style: buttonTextTheme,
                          decoration: textInputTheme,
                          controller: editor,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (val) {
                            try {
                              codeRx.value.iterCount = int.parse(editor.text);
                            } catch (e) {
                              ;
                            }
                          },
                        ),
                      ),
                      Text("; i++) {")
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final code in codeRx.value.subCode)
                            CodeWidgetBuilder.codeWidget(code),
                          subCodeButton(),
                        ],
                      ),
                    ],
                  ),
                  Text("}"),
                ],
              )),
        )
      ],
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
