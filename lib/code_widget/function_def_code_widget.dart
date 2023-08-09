import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_test/code_model/code_control.dart';
import 'package:ui_test/code_model/code_model.dart';
import 'package:ui_test/code_widget/code_widget_builder.dart';

import 'code_theme.dart';

class FunctionDefWidget extends StatelessWidget {
  final Rx<FunctionCodeModel> codeRx;
  final TextEditingController editor = TextEditingController(text: 'function');
  final codeController = Get.find<CodeController>();

  final RxBool isTargeted = false.obs;

  FunctionDefWidget({super.key, required this.codeRx});

  @override
  Widget build(BuildContext context) {
    editor.text = codeRx.value.name;
    return Stack(
      children: [
        InkWell(
          onTap: () => Get.find<CodeController>()
              .setSelectedCode(codeRx.value, extra: 0),
          child: LongPressDraggable<CodeModel>(
            data: codeRx.value,
            feedback: Text('${codeRx.value.name}()', style: buttonTextTheme),
            childWhenDragging: Text("----"),
            child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("void "),
                        SizedBox(
                          width: 60,
                          child: TextField(
                            cursorColor: Color(0xff606060),
                            cursorHeight: 20,
                            cursorWidth: 1.1,
                            style: buttonTextTheme,
                            decoration: textInputTheme,
                            controller: editor,
                            onChanged: (val) {
                              try {
                                codeRx.value.name = editor.text;
                              } catch (e) {
                                ;
                              }
                            },
                          ),
                        ),
                        Text("() {")
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
                    Text('}'),
                  ],
                )),
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
              return model != codeRx.value && model is FunctionCodeModel;
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

  Widget subCodeButton() {
    return ElevatedButton(
      onPressed: () {
        Get.find<CodeController>().setSelectedCode(codeRx.value, extra: 2);
      },
      style: buttonTheme,
      child: Text(
        'code',
        style: buttonTextTheme,
      ),
    );
  }
}
