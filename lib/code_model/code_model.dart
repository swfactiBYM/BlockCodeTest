import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:ui_test/code_model/code_control.dart';

final codeController = Get.find<CodeController>();

class CodeModel {
  String code;

  CodeModel(this.code);

  Widget getWidget() {
    return GestureDetector(
        onTap: () {
          codeController.select(this);
        },
        child: Container(
            color: codeController.selected == this ? Colors.grey : Colors.white,
            child: Text(code)));
  }

  String getCode() {
    return code;
  }
}

class IfCodeModel extends CodeModel {
  String? condition;
  List<CodeModel> action = [];
  bool selected = false;

  IfCodeModel() : super("if");

  final List<CodeModel> _ifCode = [];
  final List<CodeModel> _elseCode = [];

  void addIfCode(CodeModel code) => _ifCode.add(code);

  void removeIfCode(int indx) => _ifCode.removeAt(indx);

  void addElseCode(CodeModel code) => _elseCode.add(code);

  void removeElseCode(int indx) => _elseCode.removeAt(indx);

  @override
  Widget getWidget() {
    return GestureDetector(
      onTap: () {
        codeController.select(this);
      },
      child: Container(
        color: codeController.selected == this ? Colors.grey : Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('''if '''),
                ElevatedButton(
                    onPressed: () {
                      codeController.setMode(MODE.ifCondition);
                      codeController.select(this);
                    },
                    child: condition == null
                        ? const Text('condition')
                        : Text(condition!)),
                const Text(' {')
              ],
            ),
            ElevatedButton(
              onPressed: () {
                codeController.setMode(MODE.ifAction);
                codeController.select(this);
              },
              child: const Text('action'),
            ),
            const Text('}')
          ],
        ),
      ),
    );
  }

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
  void removeSubCode(int indx) => _subCode.removeAt(indx);

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
  FunctionCodeModel(this.name) : super(name);

  @override
  String getCode() {
    return "name();";
  }
}
