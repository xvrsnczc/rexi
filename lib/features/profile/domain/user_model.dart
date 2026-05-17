class UserModel {
  const UserModel({
    required this.id,
    this.email,
    this.fullName,
  });

  final String id;
  final String? email;
  final String? fullName;
}
