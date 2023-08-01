import 'package:get/get.dart';
import 'package:ui_test/code_model/code_model.dart';
import 'package:ui_test/flame/game_controller.dart';

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
          case 2:
            (selectedCode.value as IfCodeModel).addIfCode(code);
            break;
          case 3:
            (selectedCode.value as IfCodeModel).addElseCode(code);
            break;
          default:
            break;
        }
      } else if (selectedCode.value is ForCodeModel) {
        if (extra.value == 2) {
          (selectedCode.value as ForCodeModel).addSubCode(code);
        }
      }
    }
    mainCode.refresh();
  }

  void setCondition(String condition) {
    if (selectedCode.value is IfCodeModel && extra.value == 1) {
      (selectedCode.value as IfCodeModel).condition = condition;
    }
    mainCode.refresh();
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
    } else {
      for (final subC in mainCode) {
        if (subC is IfCodeModel) {
          subC.removeSubCode(selectedCode.value);
        } else if (subC is ForCodeModel) {
          subC.removeSubCode(selectedCode.value);
        }
      }
    }
    mainCode.refresh();
  }

  Future<void> runCode() async {
    final gameController = Get.find<GameController>();
    for (final code in mainCode) {
      await code.callback!();
      if (gameController.isError) {
        break;
      }
    }
  }
}
