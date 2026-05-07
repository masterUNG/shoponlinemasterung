import 'package:cloud_firestore/cloud_firestore.dart';

class AppUserModel {
  const AppUserModel({
    required this.displayName,
    required this.base64Avatar,
    required this.uid,
    this.role = 'customer',
    this.geopoint,
  });

  final String displayName;
  final String base64Avatar;
  final String uid;
  final String role;
  final GeoPoint? geopoint;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'displayname': displayName,
      'base64avatar': base64Avatar,
      'uid': uid,
      'role': role,
      if (geopoint != null) 'geopoint': geopoint,
    };
  }

  factory AppUserModel.fromMap(Map<String, dynamic> map) {
    return AppUserModel(
      displayName: (map['displayname'] ?? '') as String,
      base64Avatar: (map['base64avatar'] ?? '') as String,
      uid: (map['uid'] ?? '') as String,
      role: (map['role'] ?? 'customer') as String,
      geopoint: map['geopoint'] is GeoPoint
          ? map['geopoint'] as GeoPoint
          : null,
    );
  }
}
