// Model for API response
class Diagnosis {
  final String diagnosis;
  final double confidence;
  final String doctorType;

  Diagnosis({required this.diagnosis, required this.confidence, required this.doctorType});

  factory Diagnosis.fromJson(Map<String, dynamic> json) {
    return Diagnosis(
      diagnosis: json['diagnosis'],
      confidence: json['confidence'].toDouble(),
      doctorType: json['doctor_type'],
    );
  }
}