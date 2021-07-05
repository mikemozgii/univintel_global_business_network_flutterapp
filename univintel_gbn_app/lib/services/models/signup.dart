
class Signup {
  final String email;
  final String timeZone;
  Signup({this.email, this.timeZone});

  factory Signup.fromJson(Map<String, dynamic> json) {
    return Signup(
      email: json['email'],
      timeZone: json['timeZone']
    );
  }

  Map<String, dynamic> toJson() =>
    {
      'email': email,
      'timeZone': timeZone
    };

}