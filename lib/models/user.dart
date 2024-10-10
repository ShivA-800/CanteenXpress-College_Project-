class UserModel {
  String? displayName;
  String? email;
  String? password;
  String? uuid;
  String? role;
  double? balance;
  String? phone;

  UserModel(
      {this.displayName,
      this.email,
      this.password,
      this.uuid,
      this.role,
      this.balance,
      this.phone});

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
        displayName: data['displayName'],
        email: data['email'],
        password: data['password'],
        uuid: data['uuid'],
        role: data['role'],
        balance: data['balance'],
        phone: data['phone']);
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'password': password,
      'uuid': uuid,
      'role': role,
      'balance': balance,
      'phone': phone,
    };
  }
}
