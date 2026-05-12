// IMPORTANTE: Este arquivo deve conter as chaves do seu projeto Firebase.
// 
// Opção A (Recomendado): Execute 'flutterfire configure' no terminal.
// Opção B (Manual): No Console do Firebase > Configurações do Projeto, 
// copie as chaves e cole nos campos abaixo.
//
// NÃO compartilhe este arquivo se ele contiver chaves reais.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ============================================================
  // SUBSTITUA OS VALORES ABAIXO PELOS DO SEU PROJETO FIREBASE
  // Obtenha em: Firebase Console > Configurações do Projeto
  // ============================================================

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDkq5x-9l8XaSBpR61W1MbHDjekeBup_ms',
    appId: '1:563134790579:web:3fcf8e352f7c824049a9c6',
    messagingSenderId: '563134790579',
    projectId: 'trabalho1monitoreconomicos',
    authDomain: 'trabalho1monitoreconomicos.firebaseapp.com',
    storageBucket: 'trabalho1monitoreconomicos.firebasestorage.app',
    measurementId: 'G-ZRNFB6FBST',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBH02uKLQGPpsWdrs6_uQIuLgT3_-m-v0A',
    appId: '1:563134790579:android:a6201efee6bb2f2149a9c6',
    messagingSenderId: '563134790579',
    projectId: 'trabalho1monitoreconomicos',
    storageBucket: 'trabalho1monitoreconomicos.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAhgTSmdhmiG3SgRPsFjTSFA_pidwaYquM',
    appId: '1:563134790579:ios:67ad01cf24d52caf49a9c6',
    messagingSenderId: '563134790579',
    projectId: 'trabalho1monitoreconomicos',
    storageBucket: 'trabalho1monitoreconomicos.firebasestorage.app',
    iosBundleId: 'com.example.bcbApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAhgTSmdhmiG3SgRPsFjTSFA_pidwaYquM',
    appId: '1:563134790579:ios:67ad01cf24d52caf49a9c6',
    messagingSenderId: '563134790579',
    projectId: 'trabalho1monitoreconomicos',
    storageBucket: 'trabalho1monitoreconomicos.firebasestorage.app',
    iosBundleId: 'com.example.bcbApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDkq5x-9l8XaSBpR61W1MbHDjekeBup_ms',
    appId: '1:563134790579:web:ecef9174cafa745149a9c6',
    messagingSenderId: '563134790579',
    projectId: 'trabalho1monitoreconomicos',
    authDomain: 'trabalho1monitoreconomicos.firebaseapp.com',
    storageBucket: 'trabalho1monitoreconomicos.firebasestorage.app',
    measurementId: 'G-4EQ31RRV8X',
  );

}