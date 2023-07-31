import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_test/code_model/code_control.dart';
import 'package:ui_test/code_widget/code_widget_builder.dart';

import 'code_model/code_model.dart';

class TheApp extends StatelessWidget {
  final codeController = Get.put(CodeController());

  TheApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(children: [
        Expanded(
          flex: 1,
          child: Column(
            children: [
              SizedBox(
                height: context.height / 2,
                child: Obx(() => ListView.builder(
                      itemCount: codeController.mainCode.length,
                      itemBuilder: (context, idx) {
                        CodeModel code = codeController.mainCode[idx];
                        return CodeWidgetBuilder.codeWidget(code);
                      },
                    )),
              ),
              DecoratedBox(
                  decoration: const BoxDecoration(color: Color(0xffF0F0F0)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Select a Code",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                              onPressed: () {
                                codeController.removeRequest();
                              },
                              icon: Icon(Icons.delete))
                        ]),
                  )),
              Flexible(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  children: [
                    ListTile(
                      title: Text('move'),
                      onTap: () {
                        codeController.addCode(CodeModel("move();"));
                      },
                    ),
                    ListTile(
                      title: Text("if"),
                      onTap: () {
                        codeController.addCode(IfCodeModel());
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        Container(
          width: context.width / 2,
          color: Colors.red,
        ),
      ]),
    );
  }
}
