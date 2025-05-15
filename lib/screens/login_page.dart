// lib/screens/login_page.dart
import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // ★ AuthService経由で使うので直接インポートは不要になる
import '../services/auth_service.dart'; // ★ AuthServiceをインポート
import 'signup_page.dart'; // サインアップページへの導線 (後で作成・インポート)

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService(); // ★ AuthServiceのインスタンスを取得

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage; // エラーメッセージ表示用

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null; // エラーメッセージをリセット
      });

      try {
        // ★ AuthServiceのsignInWithEmailAndPasswordメソッドを呼び出す
        final user = await _authService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );

        // ログイン成功時の処理
        // AuthWrapperが画面遷移をハンドルするため、ここでの明示的な画面遷移は不要
        if (user != null) {
          print('ログイン成功 (LoginPage): ${user.email}');
          // 必要であれば、ログイン成功を示す一時的なメッセージを表示しても良いが、
          // 通常はAuthWrapperによる画面遷移に任せる
          // if (mounted) {
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(content: Text('ログインしました！')),
          //   );
          // }
        } else {
          // AuthServiceがnullを返した場合 (通常はエラーをスローするが念のため)
          if (mounted) {
            setState(() { _errorMessage = 'ログインに失敗しました。'; });
          }
        }

      } catch (e) {
        // AuthServiceからスローされたエラーメッセージをキャッチして表示
        print('ログイン失敗 (LoginPage): ${e.toString()}');
        if (mounted) {
          setState(() {
            _errorMessage = e.toString(); // AuthServiceが整形したメッセージを表示
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ログイン'), // constを追加
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text( // constを追加
                  'ようこそ！',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30), // constを追加
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration( // constを追加
                    labelText: 'メールアドレス',
                    prefixIcon: Icon(Icons.email), // Iconはconst
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'メールアドレスを入力してください';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return '有効なメールアドレスを入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20), // constを追加
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration( // constを追加
                    labelText: 'パスワード',
                    prefixIcon: Icon(Icons.lock), // Iconはconst
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'パスワードを入力してください';
                    }
                    if (value.length < 6) {
                      return 'パスワードは6文字以上で入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10), // constを追加
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14), // TextStyleはconst
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 20), // constを追加
                _isLoading
                    ? const Center(child: CircularProgressIndicator()) // constを追加
                    : ElevatedButton(
                  onPressed: _loginUser,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15), // EdgeInsetsはconst
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // TextStyleはconst
                  ),
                  child: const Text('ログイン'), // Textはconst
                ),
                const SizedBox(height: 20), // constを追加
                TextButton(
                  onPressed: () {
                    // サインアップページへ遷移
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SignupPage()), // SignupPageをインポートしておく
                    );
                  },
                  child: const Text('アカウントをお持ちでないですか？ サインアップ'), // Textはconst
                ),
                TextButton(
                  onPressed: () {
                    // TODO: パスワードリセット機能の実装
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('パスワードリセット機能は未実装です')), // SnackBarとTextはconst
                    );
                  },
                  child: const Text('パスワードをお忘れですか？'), // Textはconst
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}