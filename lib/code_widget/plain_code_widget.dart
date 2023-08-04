import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_test/code_model/code_control.dart';
import 'package:ui_test/code_model/code_model.dart';

class PlainCodeWidget extends StatelessWidget {
  final Rx<CodeModel> codeRx;

  const PlainCodeWidget({super.key, required this.codeRx});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(() => Text(codeRx.value.getCode())),
        Positioned.fill(
          child: InkWell(
            onTap: () => Get.find<CodeController>()
                .setSelectedCode(codeRx.value, extra: 0),
          ),
        ),
      ],
    );
  }
}
