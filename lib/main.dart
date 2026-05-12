import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app_theme.dart';
import 'firebase_options.dart';
import 'screens/lista_indicadores_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BcbApp());
}

class BcbApp extends StatelessWidget {
  const BcbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Indicadores BCB',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const ListaIndicadoresScreen(),
    );
  }
}
