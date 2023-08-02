import 'package:get/get.dart';
import 'package:ui_test/code_model/code_model.dart';
import 'package:ui_test/flame/game_controller.dart';

class CodeController extends GetxController {
  /// 주 화면 내의 모든 코드
  ///
  /// 가장 root에 있는 코드들만 포함되며</br>
  /// [IfCodeModel] 이나 [ForCodeModel] 내의 코드들은 해당 리스트에 없음
  RxList<CodeModel> mainCode = <CodeModel>[].obs;

  /// 현재 선택 정보의 추가 정보
  ///
  /// [IfCodeModel]이 선택되었을 경우</br>
  /// - 1은 [IfCodeModel.check]을 설정
  /// - 2는 [IfCodeModel._ifCode]를 설정
  /// - 3은 [IfCodeModel._elseCode]를 설정
  /// </br>
  /// [ForCodeModel]이 선택되었을 경우</br>
  /// - 2는 [ForCodeModel._subCode]를 설정
  RxInt extra = 0.obs;

  /// 현재 선택된 코드
  Rxn<CodeModel> selectedCode = Rxn<CodeModel>();

  /// 새로운 코드 추가
  ///
  /// [extra] 값이 0일 경우에는 [mainCode]에 코드를 추가</br>
  /// 그 외에는 [selectedCode] 값과 [extra] 값에 따라 각 model에 코드를 추가
  void addCode(CodeModel code) {
    if (extra.value == 0) {
      mainCode.add(code);
    } else {
      if (selectedCode.value is IfCodeModel) {
        /// if문 일 때
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
        /// for문 일 때
        if (extra.value == 2) {
          (selectedCode.value as ForCodeModel).addSubCode(code);
        }
      }
    }
    mainCode.refresh();

    /// 추가뒤 Obx 업데이트를 위한 refresh함수
  }

  /// 조건문 설정
  void setCondition(String condition) {
    if (selectedCode.value is IfCodeModel && extra.value == 1) {
      (selectedCode.value as IfCodeModel).condition = condition;
    }
    mainCode.refresh();
  }

  /// 선택된 코드 설정
  void setSelectedCode(CodeModel code, {int? extra}) {
    selectedCode.value = code;
    if (extra != null) {
      this.extra.value = extra;
    }
  }

  /// 선택사항 제거
  void clearSelectedCode() {
    selectedCode.value = null;
    extra.value = 0;
  }

  /// 코드 삭제
  ///
  /// [mainCode]코드에 [selectedCode] 가 있을 경우에는 바로 삭제</br>
  /// 아닌 경우에는 모든 [HasSubCode]를 implement하는 코드들에서 [HasSubCode.removeSubCode]를 실행
  void removeRequest() {
    if (mainCode.contains(selectedCode.value)) {
      mainCode.remove(selectedCode.value);
    } else {
      for (final subC in mainCode) {
        if (subC is HasSubCode) {
          (subC as HasSubCode).removeSubCode(selectedCode.value);
        }
      }
    }
    mainCode.refresh();
  }

  /// 코드 실행
  ///
  /// [mainCode]내의 모든 코드의 [CodeModel.callback] 함수 실행
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
