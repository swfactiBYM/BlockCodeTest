import 'package:get/get.dart';
import 'package:ui_test/flame/game_controller.dart';

/// 코드 데이터 값 저장하는 모델

/// 일반 코드 모델
class CodeModel {
  final gameController = Get.find<GameController>();

  /// 코드
  String code;

  /// 호출되는 callback함수
  Future<void> Function()? callback;

  CodeModel(this.code, {this.callback});

  /// 코드
  String getCode() {
    return code;
  }
}

/// 내부에 다른 코드들을 가지고 있는 코드들(if, for, 등등...)을 위한 interface
/// 코드 삭제할 때 recursive하게 removeSubCode를 호출
class HasSubCode {
  void removeSubCode(CodeModel? code) {}
}

/// if Code
class IfCodeModel extends CodeModel implements HasSubCode {
  /// 조건문 String
  String? condition;

  IfCodeModel() : super("if");

  /// 조건문이 참일 경우 실행되는 코드들 list
  final List<CodeModel> _ifCode = [];

  /// 조건문이 거짓일 경우 실행되는 코드들 list
  final List<CodeModel> _elseCode = [];

  /// 조건을 확인할 때 호출되는 callback함수
  bool Function()? check;

  /// 실행시 호출 되는 callback함수
  ///
  /// 조건문이 참이면 [_ifCode]내의 모든 코드의 [callback] 호출
  /// 조건문이 거짓이면 [_elseCode] 내의 모든 코드의 [callback]호출
  @override
  Future<void> Function()? get callback => () async {
        if (check == null) return;
        if (check!()) {
          for (final subC in _ifCode) {
            if (gameController.isError ||
                gameController.isGameRunning.isFalse) {
              break;
            }
            await subC.callback!();
          }
        } else {
          for (final subC in _elseCode) {
            if (gameController.isError ||
                gameController.isGameRunning.isFalse) {
              break;
            }
            await subC.callback!();
          }
        }
      };

  /// 외부용 함수들
  List<CodeModel> get ifCode => _ifCode;
  void addIfCode(CodeModel code) => _ifCode.add(code);
  List<CodeModel> get elseCode => _elseCode;
  void addElseCode(CodeModel code) => _elseCode.add(code);

  /// 내부코드 삭제용 함수, [HasSubCode] 에서 inherit
  @override
  void removeSubCode(CodeModel? code) {
    if (code == null) return;
    if (ifCode.contains(code)) {
      ifCode.remove(code);
    } else if (elseCode.contains(code)) {
      elseCode.remove(code);
    } else {
      ifCode.whereType<HasSubCode>().forEach((e) => e.removeSubCode(code));
      elseCode.whereType<HasSubCode>().forEach((e) => e.removeSubCode(code));
    }
  }

  void setCondition(String cond) => condition = cond;

  @override
  String getCode() {
    final ifC = _ifCode.fold('', (prev, elem) => '\t$prev${elem.getCode()}\n');
    if (_elseCode.isEmpty) {
      return '''if ($condition){
$ifC
}''';
    }

    final elC =
        _elseCode.fold('', (prev, elem) => '$prev\t${elem.getCode()}\n');
    return '''if ($condition){
$ifC
} else {
$elC
}''';
  }
}

/// for Code
class ForCodeModel extends CodeModel implements HasSubCode {
  /// iteration 횟수
  int iterCount = 1;

  /// 실행시킬 코드 목록
  final List<CodeModel> _subCode = [];

  ForCodeModel(this.iterCount) : super("for");

  /// 외부용 함수
  List<CodeModel> get subCode => _subCode;
  void addSubCode(CodeModel code) => _subCode.add(code);

  /// 내부코드 삭제용 함수, [HasSubCode] 에서 inherit
  @override
  void removeSubCode(CodeModel? code) {
    if (code == null) return;
    if (subCode.contains(code)) {
      subCode.remove(code);
    } else {
      subCode.whereType<HasSubCode>().forEach((e) => e.removeSubCode(code));
    }
  }

  /// 실행시 호출되는 callback함수
  ///
  /// [iterCount]만큼 [_subCode] 내의 모든 코드의 [callback] 실행
  @override
  Future<void> Function()? get callback => () async {
        for (int i = 0; i < iterCount; i++) {
          for (final subC in subCode) {
            if (gameController.isError ||
                gameController.isGameRunning.isFalse) {
              break;
            }
            await subC.callback!();
          }
        }
      };

  @override
  String getCode() {
    final subC =
        _subCode.fold('', (prev, elem) => '$prev\t${elem.getCode()}\n');
    return '''for(int i = 0; i< $iterCount; i++){
$subC
}''';
  }
}

/// Function Code
class FunctionCodeModel extends CodeModel implements HasSubCode {
  /// 함수 이름
  String name;

  /// 함수 실행시 실행될 모든 코드 목록
  final List<CodeModel> _subCode = [];

  FunctionCodeModel(this.name) : super(name);

  /// 외부용 함수
  List<CodeModel> get subCode => _subCode;
  void addSubCode(CodeModel code) => _subCode.add(code);

  /// 내부코드 삭제용 함수, [HasSubCode] 에서 inherit
  @override
  void removeSubCode(CodeModel? code) {
    if (code == null) return;
    if (subCode.contains(code)) {
      subCode.remove(code);
    } else {
      subCode.whereType<HasSubCode>().forEach((e) => e.removeSubCode(code));
    }
  }

  /// 실행시 호출되는 callback함수
  ///
  /// [_subCode] 내의 모든 코드의 [callback]호출
  @override
  Future<void> Function()? get callback => () async {
        for (final subC in subCode) {
          if (gameController.isError || gameController.isGameRunning.isFalse) {
            break;
          }
          await subC.callback!();
        }
      };

  @override
  String getCode() {
    return "$name();";
  }

  String getDefCode() {
    final subC =
        _subCode.fold('', (prev, elem) => '$prev\t${elem.getCode()}\n');
    return '''void $name(){
$subC
}''';
  }
}
