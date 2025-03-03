class BadgeScan {
  final String titre;
  final String message;
  final String? details;
  final bool isAuthorized;
  final int statusCode;
  final DateTime scanTime;

  BadgeScan({
    required this.titre,
    required this.message,
    required this.details,
    required this.isAuthorized,
    required this.statusCode,
    required this.scanTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'titre': titre,
      'message': message,
      'details': details ?? 'RAS',
      'isAuthorized': isAuthorized,
      'statusCode': statusCode,
      'scanTime': scanTime.toIso8601String(),
    };
  }

  factory BadgeScan.fromJson(Map<String, dynamic> json) {
    return BadgeScan(
      titre: json['titre'],
      message: json['message'],
      details: json['details'],
      isAuthorized: json['isAuthorized'],
      statusCode: json['statusCode'],
      scanTime: DateTime.parse(json['scanTime']),
    );
  }
}
