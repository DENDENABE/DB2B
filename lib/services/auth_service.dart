import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuthの機能をインポート

class AuthService {
  // FirebaseAuthのインスタンスをシングルトンまたはプライベート変数として保持
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // ユーザーの認証状態の変化を監視するStream
  // これを購読することで、ログイン/ログアウト状態の変化をリアルタイムに検知できる
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // 現在ログインしているユーザーを取得 (ログインしていなければ null)
  User? get currentUser => _firebaseAuth.currentUser;

  // メールアドレスとパスワードで新しいユーザーを作成 (サインアップ)
  Future<User?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      // Firebaseにユーザー作成をリクエスト
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(), // 前後の空白を除去
        password: password,
      );
      return userCredential.user; // 作成されたユーザー情報を返す
    } on FirebaseAuthException catch (e) {
      // Firebase Authentication 関連のエラー処理
      print('サインアップエラー (${e.code}): ${e.message}');
      // エラーコードに基づいて、より分かりやすいメッセージをスローする
      if (e.code == 'weak-password') {
        throw '指定されたパスワードは弱すぎます。';
      } else if (e.code == 'email-already-in-use') {
        throw 'このメールアドレスは既に使用されています。';
      } else if (e.code == 'invalid-email') {
        throw 'メールアドレスの形式が正しくありません。';
      } else {
        throw 'サインアップに失敗しました。もう一度お試しください。';
      }
    } catch (e) {
      // その他の予期せぬエラー
      print('サインアップ中の予期せぬエラー: $e');
      throw 'サインアップ中に予期せぬエラーが発生しました。';
    }
  }

  // メールアドレスとパスワードでサインイン (ログイン)
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Firebaseにサインインをリクエスト
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential.user; // ログインしたユーザー情報を返す
    } on FirebaseAuthException catch (e) {
      // Firebase Authentication 関連のエラー処理
      print('ログインエラー (${e.code}): ${e.message}');
      if (e.code == 'user-not-found') {
        throw '指定されたメールアドレスのユーザーは見つかりません。';
      } else if (e.code == 'wrong-password') {
        throw 'パスワードが間違っています。';
      } else if (e.code == 'invalid-email') {
        throw 'メールアドレスの形式が正しくありません。';
      } else if (e.code == 'user-disabled') {
        throw 'このユーザーアカウントは無効化されています。';
      } else if (e.code == 'too-many-requests') {
        throw '試行回数が多すぎます。しばらくしてから再度お試しください。';
      }
      else {
        throw 'ログインに失敗しました。もう一度お試しください。';
      }
    } catch (e) {
      // その他の予期せぬエラー
      print('ログイン中の予期せぬエラー: $e');
      throw 'ログイン中に予期せぬエラーが発生しました。';
    }
  }

  // サインアウト (ログアウト)
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      print('ログアウトしました。');
    } catch (e) {
      print('ログアウト中のエラー: $e');
      throw 'ログアウト中にエラーが発生しました。';
    }
  }

  // (オプション) パスワードリセットメールの送信
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      print('パスワードリセットメールを送信しました: $email');
    } on FirebaseAuthException catch (e) {
      print('パスワードリセットメール送信エラー (${e.code}): ${e.message}');
      if (e.code == 'user-not-found') {
        throw '指定されたメールアドレスのユーザーは見つかりません。';
      } else if (e.code == 'invalid-email') {
        throw 'メールアドレスの形式が正しくありません。';
      } else {
        throw 'パスワードリセットメールの送信に失敗しました。';
      }
    } catch (e) {
      print('パスワードリセットメール送信中の予期せぬエラー: $e');
      throw 'パスワードリセットメールの送信中に予期せぬエラーが発生しました。';
    }
  }
}