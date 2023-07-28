class CodeModel {
  String code;

  CodeModel(this.code);

  String getCode() {
    return code;
  }
}

class IfCodeModel extends CodeModel {
  String condition;

  IfCodeModel(this.condition) : super("if");

  final List<CodeModel> _ifCode = [];
  final List<CodeModel> _elseCode = [];

  void addIfCode(CodeModel code) => _ifCode.add(code);
  void removeIfCodeI(int indx) => _ifCode.removeAt(indx);
  void removeIfCode(CodeModel code) => _ifCode.remove(code);

  void addElseCode(CodeModel code) => _elseCode.add(code);
  void removeElseCodeI(int indx) => _elseCode.removeAt(indx);
  void removeElseCode(CodeModel code) => _elseCode.remove(code);

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

  void addSubCode(CodeModel code) => _subCode.add(code);
  void removeSubCodeI(int indx) => _subCode.removeAt(indx);
  void removeSubCode(CodeModel code) => _subCode.remove(code);

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
