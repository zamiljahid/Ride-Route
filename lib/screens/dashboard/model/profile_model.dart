class ProfileModel {
  final int? id;
  final String? profilePicture;
  final String? firstName;
  final String? lastName;
  final String? contactNumber;
  final String? iqamaNumber;
  final String? nationality;
  final String? iqamaExpiryDate;
  final String? drivingLicenseExpiryDate;
  final String? currentLatitude;
  final String? currentLongitude;
  final UserModel? user; // Changed to UserModel

  ProfileModel({
    this.id,
    this.profilePicture,
    this.firstName,
    this.lastName,
    this.contactNumber,
    this.iqamaNumber,
    this.nationality,
    this.iqamaExpiryDate,
    this.drivingLicenseExpiryDate,
    this.currentLatitude,
    this.currentLongitude,
    this.user,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as int?,
      profilePicture: json['profile_picture'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      contactNumber: json['contact_number'] as String?,
      iqamaNumber: json['iqama_number'] as String?,
      nationality: json['nationality'] as String?,
      iqamaExpiryDate: json['iqama_expiry_date'] as String?,
      drivingLicenseExpiryDate: json['driving_license_expiry_date'] as String?,
      currentLatitude: json['current_latitude'] as String?,
      currentLongitude: json['current_longitude'] as String?,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_picture': profilePicture,
      'first_name': firstName,
      'last_name': lastName,
      'contact_number': contactNumber,
      'iqama_number': iqamaNumber,
      'nationality': nationality,
      'iqama_expiry_date': iqamaExpiryDate,
      'driving_license_expiry_date': drivingLicenseExpiryDate,
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
      'user': user?.toJson(),
    };
  }
}

class UserModel {
  final String? email;
  final int? id;
  final String? username;

  UserModel({this.email, this.id, this.username});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] as String?,
      id: json['id'] as int?,
      username: json['username'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'id': id,
      'username': username,
    };
  }
}
