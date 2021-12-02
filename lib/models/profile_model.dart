class Profile {
  String name;
  int age;
  String role;
  int phoneNo;

  Profile(
      {required this.name,
      required this.age,
      required this.role,
      required this.phoneNo});

  Profile.fromJson(Map<String, dynamic>? json)
      : name = json!['name'],
        age = json['age'],
        phoneNo = json['phoneNo'],
        role = json['role'];
}
