// AppUser model
class AppUser {
  final String uid;
  final String fullName;
  final String userType;
  final String profileImageUrl;
  final Map<String, dynamic> data;

  AppUser({
    required this.uid,
    required this.fullName,
    required this.userType,
    required this.profileImageUrl,
    required this.data,
  });

  factory AppUser.fromPatientMap(Map<dynamic, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      fullName: map['fullName'] ?? '',
      userType: 'Patient',
      profileImageUrl: map['profileImageUrl'] ?? '',
      data: Map<String, dynamic>.from(map),
    );
  }

  factory AppUser.fromDoctorMap(Map<dynamic, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      fullName: map['fullName'] ?? '',
      userType: 'Doctor',
      profileImageUrl: map['profileImageUrl'] ?? '',
      data: Map<String, dynamic>.from(map),
    );
  }
}
