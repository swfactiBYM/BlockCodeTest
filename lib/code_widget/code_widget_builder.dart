import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_test/code_model/code_model.dart';
import 'package:ui_test/code_widget/for_code_widget.dart';
import 'package:ui_test/code_widget/function_def_code_widget.dart';
import 'package:ui_test/code_widget/if_code_widget.dart';
import 'package:ui_test/code_widget/plain_code_widget.dart';
import 'package:ui_test/code_widget/while_code_widget.dart';

class CodeWidgetBuilder {
  static Widget codeWidget(CodeModel code) {
    if (code is IfCodeModel) {
      return IfCodeWidget(codeRx: code.obs);
    } else if (code is ForCodeModel) {
      return ForCodeWidget(codeRx: code.obs);
    } else if (code is FunctionCodeModel) {
      return FunctionDefWidget(codeRx: code.obs);
    } else if (code is WhileCodeModel) {
      return WhileCodeWidget(codeRx: code.obs);
    } else {
      return PlainCodeWidget(codeRx: code.obs);
    }
  }
}
