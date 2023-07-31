import 'package:get/get.dart';
import 'package:ui_test/code_model/code_model.dart';

class CodeController extends GetxController {
  RxList<CodeModel> mainCode = <CodeModel>[].obs;
  RxInt extra = 0.obs;

  Rxn<CodeModel> selectedCode = Rxn<CodeModel>();

  void addCode(CodeModel code) {
    if (extra.value == 0) {
      mainCode.add(code);
    } else {
      if (selectedCode.value is IfCodeModel) {
        switch (extra.value) {
          case 1:
            (selectedCode.value as IfCodeModel).addIfCode(code);
            break;
          case 2:
            (selectedCode.value as IfCodeModel).addElseCode(code);
        }
      }
    }
  }

  void setSelectedCode(CodeModel code, {int? extra}) {
    selectedCode.value = code;
    if (extra != null) {
      this.extra.value = extra;
    }
  }

  void clearSelectedCode() {
    selectedCode.value = null;
    extra.value = 0;
  }

  void removeRequest() {
    if (mainCode.contains(selectedCode.value)) {
      mainCode.remove(selectedCode.value);
    } else {}
  }
}
