import 'package:cloud_firestore/cloud_firestore.dart';
//Devloped by dhruv
class DatabaseService{

  final String uid;
  DatabaseService({this.uid});
  final CollectionReference dataCollection = Firestore.instance.collection('data');
  Future updateUserData(String email1, String name1, String address1, String phone1) async {
    return await dataCollection.document(uid).setData({
      'Email':email1,
      'Name':name1,
      'Address':address1,
      'Phone':phone1,
      'uid':uid,
    });
  }
}
