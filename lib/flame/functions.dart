import 'dart:ui' as ui;

import 'package:flutter/services.dart';

Future<ui.Image> loadImage(String path) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
  ui.FrameInfo fi = await codec.getNextFrame();
  return fi.image;
}
