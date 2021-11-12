class Profile {
  String name;
  int age;
  String role;

  Profile(
      {required this.name,
      required this.age,
      required this.role,
      });

  Profile.fromJson(Map<String, dynamic>? json)
      : name = json!['name'],
        age = json['age'],
        role = json['role'];
}
