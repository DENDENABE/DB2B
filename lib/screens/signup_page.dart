import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // AuthServiceをインポート

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService(); // AuthServiceのインスタンス

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); // 確認用パスワードのコントローラー

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose(); // 確認用パスワードコントローラーも破棄
    super.dispose();
  }

  Future<void> _signupUser() async {
    if (_formKey.currentState!.validate()) {
      // パスワードと確認用パスワードが一致するかチェック
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _errorMessage = 'パスワードが一致しません。';
        });
        return; // 一致しない場合は処理を中断
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null; // エラーメッセージをリセット
      });

      try {
        final user = await _authService.createUserWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text,
        );

        // サインアップ成功時の処理
        // AuthWrapperが画面遷移をハンドルするため、ここでの明示的な画面遷移は不要なことが多い
        if (user != null && mounted) {
          print('サインアップ成功 (SignupPage): ${user.email}');
          // 通常はログイン画面に戻るか、AuthWrapperによって自動的にメイン画面に遷移する
          // もしサインアップ後すぐにログイン画面に戻したい場合は Navigator.pop(context) を使う
          // Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('アカウント登録が完了しました。メイン画面に遷移します。')),
          );
          // AuthWrapperが検知してCustomerListPageに遷移するのを待つ
        } else if (mounted) {
          // AuthServiceがnullを返した場合 (通常はエラーをスローするが念のため)
          setState(() { _errorMessage = 'サインアップに失敗しました。'; });
        }
      } catch (e) {
        // AuthServiceからスローされたエラーメッセージをキャッチして表示
        print('サインアップ失敗 (SignupPage): ${e.toString()}');
        if (mounted) {
          setState(() {
            _errorMessage = e.toString();
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
        title: const Text('サインアップ'),
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
                const Text(
                  '新しいアカウントを作成',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'メールアドレス',
                    prefixIcon: Icon(Icons.email),
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
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'パスワード (6文字以上)',
                    prefixIcon: Icon(Icons.lock),
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
                const SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'パスワードの確認',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'パスワードの確認を入力してください';
                    }
                    if (value != _passwordController.text) {
                      return 'パスワードが一致しません';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _signupUser,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('登録する'),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // ログイン画面に戻る
                  },
                  child: const Text('既にアカウントをお持ちですか？ ログイン'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}