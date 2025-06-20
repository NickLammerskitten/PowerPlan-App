// plan.dart
class Plan {
  final String id;
  final String name;
  // Add more fields as needed later

  Plan({
    required this.id,
    required this.name,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}