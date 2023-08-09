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

  /// 조상 코드
  ///
  /// [null]일 경우에는 [CodeController.mainCode] 또는 [CodeController.funcDefCode]에 존재
  CodeModel? parent;

  /// 코드
  String getCode() {
    return code;
  }
}

class PlaceHolderCodeModel extends CodeModel {
  PlaceHolderCodeModel() : super('');
  @override
  Future<void> Function()? get callback => () async {};
}

/// 내부에 다른 코드들을 가지고 있는 코드들(if, for, 등등...)을 위한 interface
/// 코드 삭제할 때 recursive하게 removeSubCode를 호출
class HasSubCode {
  void addSubCode(CodeModel code) {}
  void removeSubCode(CodeModel? code) {}
  void insertAt(CodeModel code, int index) {}
  List<CodeModel> get subCode => [];
}

/// 내부에 조건문을 가지고 있는 코드들(if, while) 을 위한 interface
class HasCheck {
  /// 조건문 String
  String? condition;

  /// 조건을 확인할 때 호출되는 callback함수
  bool Function()? check;

  void setCondition(String cond) => condition = cond;
}

/// if Code
class IfCodeModel extends CodeModel implements HasSubCode, HasCheck {
  /// 조건문 String
  @override
  String? condition;

  IfCodeModel() : super("if");

  /// 조건문이 참일 경우 실행되는 코드들 list
  final List<CodeModel> _ifCode = [];

  /// 조건문이 거짓일 경우 실행되는 코드들 list
  final List<CodeModel> _elseCode = [];

  /// 조건을 확인할 때 호출되는 callback함수
  @override
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

  /// 코드 추가
  void addIfCode(CodeModel code) {
    _ifCode.add(code);
    code.parent = this;
  }

  /// 특정 위치에 코드 삽입
  void insertIfCode(CodeModel code, int index) {
    _ifCode.insert(index, code);
    code.parent = this;
  }

  List<CodeModel> get elseCode => _elseCode;

  /// 코드 추가
  void addElseCode(CodeModel code) {
    _elseCode.add(code);
    code.parent = this;
  }

  /// 특정 위치에 코드 삽입
  void insertElseCode(CodeModel code, int index) {
    _elseCode.insert(index, code);
    code.parent = this;
  }

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

  @override
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

  /// if 에선 안씀
  @override
  void addSubCode(CodeModel code) => throw UnimplementedError();

  /// if 에선 안씀
  @override
  void insertAt(CodeModel code, int index) => throw UnimplementedError();

  /// if 에선 안씀
  @override
  List<CodeModel> get subCode => throw UnimplementedError();
}

/// for Code
class ForCodeModel extends CodeModel implements HasSubCode {
  /// iteration 횟수
  int iterCount = 1;

  /// 실행시킬 코드 목록
  final List<CodeModel> _subCode = [];

  ForCodeModel(this.iterCount) : super("for");

  /// 외부용 함수
  @override
  List<CodeModel> get subCode => _subCode;
  @override
  void addSubCode(CodeModel code) {
    _subCode.add(code);
    code.parent = this;
  }

  /// 특정 위치에 삽입
  @override
  void insertAt(CodeModel code, int index) {
    _subCode.insert(index, code);
    code.parent = this;
  }

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

/// for Code
class WhileCodeModel extends CodeModel implements HasSubCode, HasCheck {
  /// 조건문 String
  @override
  String? condition;

  /// 실행시킬 코드 목록
  final List<CodeModel> _subCode = [];

  WhileCodeModel() : super("while");

  /// 외부용 함수
  @override
  List<CodeModel> get subCode => _subCode;
  @override
  void addSubCode(CodeModel code) {
    _subCode.add(code);
    code.parent = this;
  }

  /// 특정 위치에 삽입
  @override
  void insertAt(CodeModel code, int index) {
    subCode.insert(index, code);
    code.parent = this;
  }

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

  /// 조건을 확인할 때 호출되는 callback함수
  @override
  bool Function()? check;

  /// 실행시 호출되는 callback함수
  ///
  /// [check]가 [true]일 동안 [_subCode] 내의 모든 코드의 [callback] 실행
  @override
  Future<void> Function()? get callback => () async {
        if (check == null) return;
        while (check!() &&
            !gameController.isError &&
            gameController.isGameRunning.isTrue) {
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
  void setCondition(String cond) => condition = cond;

  @override
  String getCode() {
    final subC =
        _subCode.fold('', (prev, elem) => '$prev\t${elem.getCode()}\n');
    return '''while($condition) {
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
  @override
  List<CodeModel> get subCode => _subCode;
  @override
  void addSubCode(CodeModel code) {
    _subCode.add(code);
    code.parent = this;
  }

  /// 특정 위치에 삽입
  @override
  void insertAt(CodeModel code, int index) {
    subCode.insert(index, code);
    code.parent = this;
  }

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
