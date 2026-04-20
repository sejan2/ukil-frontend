class UserModel {
  final String? id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? token;
  final bool isApproved; // 🔥 NEW

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.token,
    this.isApproved = false, // 🔥 NEW
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'user',
      token: json['token'],
      isApproved: json['isApproved'] ?? json['is_approved'] ?? false, // 🔥 NEW
    );
  }

  Map<String, dynamic> toJson() {
    return {"name": name, "email": email, "phone": phone, "role": role};
  }
}
