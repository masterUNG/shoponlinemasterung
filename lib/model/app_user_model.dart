import 'package:cloud_firestore/cloud_firestore.dart';

class AppUserModel {
  const AppUserModel({
    required this.displayName,
    required this.base64Avatar,
    required this.uid,
    required this.phone,
    this.role = 'customer',
    this.permissions = const <String, bool>{},
    this.geopoint,
  });

  final String displayName;
  final String base64Avatar;
  final String uid;
  final String phone;
  final String role;
  final Map<String, bool> permissions;
  final GeoPoint? geopoint;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'displayname': displayName,
      'base64avatar': base64Avatar,
      'uid': uid,
      'phone': phone,
      'role': role,
      if (permissions.isNotEmpty) 'permissions': permissions,
      if (geopoint != null) 'geopoint': geopoint,
    };
  }

  factory AppUserModel.fromMap(Map<String, dynamic> map) {
    final Object? rawPermissions = map['permissions'];
    final Map<String, bool> permissions = rawPermissions is Map
        ? rawPermissions.map((key, value) {
            return MapEntry(key.toString(), value == true);
          })
        : const <String, bool>{};

    return AppUserModel(
      displayName: (map['displayname'] ?? '') as String,
      base64Avatar: (map['base64avatar'] ?? '') as String,
      uid: (map['uid'] ?? '') as String,
      phone: (map['phone'] ?? '') as String,
      role: (map['role'] ?? 'customer') as String,
      permissions: permissions,
      geopoint: map['geopoint'] is GeoPoint
          ? map['geopoint'] as GeoPoint
          : null,
    );
  }
}
