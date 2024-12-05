class UserModel {
  final String? email;
  final int? id;
  final String? username;

  UserModel({
    this.email,
    this.id,
    this.username,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] as String?,
      id: json['id'] as int?,
      username: json['username'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'id': id,
      'username': username,
    };
  }
}
