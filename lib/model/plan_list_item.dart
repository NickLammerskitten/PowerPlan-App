class PlanListItem {
  const PlanListItem({
    required this.id,
    required this.name,
    this.difficultyLevel,
    required this.classifications,
    this.status,
  });

  final String id;
  final String name;
  final String? difficultyLevel;
  final List<String> classifications;
  final String? status;

  @override
  String toString() {
    return 'Plan{id: $id}';
  }

  factory PlanListItem.fromJson(Map<String, dynamic> json) {
    return PlanListItem(
      id: json['id'] as String,
      name: json['name'] as String,
      difficultyLevel: json['difficultyLevel'] as String?,
      classifications: List<String>.from(json['classifications']),
      status: json['status'] as String?,
    );
  }
}
