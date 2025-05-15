// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ★ FirebaseAuthをインポート
import 'firebase_options.dart';
import 'screens/customer_list_page.dart'; // ログイン後のメイン画面
import 'screens/login_page.dart';          // ログイン画面
import 'services/auth_service.dart';        // ★ AuthServiceをインポート

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

const Color creamColor = Color(0xFFF5F5DC); // ベージュに近いクリーム色 (Beige)

class MyApp extends StatelessWidget {
  // ★ AuthServiceのインスタンスをここで作成（またはProviderなどで共有）
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoTran顧客管理アプリ',
      theme: ThemeData(
        scaffoldBackgroundColor: creamColor,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.brown[500],
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.brown[600],
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.brown[800],
          // ★ SnackBarのテキスト色を白に変更 (背景が濃い茶色なので)
          contentTextStyle: TextStyle(color: Colors.white),
        ),
      ),
      // ★ homeプロパティをAuthWrapperに変更
      home: AuthWrapper(authService: _authService),
    );
  }
}

// ★ 認証状態に応じて画面を切り替えるラッパーウィジェット
class AuthWrapper extends StatelessWidget {
  final AuthService authService;

  AuthWrapper({required this.authService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authService.authStateChanges, // AuthServiceから認証状態のStreamを取得
      builder: (context, snapshot) {
        // 接続状態の確認
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold( // ローディング中もテーマが適用されるようにScaffoldでラップ
            backgroundColor: creamColor, // ローディング画面の背景色
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // エラー発生時の表示 (任意でより詳細なエラー表示も可能)
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: creamColor,
            body: Center(child: Text('エラーが発生しました: ${snapshot.error}')),
          );
        }

        // ユーザーデータ (Userオブジェクト) があればログイン済み
        if (snapshot.hasData && snapshot.data != null) {
          print('AuthWrapper: User is logged in - ${snapshot.data!.uid}');
          return CustomerListPage(); // 顧客一覧画面へ
        } else {
          // ユーザーデータがなければ未ログイン
          print('AuthWrapper: User is not logged in');
          return LoginPage(); // ログイン画面へ
        }
      },
    );
  }
}