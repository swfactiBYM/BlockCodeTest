import 'package:get/get.dart';
import 'package:ui_test/code_model/code_model.dart';

enum MODE { basic, ifCondition, ifAction }

class CodeController extends GetxController {
  RxList<CodeModel> codes = <CodeModel>[].obs;
  RxInt index = 0.obs;
  MODE mode = MODE.basic;

  CodeModel? selected;

  void add(CodeModel code) {
    codes.add(code);
  }

  void setMode(MODE mode) {
    this.mode = mode;
    update();
  }

  void select(CodeModel selected) {
    if (this.selected != selected) {
      this.selected = selected;
    } else if (this.selected == selected) {
      this.selected == CodeModel('basic');
    }
    update();
  }

  void remove() {
    if (selected != null) {
      codes.remove(selected);
    }
    update();
  }

  void setCondition(IfCodeModel ifCodeModel, String condition) {
    ifCodeModel.condition = condition;
    update();
  }

  void addAction(IfCodeModel ifCodeModel, CodeModel action) {
    ifCodeModel.action.add(action);
    update();
  }
}
