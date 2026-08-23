import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminRoleService {
  AdminRoleService({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  static const String adminRole = 'admin';
  static const String canDeleteProductsPermission = 'canDeleteProducts';

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  Future<bool> currentUserIsAdmin() async {
    final User? user = _firebaseAuth.currentUser;
    if (user == null) {
      return false;
    }

    final DocumentSnapshot<Map<String, dynamic>> userDocument = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();
    final Map<String, dynamic>? userData = userDocument.data();

    return userData?['role'] == adminRole;
  }

  Future<bool> currentUserCanDeleteProducts() async {
    final User? user = _firebaseAuth.currentUser;
    if (user == null) {
      return false;
    }

    final DocumentSnapshot<Map<String, dynamic>> userDocument = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();
    final Map<String, dynamic>? userData = userDocument.data();
    final Object? permissions = userData?['permissions'];
    if (permissions is Map<String, dynamic>) {
      return permissions[canDeleteProductsPermission] == true;
    }

    return false;
  }
}
