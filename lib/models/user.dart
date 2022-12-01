class UserModel {
  String? photoUrl;
  String? fcmToken;

  UserModel();

  UserModel.fromJson(Map<String, dynamic> json) {
    photoUrl = json['photoUrl'];
    fcmToken = json['fcmToken'];
  }

  Map<String, dynamic> toJson() {
    return {
      'photoUrl': photoUrl,
      'fcmToken': fcmToken,
    };
  }
}
