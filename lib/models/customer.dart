// lib/models/customer.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String? id;
  final String name;
  final String? phoneNumber;
  final String? email;
  final String? address;
  final String? companyName;
  final String? memo;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  // 新しいプロパティ
  final String? zipCode;          // 郵便番号
  final String? departmentPosition; // 部署・役職
  final Timestamp? birthday;       // 誕生日

  Customer({
    this.id,
    required this.name,
    this.phoneNumber,
    this.email,
    this.address,
    this.companyName,
    this.memo,
    this.createdAt,
    this.updatedAt,
    this.zipCode,              // コンストラクタに追加
    this.departmentPosition,   // コンストラクタに追加
    this.birthday,             // コンストラクタに追加
  });

  factory Customer.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
    final data = snapshot.data();
    return Customer(
      id: snapshot.id,
      name: data?['name'] ?? '',
      phoneNumber: data?['phoneNumber'],
      email: data?['email'],
      address: data?['address'],
      companyName: data?['companyName'],
      memo: data?['memo'],
      createdAt: data?['createdAt'] as Timestamp?,
      updatedAt: data?['updatedAt'] as Timestamp?,
      zipCode: data?['zipCode'],                     // fromFirestoreに追加
      departmentPosition: data?['departmentPosition'], // fromFirestoreに追加
      birthday: data?['birthday'] as Timestamp?,    // fromFirestoreに追加
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (companyName != null) 'companyName': companyName,
      if (memo != null) 'memo': memo,
      if (id == null) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (zipCode != null) 'zipCode': zipCode,                             // toFirestoreに追加
      if (departmentPosition != null) 'departmentPosition': departmentPosition, // toFirestoreに追加
      if (birthday != null) 'birthday': birthday,                         // toFirestoreに追加
    };
  }
}