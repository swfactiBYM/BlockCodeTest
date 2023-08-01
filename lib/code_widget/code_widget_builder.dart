import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_test/code_model/code_model.dart';
import 'package:ui_test/code_widget/if_code_widget.dart';
import 'package:ui_test/code_widget/plain_code_widget.dart';

class CodeWidgetBuilder {
  static Widget codeWidget(CodeModel code) {
    if (code is IfCodeModel) {
      return IfCodeWidget(codeRx: code.obs);
    } else if (code is ForCodeModel) {
      return SizedBox();
    } else {
      return PlainCodeWidget(code: code);
    }
  }
}