import 'package:flutter/material.dart';

final buttonTheme = ButtonStyle(
  backgroundColor: const MaterialStatePropertyAll(Colors.white),
  padding: const MaterialStatePropertyAll(
      EdgeInsets.symmetric(vertical: 4, horizontal: 4)),
  side: const MaterialStatePropertyAll(
      BorderSide(color: Color(0xffC7C3C3), width: 1)),
  shape: MaterialStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))),
  minimumSize: const MaterialStatePropertyAll(Size.zero),
  textStyle: const MaterialStatePropertyAll(TextStyle(color: Colors.black)),
  overlayColor: const MaterialStatePropertyAll(Colors.black26),
);

const buttonTextTheme = TextStyle(
  color: Colors.black,
  fontWeight: FontWeight.normal,
  fontSize: 15,
  decoration: TextDecoration.none,
);

final textInputTheme = InputDecoration(
  isDense: true,
  contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(4),
    borderSide: const BorderSide(color: Color(0xffC7C3C3), width: 1),
  ),
  focusColor: Colors.black45,
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(4),
    borderSide: const BorderSide(color: Color(0xffC7C3C3), width: 1),
  ),
);
