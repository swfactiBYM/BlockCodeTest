import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_test/code_model/button_model.dart';
import 'package:ui_test/code_model/code_control.dart';

class CodePage extends StatelessWidget {
  final codeController = Get.put(CodeController());
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(16, 22, 30, 1),
          title: const Text(
            'Main',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: GetBuilder<CodeController>(builder: (controller) {
            return Row(
              children: [
                SizedBox(
                  width: screenSize.width * 0.5,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        codes(screenSize),
                        buttons(screenSize),
                      ]),
                ),
                Expanded(
                    child: Container(
                  color: Colors.black,
                ))
              ],
            );
          }),
        ));
  }

  Widget codes(Size screenSize) {
    return SizedBox(
      height: screenSize.height * 0.5,
      child: Obx(() => ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: codeController.codes.value.length,
            itemBuilder: (context, index) {
              return codeController.codes.value[index].getWidget();
            },
          )),
    );
  }

  Widget buttons(Size screenSize) {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: const Color.fromRGBO(240, 240, 240, 1),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            height: screenSize.height * 0.05,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    codeController.mode != MODE.basic
                        ? IconButton(
                            onPressed: () {
                              codeController.setMode(MODE.basic);
                            },
                            icon: const Icon(Icons.arrow_back))
                        : Container(),
                    const Text(
                      'Select a code',
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                    onPressed: () {
                      codeController.remove();
                    },
                    icon: const Icon(Icons.delete))
              ],
            ),
          ),
          ButtonModel()
        ],
      ),
    );
  }
}
