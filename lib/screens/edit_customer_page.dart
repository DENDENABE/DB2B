// lib/screens/edit_customer_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Timestampのため
import 'package:intl/intl.dart';                     // 日付フォーマットのため
import '../models/customer.dart';                    // Customerモデル
import '../services/firestore_service.dart';           // FirestoreService

class EditCustomerPage extends StatefulWidget {
  final Customer customer; // 編集対象の顧客データを受け取る

  EditCustomerPage({required this.customer});

  @override
  _EditCustomerPageState createState() => _EditCustomerPageState();
}

class _EditCustomerPageState extends State<EditCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  // 各入力フィールドのコントローラー
  late TextEditingController _nameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _companyNameController;
  late TextEditingController _zipCodeController;
  late TextEditingController _departmentPositionController;
  late TextEditingController _memoController;
  late TextEditingController _birthdayTextController;

  DateTime? _selectedBirthday;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 初期値をコントローラーに設定
    _nameController = TextEditingController(text: widget.customer.name);
    _phoneNumberController = TextEditingController(text: widget.customer.phoneNumber);
    _emailController = TextEditingController(text: widget.customer.email);
    _addressController = TextEditingController(text: widget.customer.address);
    _companyNameController = TextEditingController(text: widget.customer.companyName);
    _zipCodeController = TextEditingController(text: widget.customer.zipCode);
    _departmentPositionController = TextEditingController(text: widget.customer.departmentPosition);
    _memoController = TextEditingController(text: widget.customer.memo);

    if (widget.customer.birthday != null) {
      _selectedBirthday = widget.customer.birthday!.toDate();
      _birthdayTextController = TextEditingController(text: DateFormat('yyyy/MM/dd').format(_selectedBirthday!));
    } else {
      _birthdayTextController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _companyNameController.dispose();
    _zipCodeController.dispose();
    _departmentPositionController.dispose();
    _memoController.dispose();
    _birthdayTextController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: '誕生日を選択',
      cancelText: 'キャンセル',
      confirmText: '決定',
    );
    if (picked != null && picked != _selectedBirthday) {
      setState(() {
        _selectedBirthday = picked;
        _birthdayTextController.text = DateFormat('yyyy/MM/dd').format(picked);
      });
    }
  }

  Future<void> _updateCustomer() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // 更新するCustomerオブジェクトを作成
      // id と createdAt は元のデータを引き継ぐ
      final updatedCustomer = Customer(
        id: widget.customer.id, // ★ 編集なのでIDは必須
        name: _nameController.text,
        phoneNumber: _phoneNumberController.text.isEmpty ? null : _phoneNumberController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        address: _addressController.text.isEmpty ? null : _addressController.text,
        companyName: _companyNameController.text.isEmpty ? null : _companyNameController.text,
        zipCode: _zipCodeController.text.isEmpty ? null : _zipCodeController.text,
        departmentPosition: _departmentPositionController.text.isEmpty ? null : _departmentPositionController.text,
        birthday: _selectedBirthday != null ? Timestamp.fromDate(_selectedBirthday!) : null,
        memo: _memoController.text.isEmpty ? null : _memoController.text,
        createdAt: widget.customer.createdAt, // ★ 作成日時は変更しない
        // updatedAt は FirestoreService の toFirestore で FieldValue.serverTimestamp() が自動設定
      );

      try {
        await _firestoreService.updateCustomer(updatedCustomer);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('顧客情報を更新しました')),
        );
        if (mounted) {
          Navigator.pop(context, true); // 更新成功のフラグを返す (任意)
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('更新に失敗しました: $e')),
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
        title: Text('顧客情報を編集'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // 各TextFormField (AddCustomerPageと同様だが、controllerの初期値が設定されている)
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: '氏名 *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return '氏名は必須です';
                    return null;
                  },
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
                  validator: (value) {
                    if (value != null && value.isNotEmpty && !value.contains('@')) {
                      return '有効なメールアドレスを入力してください';
                    }
                    return null;
                  },
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
                TextFormField(
                  controller: _zipCodeController,
                  decoration: InputDecoration(labelText: '郵便番号'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _departmentPositionController,
                  decoration: InputDecoration(labelText: '部署・役職'),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _birthdayTextController,
                  decoration: InputDecoration(
                    labelText: '誕生日',
                    hintText: 'タップして選択',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectBirthday(context),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _memoController,
                  decoration: InputDecoration(labelText: 'メモ'),
                  maxLines: 3,
                ),
                SizedBox(height: 32.0),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _updateCustomer, // 保存処理を呼び出す
                  child: Text('更新する'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}