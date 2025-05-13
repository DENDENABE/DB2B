// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/customer_list_page.dart'; // または初期画面

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

// クリーム色の定義 (例)
// 色は #RRGGBB 形式の16進数や、名前付きの色定数、Color.fromRGBO などで指定できます。
// より正確なクリーム色を求める場合は、カラーコードで指定してください。
// 例: const Color creamColor = Color(0xFFFFFDD0); // 一般的なクリーム色
const Color creamColor = Color(0xFFF5F5DC); // ベージュに近いクリーム色 (Beige)
// const Color creamColor = Color(0xFFFAF0E6); // リネン色 (Linen)

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoTran顧客管理アプリ',
      theme: ThemeData(
        // scaffoldBackgroundColor: Colors.amber[50], // 薄い黄色 (クリーム色に近い)
        scaffoldBackgroundColor: creamColor, // ★ 全画面の基本的な背景色をクリーム色に設定

        // AppBarの色も調整する場合 (任意)
        // primarySwatch をクリーム色に近い色にすると、AppBarなどもそれに準じた色になりますが、
        // primarySwatch は MaterialColor である必要があるため、単色のクリーム色を直接指定するのは難しいです。
        // 個別に AppBarTheme で設定する方がコントロールしやすいです。
        // primarySwatch: Colors.orange, // 例えばオレンジ系をベースにするなど

        appBarTheme: AppBarTheme(
          backgroundColor: Colors.brown[500], // AppBarの背景色 (クリーム色と合う色を選択)
          foregroundColor: Colors.white,      // AppBarのテキストやアイコンの色
        ),

        // FloatingActionButtonの色 (任意)
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.brown[600], // FABの色
        ),

        // SnackBarのテーマ (前回設定したもの)
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.brown[800], // SnackBarの色 (クリーム色と合うように調整)
          contentTextStyle: TextStyle(color: Colors.grey),
        ),

        // Cardの背景色 (任意、デフォルトは白に近い)
        // cardTheme: CardTheme(
        //   color: Colors.white, // またはクリーム色より少し明るい/暗い色
        // ),

        // CanvasColor (ダイアログやドロワーなどの背景色に影響することがある)
        // canvasColor: creamColor, // scaffoldBackgroundColor と同じにするか、少し変えるか

        // useMaterial3: true, // Material 3 を使用している場合は、色の扱いが少し異なる場合があります
      ),
      home: CustomerListPage(), // または初期画面
    );
  }
}