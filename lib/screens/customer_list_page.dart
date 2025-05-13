// lib/screens/customer_list_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';
import '../services/firestore_service.dart';
import 'add_customer_page.dart';
import 'edit_customer_page.dart';

class CustomerListPage extends StatefulWidget {
  @override
  _CustomerListPageState createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final FirestoreService _firestoreService = FirestoreService();

  final _searchNameController = TextEditingController();
  final _searchCompanyNameController = TextEditingController();
  final _searchMemoController = TextEditingController();
  final _searchBirthdayTextController = TextEditingController();
  DateTime? _searchSelectedBirthday;

  List<Customer> _allCustomers = [];
  List<Customer> _filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    _searchNameController.addListener(_filterCustomers);
    _searchCompanyNameController.addListener(_filterCustomers);
    _searchMemoController.addListener(_filterCustomers);
  }

  @override
  void dispose() {
    _searchNameController.removeListener(_filterCustomers);
    _searchNameController.dispose();
    _searchCompanyNameController.removeListener(_filterCustomers);
    _searchCompanyNameController.dispose();
    _searchMemoController.removeListener(_filterCustomers);
    _searchMemoController.dispose();
    _searchBirthdayTextController.dispose();
    super.dispose();
  }

  void _filterCustomers() {
    final nameQuery = _searchNameController.text.toLowerCase();
    final companyQuery = _searchCompanyNameController.text.toLowerCase();
    final memoQuery = _searchMemoController.text.toLowerCase();
    final currentAllCustomers = List<Customer>.from(_allCustomers);

    if (nameQuery.isEmpty && companyQuery.isEmpty && memoQuery.isEmpty && _searchSelectedBirthday == null) {
      setState(() {
        _filteredCustomers = currentAllCustomers;
      });
      return;
    }

    setState(() {
      _filteredCustomers = currentAllCustomers.where((customer) {
        final nameMatches = customer.name.toLowerCase().contains(nameQuery);
        final companyMatches = customer.companyName?.toLowerCase().contains(companyQuery) ?? companyQuery.isEmpty;
        final memoMatches = customer.memo?.toLowerCase().contains(memoQuery) ?? memoQuery.isEmpty;
        bool birthdayMatches = true;
        if (_searchSelectedBirthday != null && customer.birthday != null) {
          final customerBirthday = customer.birthday!.toDate();
          birthdayMatches = customerBirthday.year == _searchSelectedBirthday!.year &&
              customerBirthday.month == _searchSelectedBirthday!.month &&
              customerBirthday.day == _searchSelectedBirthday!.day;
        } else if (_searchSelectedBirthday != null && customer.birthday == null) {
          birthdayMatches = false;
        }
        bool match = true;
        if (nameQuery.isNotEmpty && !nameMatches) match = false;
        if (companyQuery.isNotEmpty && !companyMatches) match = false;
        if (memoQuery.isNotEmpty && !memoMatches) match = false;
        if (_searchSelectedBirthday != null && !birthdayMatches) match = false;
        return match;
      }).toList();
    });
  }

  Future<void> _selectSearchBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _searchSelectedBirthday ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _searchSelectedBirthday = picked;
        _searchBirthdayTextController.text = DateFormat('yyyy/MM/dd').format(picked);
        _filterCustomers();
      });
    }
  }

  void _clearSearchBirthday() {
    setState(() {
      _searchSelectedBirthday = null;
      _searchBirthdayTextController.clear();
      _filterCustomers();
    });
  }

  String _formatTimestamp(Timestamp? timestamp, [String format = 'yyyy/MM/dd HH:mm']) {
    if (timestamp == null) return '日時不明';
    return DateFormat(format).format(timestamp.toDate());
  }

  // --- ★ 削除確認ダイアログを表示するメソッドを追加 ★ ---
  Future<void> _showDeleteConfirmDialog(Customer customer) async {
    if (customer.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('エラー: 顧客IDが見つからないため削除できません。')),
      );
      return;
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('顧客の削除'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('${customer.name} を本当に削除しますか？'),
                const Text('この操作は元に戻せません。', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('削除', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // ダイアログを閉じる

                try {
                  await _firestoreService.deleteCustomer(customer.id!);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${customer.name} を削除しました')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('削除に失敗しました: $e')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
  // --- ★ ここまで削除確認ダイアログメソッド ★ ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/motranlogo.png', // ロゴパスを 'motranlogo.png' から 'motranlogo.png' に修正しました（もしこれが正しい場合）
          fit: BoxFit.contain,
          height: 46, // ロゴの高さを46に変更しました
        ),
        actions: [
          // IconButton(icon: Icon(Icons.search), onPressed: () {
          //   Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerSearchPage()));
          // }),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchNameController,
                  decoration: const InputDecoration(labelText: '名前検索', hintText: '名前でフィルタリング', prefixIcon: Icon(Icons.person_search)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _searchCompanyNameController,
                  decoration: const InputDecoration(labelText: '会社名検索', hintText: '会社名でフィルタリング', prefixIcon: Icon(Icons.business)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _searchMemoController,
                  decoration: const InputDecoration(labelText: 'メモ検索', hintText: 'メモ内容でフィルタリング', prefixIcon: Icon(Icons.note_alt_outlined)),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _searchBirthdayTextController,
                  decoration: InputDecoration(
                    labelText: '誕生日検索',
                    hintText: 'タップして選択',
                    prefixIcon: const Icon(Icons.cake),
                    suffixIcon: _searchSelectedBirthday != null
                        ? IconButton(icon: const Icon(Icons.clear), onPressed: _clearSearchBirthday, tooltip: '誕生日検索クリア',)
                        : null,
                  ),
                  readOnly: true,
                  onTap: () => _selectSearchBirthday(context),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<List<Customer>>(
              stream: _firestoreService.getCustomers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && _allCustomers.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('エラー: ${snapshot.error}'));
                }
                if (snapshot.hasData) {
                  _allCustomers = snapshot.data!;
                  if (_filteredCustomers.isEmpty && _allCustomers.isNotEmpty && _searchNameController.text.isEmpty && _searchCompanyNameController.text.isEmpty && _searchMemoController.text.isEmpty && _searchSelectedBirthday == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) _filterCustomers();
                    });
                  }
                }
                if (_filteredCustomers.isEmpty) {
                  if (_searchNameController.text.isNotEmpty || _searchCompanyNameController.text.isNotEmpty || _searchMemoController.text.isNotEmpty || _searchSelectedBirthday != null) {
                    return const Center(child: Text('検索条件に一致する顧客が見つかりません。'));
                  } else if (_allCustomers.isEmpty && !snapshot.hasData && snapshot.connectionState != ConnectionState.waiting) {
                    return const Center(child: Text('顧客データがありません。'));
                  } else {
                    return Container();
                  }
                }
                return ListView.builder(
                  itemCount: _filteredCustomers.length,
                  itemBuilder: (context, index) {
                    final customer = _filteredCustomers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?'),
                        ),
                        title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const SizedBox(height: 4.0),
                            if (customer.phoneNumber != null && customer.phoneNumber!.isNotEmpty)
                              Text('電話: ${customer.phoneNumber!}'),
                            if (customer.companyName != null && customer.companyName!.isNotEmpty)
                              Text('会社: ${customer.companyName!}'),
                            if (customer.departmentPosition != null && customer.departmentPosition!.isNotEmpty)
                              Text('部署/役職: ${customer.departmentPosition!}'),
                            if (customer.email != null && customer.email!.isNotEmpty)
                              Text('メール: ${customer.email!}'),
                            if (customer.birthday != null)
                              Text('誕生日: ${_formatTimestamp(customer.birthday, 'yyyy/MM/dd')}'),
                            Text('登録日: ${_formatTimestamp(customer.createdAt)}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => EditCustomerPage(customer: customer)),
                            );
                            if (result == true && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${customer.name} の情報が更新されました')),
                              );
                            }
                          },
                        ),
                        // --- ★ onLongPress コールバックを追加 ★ ---
                        onLongPress: () {
                          _showDeleteConfirmDialog(customer); // 長押しで削除確認ダイアログ表示
                        },
                        // --- ★ ここまで onLongPress ★ ---
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddCustomerPage()),
          );
          if (result == true && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('新しい顧客が追加されました！')),
            );
          }
        },
        child: const Icon(
          Icons.add,
          color: Colors.white, // ★ この行を追加してアイコンの色を白に設定
          // size: 30, // ★ 必要であればアイコンのサイズも調整
        ),
        tooltip: '新しい顧客を追加',
      ),
    );
  }
}