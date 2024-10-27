class BadgeScan {
  final String name;
  final String function;
  final bool isAuthorized;
  final DateTime scanTime;

  BadgeScan({
    required this.name,
    required this.function,
    required this.isAuthorized,
    required this.scanTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'function': function,
      'isAuthorized': isAuthorized,
      'scanTime': scanTime.toIso8601String(),
    };
  }

  factory BadgeScan.fromJson(Map<String, dynamic> json) {
    return BadgeScan(
      name: json['name'],
      function: json['function'],
      isAuthorized: json['isAuthorized'],
      scanTime: DateTime.parse(json['scanTime']),
    );
  }
}
