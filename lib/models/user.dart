class Candidate {
  final String name;
  final String imageUrl;
  final String position;
  final int userID;
  final String bio;
  final String company;
  final String email;
  final String gender;
  final String location;

  Candidate({
    required this.userID,
    required this.name,
    required this.imageUrl,
    this.position = '',
    this.bio = '',
    this.company = '',
    this.email = '',
    this.gender = '',
    this.location = '',
  });
}
