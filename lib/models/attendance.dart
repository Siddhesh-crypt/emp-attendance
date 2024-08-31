class Attendance {
  final int id;
  final int employeeId;
  final DateTime time;
  final String location;

  Attendance({required this.id, required this.employeeId, required this.time, required this.location});

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      employeeId: json['employee_id'],
      time: DateTime.parse(json['time']),
      location: json['location'],
    );
  }
}
