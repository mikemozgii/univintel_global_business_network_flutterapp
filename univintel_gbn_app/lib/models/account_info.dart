class AcountInfo {
  String firstName;
  String lastName;
  String avatarId;
  String bio;
  String email;
  String rankId;
  DateTime rankDateEnd;

  AcountInfo(this.firstName, this.lastName, this.avatarId, this.bio);

  AcountInfo.fromJson(Map<String, dynamic> json)
    :firstName = json['firstName'], 
    lastName = json['lastName'],
    avatarId = json['avatarId'],
    rankId = json['rankId'],
    email = json['email'] != null ? json['email'] : "",
    rankDateEnd = json['rankDateEnd'] == null ? null : DateTime.parse(json['rankDateEnd']), 
    bio = json['bio'];

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'avatarId': avatarId,
    'bio': bio,
    'email': email
  };
}
