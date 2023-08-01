class CodeModel {
  String code;
  Future<void> Function()? callback;

  CodeModel(this.code, {this.callback});

  String getCode() {
    return code;
  }
}

class IfCodeModel extends CodeModel {
  String? condition;

  IfCodeModel() : super("if");

  final List<CodeModel> _ifCode = [];
  final List<CodeModel> _elseCode = [];

  bool Function()? check;

  @override
  Future<void> Function()? get callback => () async {
        if (check == null) return;
        if (check!()) {
          for (final subC in _ifCode) {
            await subC.callback!();
          }
        } else {
          for (final subC in _elseCode) {
            await subC.callback!();
          }
        }
      };

  List<CodeModel> get ifCode => _ifCode;
  void addIfCode(CodeModel code) => _ifCode.add(code);
  List<CodeModel> get elseCode => _elseCode;
  void addElseCode(CodeModel code) => _elseCode.add(code);

  void removeSubCode(CodeModel? code) {
    if (code == null) return;
    if (ifCode.contains(code)) {
      ifCode.remove(code);
    } else if (elseCode.contains(code)) {
      elseCode.remove(code);
    } else {
      for (final subC in ifCode) {
        if (subC is IfCodeModel) {
          subC.removeSubCode(code);
        } else if (subC is ForCodeModel) {
          subC.removeSubCode(code);
        }
      }
      for (final subC in elseCode) {
        if (subC is IfCodeModel) {
          subC.removeSubCode(code);
        } else if (subC is ForCodeModel) {
          subC.removeSubCode(code);
        }
      }
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

class ForCodeModel extends CodeModel {
  int iterCount = 1;
  final List<CodeModel> _subCode = [];

  ForCodeModel(this.iterCount) : super("for");

  List<CodeModel> get subCode => _subCode;
  void addSubCode(CodeModel code) => _subCode.add(code);
  void removeSubCode(CodeModel? code) {
    if (code == null) return;
    if (subCode.contains(code)) {
      subCode.remove(code);
    } else {
      for (final subC in subCode) {
        if (subC is IfCodeModel) {
          subC.removeSubCode(code);
        } else if (subC is ForCodeModel) {
          subC.removeSubCode(code);
        }
      }
    }
  }

  @override
  Future<void> Function()? get callback => () async {
        for (int i = 0; i < iterCount; i++) {
          for (final subC in subCode) {
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

class FunctionCodeModel extends CodeModel {
  String name;
  final List<CodeModel> _subCode = [];

  FunctionCodeModel(this.name) : super(name);

  void addSubCode(CodeModel code) => _subCode.add(code);
  void removeSubCodeI(int indx) => _subCode.removeAt(indx);
  void removeSubCode(CodeModel code) => _subCode.remove(code);

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
