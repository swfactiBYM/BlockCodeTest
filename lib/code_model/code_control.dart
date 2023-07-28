import 'package:get/get.dart';
import 'package:ui_test/code_model/code_model.dart';

class CodeController extends GetxController {
  RxList<CodeModel> codes = <CodeModel>[].obs;
  RxInt index = 0.obs;
}
