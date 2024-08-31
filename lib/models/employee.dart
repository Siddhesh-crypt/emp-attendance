class Employee {
  final int id;
  final String name;
  final String image;

  Employee({required this.id, required this.name, required this.image});

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['name'],
      image: json['image'],
    );
  }
}
