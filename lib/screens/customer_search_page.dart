// lib/screens/customer_search_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Timestampのため
import 'package:intl/intl.dart'; // DateFormatのため
import '../models/customer.dart';
import '../services/firestore_service.dart';


class CustomerSearchPage extends StatefulWidget {
  @override
  _CustomerSearchPageState createState() => _CustomerSearchPageState();
}

class _CustomerSearchPageState extends State<CustomerSearchPage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Customer> _searchResults = [];
  bool _isLoading = false;
  String _searchStatus = '検索条件を入力してください';

  // TextEditingControllers for search fields
  final _nameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _memoController = TextEditingController();
  final _birthdayTextController = TextEditingController();
  DateTime? _selectedBirthday;

  @override
  void dispose() {
    _nameController.dispose();
    _companyNameController.dispose();
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

  Future<void> _performSearch() async {
    if (_nameController.text.isEmpty &&
        _companyNameController.text.isEmpty &&
        _memoController.text.isEmpty &&
        _selectedBirthday == null) {
      setState(() {
        _searchStatus = '検索条件を1つ以上入力してください';
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _searchStatus = '検索中...';
      _searchResults = [];
    });

    // まず名前で検索 (Firestoreクエリ)
    // ここでは簡略化のため、名前が入力されていれば名前でFirestore検索、
    // そうでなければ全件取得してクライアントフィルタリング (データ量が多いと非推奨)
    // または、他の主要キーでもFirestore検索できるようにFirestoreServiceを拡張する
    List<Customer> initialResults = [];
    if (_nameController.text.isNotEmpty) {
      initialResults = await _firestoreService.searchCustomersByName(_nameController.text);
    } else {
      // 名前が空の場合、他の条件で検索するにはFirestoreServiceの拡張が必要。
      // ここでは一旦、全顧客を取得してフィルタリングする例を示す（データ量が多い場合は非推奨）
      // final allCustomersSnapshot = await FirebaseFirestore.instance.collection('customers').get();
      // initialResults = allCustomersSnapshot.docs.map((doc) => Customer.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>, null)).toList();
      // より良いのは、FirestoreServiceに全件取得メソッドを作るか、他の主要キーでの検索メソッドを作ること
      // 今回は、名前が空なら他のクライアントフィルタのみとする
      final stream = _firestoreService.getCustomers(); // 全顧客取得
      initialResults = await stream.first; // Streamの最初の要素（現在の全顧客リスト）を取得
    }


    // クライアントサイドでの追加フィルタリング
    List<Customer> filteredResults = initialResults.where((customer) {
      bool matchesCompanyName = _companyNameController.text.isEmpty ||
          (customer.companyName?.toLowerCase().contains(_companyNameController.text.toLowerCase()) ?? false);

      bool matchesMemo = _memoController.text.isEmpty ||
          (customer.memo?.toLowerCase().contains(_memoController.text.toLowerCase()) ?? false);

      bool matchesBirthday = _selectedBirthday == null ||
          (customer.birthday != null &&
              customer.birthday!.toDate().year == _selectedBirthday!.year &&
              customer.birthday!.toDate().month == _selectedBirthday!.month &&
              customer.birthday!.toDate().day == _selectedBirthday!.day);

      return matchesCompanyName && matchesMemo && matchesBirthday;
    }).toList();


    setState(() {
      _searchResults = filteredResults;
      _isLoading = false;
      _searchStatus = _searchResults.isEmpty ? '検索結果が見つかりませんでした' : '検索結果: ${_searchResults.length}件';
    });
  }

  // Timestampをフォーマットするヘルパー関数
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return DateFormat('yyyy/MM/dd').format(timestamp.toDate());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('顧客検索'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // 検索フォーム
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: '名前', hintText: '名前を入力'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _companyNameController,
              decoration: InputDecoration(labelText: '会社名', hintText: '会社名を入力'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _memoController,
              decoration: InputDecoration(labelText: 'メモ', hintText: 'メモ内容を入力'),
            ),
            SizedBox(height: 8),
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
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _performSearch,
              child: _isLoading ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0,) : Text('検索'),
            ),
            SizedBox(height: 16),
            Text(_searchStatus), // 検索ステータス表示
            Expanded(
              child: _searchResults.isEmpty && !_isLoading
                  ? Center(child: Text(_searchStatus == '検索中...' ? '' : '結果なし')) // 検索実行前や結果なしの場合
                  : ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final customer = _searchResults[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      title: Text(customer.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (customer.companyName != null && customer.companyName!.isNotEmpty)
                            Text('会社: ${customer.companyName}'),
                          if (customer.memo != null && customer.memo!.isNotEmpty)
                            Text('メモ抜粋: ${customer.memo!.length > 20 ? customer.memo!.substring(0, 20) + "..." : customer.memo}', overflow: TextOverflow.ellipsis,),
                          if (customer.birthday != null)
                            Text('誕生日: ${_formatTimestamp(customer.birthday)}'),
                        ],
                      ),
                      // onTap: () { /* 詳細画面へ遷移など */ },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}