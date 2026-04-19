class AppUserModel {
  const AppUserModel({
    required this.displayName,
    required this.base64Avatar,
    required this.uid,
  });

  final String displayName;
  final String base64Avatar;
  final String uid;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'displayname': displayName,
      'base64avatar': base64Avatar,
      'uid': uid,
    };
  }

  factory AppUserModel.fromMap(Map<String, dynamic> map) {
    return AppUserModel(
      displayName: (map['displayname'] ?? '') as String,
      base64Avatar: (map['base64avatar'] ?? '') as String,
      uid: (map['uid'] ?? '') as String,
    );
  }
}
