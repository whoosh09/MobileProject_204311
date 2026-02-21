import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RiveNative.init(); // Must be here for version 0.14.x
  runApp(const QuackApp());
}