import 'package:flutter/material.dart';
import 'package:jogo_da_velha/core/app.dart';
import 'package:jogo_da_velha/modules/di/injection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  injectDependencies();

  runApp(const MyApp());
}
