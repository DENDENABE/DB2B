// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer.dart'; // Customerモデルへのパス

class FirestoreService { // ← クラス定義の開始

  // ↓↓↓★★★ この _customersCollection の定義が ★★★
  // ↓↓↓★★★ クラスの直下に、全てのメソッドの外側に ★★★
  // ↓↓↓★★★ 正しく記述されているか、再度確認してください。★★★
  final CollectionReference<Customer> _customersCollection =
  FirebaseFirestore.instance.collection('customers').withConverter<Customer>(
    fromFirestore: Customer.fromFirestore,
    toFirestore: (Customer customer, _) => customer.toFirestore(),
  );

  // --- 以下に各メソッドが定義されます ---

  Future<void> addCustomer(Customer customer) async {
    try {
      // _customersCollection を使用
      await _customersCollection.add(customer);
      print('顧客を追加しました: ${customer.name}');
    } catch (e) {
      print('顧客追加エラー: $e');
      rethrow;
    }
  }

  Stream<List<Customer>> getCustomers() {
    // _customersCollection を使用
    return _customersCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Future<void> updateCustomer(Customer customer) async {
    if (customer.id == null) {
      print('更新エラー: 顧客IDがありません');
      throw Exception('顧客IDがnullのため更新できません');
    }
    try {
      // _customersCollection を使用
      await _customersCollection.doc(customer.id).set(customer, SetOptions(merge: true));
      print('顧客情報を更新しました: ${customer.name}');
    } catch (e) {
      print('顧客更新エラー: $e');
      rethrow;
    }
  }

  // ↓↓↓ searchCustomersByName メソッドの定義 ↓↓↓
  Future<List<Customer>> searchCustomersByName(String nameQuery) async {
    if (nameQuery.isEmpty) {
      return [];
    }
    try {
      // ↓↓↓ ここで _customersCollection が参照されます ↓↓↓
      final querySnapshot = await _customersCollection // エラーが出ている箇所
          .where('name', isGreaterThanOrEqualTo: nameQuery)
          .where('name', isLessThanOrEqualTo: nameQuery + '\uf8ff')
          .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('顧客検索エラー (名前): $e');
      return [];
    }
  }
// 削除処理...

 Future<void> deleteCustomer(String customerId) async {
    try {
      await _customersCollection.doc(customerId).delete();
      print('顧客情報を削除しました: ID $customerId');
    } catch (e) {
      print('顧客削除エラー: $e');
      rethrow; // エラーを呼び出し元に伝える
    }
  }

} // ← クラス定義の終了