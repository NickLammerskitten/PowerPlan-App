class Plan {
  const Plan({
    required this.id
});

  final String id;

  @override
  String toString() {
    return 'Plan{id: $id}';
  }

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'] as String,
    );
  }
}