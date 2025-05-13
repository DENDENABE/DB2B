// lib/screens/add_customer_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Timestampのために必要
import 'package:intl/intl.dart'; // 日付フォーマットのために追加 (誕生日表示用)
import '../models/customer.dart';
import '../services/firestore_service.dart';

class AddCustomerPage extends StatefulWidget {
  @override
  _AddCustomerPageState createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _memoController = TextEditingController();

  // 新しいコントローラー
  final _zipCodeController = TextEditingController();
  final _departmentPositionController = TextEditingController();

  // 誕生日用の状態変数
  DateTime? _selectedBirthday; // 選択された誕生日を保持
  final _birthdayTextController = TextEditingController(); // 誕生日をテキスト表示するためのコントローラ (任意)


  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _companyNameController.dispose();
    _memoController.dispose();
    _zipCodeController.dispose(); // 破棄に追加
    _departmentPositionController.dispose(); // 破棄に追加
    _birthdayTextController.dispose(); // 破棄に追加
    super.dispose();
  }

  // 誕生日ピッカーを表示するメソッド
  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime.now(), // 初期選択日 (前回選択した日 or 今日)
      firstDate: DateTime(1900), // 選択可能な最も古い日付
      lastDate: DateTime.now(),  // 選択可能な最も新しい日付 (今日まで)
      helpText: '誕生日を選択',
      cancelText: 'キャンセル',
      confirmText: '決定',
      // locale: const Locale('ja'), // 日本語化したい場合 (要 flutter_localizations)
    );
    if (picked != null && picked != _selectedBirthday) {
      setState(() {
        _selectedBirthday = picked;
        _birthdayTextController.text = DateFormat('yyyy/MM/dd').format(picked); // テキストフィールドに表示
      });
    }
  }


  Future<void> _saveCustomer() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final newCustomer = Customer(
        name: _nameController.text,
        phoneNumber: _phoneNumberController.text.isEmpty ? null : _phoneNumberController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        address: _addressController.text.isEmpty ? null : _addressController.text,
        companyName: _companyNameController.text.isEmpty ? null : _companyNameController.text,
        memo: _memoController.text.isEmpty ? null : _memoController.text,
        // 新しいデータを追加
        zipCode: _zipCodeController.text.isEmpty ? null : _zipCodeController.text,
        departmentPosition: _departmentPositionController.text.isEmpty ? null : _departmentPositionController.text,
        birthday: _selectedBirthday != null ? Timestamp.fromDate(_selectedBirthday!) : null, // DateTimeをTimestampに変換
      );

      try {
        await _firestoreService.addCustomer(newCustomer);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('顧客情報を保存しました')),
        );
        if (mounted) {
          Navigator.pop(context); // 保存成功時にtrueなどを返しても良い
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('保存に失敗しました: $e')),
          );
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
        title: Text('新しい顧客を追加登録'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // ... (既存のフィールド: 氏名、電話番号、メールアドレス、住所、会社名) ...
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: '氏名 *'),
                  validator: (value) { /* ... */ return null; },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(labelText: '電話番号'),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'メールアドレス'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) { /* ... */ return null; },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: '住所'),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _companyNameController,
                  decoration: InputDecoration(labelText: '会社名'),
                ),
                SizedBox(height: 16.0),


                // --- 新しい入力フィールド ---
                // 郵便番号
                TextFormField(
                  controller: _zipCodeController,
                  decoration: InputDecoration(labelText: '郵便番号'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16.0),

                // 部署・役職
                TextFormField(
                  controller: _departmentPositionController,
                  decoration: InputDecoration(labelText: '部署・役職'),
                ),
                SizedBox(height: 16.0),

                // 誕生日
                TextFormField(
                  controller: _birthdayTextController, // テキスト表示用
                  decoration: InputDecoration(
                    labelText: '誕生日',
                    hintText: 'タップして選択',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true, //直接編集させない
                  onTap: () {
                    _selectBirthday(context); // タップで日付ピッカー表示
                  },
                ),
                SizedBox(height: 16.0),
                // --- ここまで新しい入力フィールド ---

                TextFormField(
                  controller: _memoController,
                  decoration: InputDecoration(labelText: 'メモ'),
                  maxLines: 3,
                ),
                SizedBox(height: 32.0),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _saveCustomer,
                  child: Text(
                    '保存する',
                    style: const TextStyle( // ★ const を追加
                      fontWeight: FontWeight.bold,
                      // fontSize: 16, // fontSizeも固定値ならconstのまま
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}