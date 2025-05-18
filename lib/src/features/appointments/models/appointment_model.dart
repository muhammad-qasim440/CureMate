class AppointmentModel {
  final String id;
  final String patientUid;
  final String doctorUid;
  final String doctorName;
  final String doctorCategory;
  final String hospital;
  final String date;
  final String timeSlot;
  final String slotType;
  final String status;
  final int consultationFee;
  final String createdAt;
  final String? patientNotes;
  final String? updatedAt;
  final String bookerName;
  final String patientName;
  final String patientNumber;
  final String patientType;
  final String? reminderTime;
  final bool isRated;
  final double? rating;
  final String? review;
  final String? ratedAt;

  AppointmentModel({
    required this.id,
    required this.patientUid,
    required this.doctorUid,
    required this.doctorName,
    required this.doctorCategory,
    required this.hospital,
    required this.date,
    required this.timeSlot,
    required this.slotType,
    required this.status,
    required this.consultationFee,
    required this.createdAt,
    this.patientNotes,
    this.updatedAt,
    required this.bookerName,
    required this.patientName,
    required this.patientNumber,
    required this.patientType,
    this.reminderTime,
    this.isRated = false,
    this.rating,
    this.review,
    this.ratedAt,
  });

  factory AppointmentModel.fromMap(Map<dynamic, dynamic> map, String id) {
    return AppointmentModel(
      id: id,
      patientUid: map['patientUid'] ?? '',
      doctorUid: map['doctorUid'] ?? '',
      doctorName: map['doctorName'] ?? '',
      doctorCategory: map['doctorCategory'] ?? '',
      hospital: map['hospital'] ?? '',
      date: map['date'] ?? '',
      timeSlot: map['timeSlot'] ?? '',
      slotType: map['slotType'] ?? 'FullDay',
      status: map['status'] ?? 'pending',
      consultationFee: map['consultationFee']?.toInt() ?? 0,
      createdAt: map['createdAt'] ?? '',
      patientNotes: map['patientNotes'],
      updatedAt: map['updatedAt'],
      bookerName: map['bookerName'] ?? '',
      patientName: map['patientName'] ?? '',
      patientNumber: map['patientNumber'] ?? '',
      patientType: map['patientType'] ?? 'Myself',
      reminderTime: map['reminderTime'],
      isRated: map['isRated'] ?? false,
      rating: (map['rating'] as num?)?.toDouble(),
      review: map['review'],
      ratedAt: map['ratedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientUid': patientUid,
      'doctorUid': doctorUid,
      'doctorName': doctorName,
      'doctorCategory': doctorCategory,
      'hospital': hospital,
      'date': date,
      'timeSlot': timeSlot,
      'slotType': slotType,
      'status': status,
      'consultationFee': consultationFee,
      'createdAt': createdAt,
      'patientNotes': patientNotes,
      'updatedAt': updatedAt,
      'bookerName': bookerName,
      'patientName': patientName,
      'patientNumber': patientNumber,
      'patientType': patientType,
      'reminderTime': reminderTime,
      'isRated': isRated,
      'rating': rating,
      'review': review,
      'ratedAt': ratedAt,
    };
  }

  AppointmentModel copyWith({
    String? id,
    String? patientUid,
    String? doctorUid,
    String? doctorName,
    String? doctorCategory,
    String? hospital,
    String? date,
    String? timeSlot,
    String? slotType,
    String? status,
    int? consultationFee,
    String? createdAt,
    String? patientNotes,
    String? updatedAt,
    String? bookerName,
    String? patientName,
    String? patientNumber,
    String? patientType,
    String? reminderTime,
    bool? isRated,
    double? rating,
    String? review,
    String? ratedAt,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      patientUid: patientUid ?? this.patientUid,
      doctorUid: doctorUid ?? this.doctorUid,
      doctorName: doctorName ?? this.doctorName,
      doctorCategory: doctorCategory ?? this.doctorCategory,
      hospital: hospital ?? this.hospital,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      slotType: slotType ?? this.slotType,
      status: status ?? this.status,
      consultationFee: consultationFee ?? this.consultationFee,
      createdAt: createdAt ?? this.createdAt,
      patientNotes: patientNotes ?? this.patientNotes,
      updatedAt: updatedAt ?? this.updatedAt,
      bookerName: bookerName ?? this.bookerName,
      patientName: patientName ?? this.patientName,
      patientNumber: patientNumber ?? this.patientNumber,
      patientType: patientType ?? this.patientType,
      reminderTime: reminderTime ?? this.reminderTime,
      isRated: isRated ?? this.isRated,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      ratedAt: ratedAt ?? this.ratedAt,
    );
  }
}