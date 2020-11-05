class UserModel {
  final String email;
  final String password;
  String uid;

  UserModel({
    this.uid,
    this.email,
    this.password,
  });

  set setUid(value) => uid = value;

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'password': password,
      };
}
