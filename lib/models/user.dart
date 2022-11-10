class UserModel {
  late String photoUrl;

  UserModel(this.photoUrl);

  UserModel.fromJson(Map<String, dynamic> json) {
    photoUrl = json['photoUrl'];
  }

  Map<String, dynamic> toJson() {
    return {
      'photoUrl': photoUrl,
    };
  }
}