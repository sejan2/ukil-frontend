class AdvocateProfile {
  final String? id;
  final String? userId;
  final String? status;
  final String? barNumber;
  final String? phone;
  final String? photoUrl;
  final String? location;
  final String? district;
  final String? division;
  final List<String> practiceAreas;
  final String? bio;
  final int experienceYears;
  final String? courtName;
  final String? createdAt;
  final String? updatedAt;

  // Joined from users table (for admin listing)
  final String? name;
  final String? email;

  AdvocateProfile({
    this.id,
    this.userId,
    this.status,
    this.barNumber,
    this.phone,
    this.photoUrl,
    this.location,
    this.district,
    this.division,
    this.practiceAreas = const [],
    this.bio,
    this.experienceYears = 0,
    this.courtName,
    this.createdAt,
    this.updatedAt,
    this.name,
    this.email,
  });

  factory AdvocateProfile.fromJson(Map<String, dynamic> json) {
    return AdvocateProfile(
      id: json['id'],
      userId: json['user_id'],
      status: json['status'],
      barNumber: json['bar_number'],
      phone: json['phone'],
      photoUrl: json['photo_url'],
      location: json['location'],
      district: json['district'],
      division: json['division'],
      practiceAreas: json['practice_areas'] != null
          ? List<String>.from(json['practice_areas'])
          : [],
      bio: json['bio'],
      experienceYears: json['experience_years'] ?? 0,
      courtName: json['court_name'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (status != null) 'status': status,
      'bar_number': barNumber ?? '',
      'phone': phone ?? '',
      'photo_url': photoUrl ?? '',
      'location': location ?? '',
      'district': district ?? '',
      'division': division ?? '',
      'practice_areas': practiceAreas,
      'bio': bio ?? '',
      'experience_years': experienceYears,
      'court_name': courtName ?? '',
    };
  }

  AdvocateProfile copyWith({
    String? id,
    String? userId,
    String? status,
    String? barNumber,
    String? phone,
    String? photoUrl,
    String? location,
    String? district,
    String? division,
    List<String>? practiceAreas,
    String? bio,
    int? experienceYears,
    String? courtName,
    String? name,
    String? email,
  }) {
    return AdvocateProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      barNumber: barNumber ?? this.barNumber,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      location: location ?? this.location,
      district: district ?? this.district,
      division: division ?? this.division,
      practiceAreas: practiceAreas ?? this.practiceAreas,
      bio: bio ?? this.bio,
      experienceYears: experienceYears ?? this.experienceYears,
      courtName: courtName ?? this.courtName,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }
}
