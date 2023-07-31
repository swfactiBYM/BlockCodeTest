import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_test/code_model/code_control.dart';
import 'package:ui_test/code_model/code_model.dart';

class PlainCodeWidget extends StatelessWidget {
  final CodeModel code;

  const PlainCodeWidget({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(code.getCode()),
        Positioned.fill(
          child: GestureDetector(
            onTap: () =>
                Get.find<CodeController>().setSelectedCode(code, extra: 0),
          ),
        ),
      ],
    );
  }
}
