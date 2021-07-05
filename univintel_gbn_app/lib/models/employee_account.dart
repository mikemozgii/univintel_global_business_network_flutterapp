class EmployeeAccount  {
  String id;
  String name;
  String email;
  String avatarId;

  EmployeeAccount() {
    id = null;
    name = "";
    email = "";
    avatarId = null;
  }

  EmployeeAccount.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      name = json['name'],
      avatarId = json['avatarId'],
      email = json['email'];

  toJson() {
    return {
      'id': id == null ? '00000000-0000-0000-0000-000000000000' : id,
      'name': name,
      'email': email,
      'avatarId': avatarId
    };
  }

}