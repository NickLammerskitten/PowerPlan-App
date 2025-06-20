import 'body_section.dart';
import 'classification.dart';
import 'difficutly_level.dart';

class ExerciseListItem {
  final String id;
  final String name;

  ExerciseListItem({required this.id, required this.name});

  factory ExerciseListItem.fromJson(Map<String, dynamic> json) {
    return ExerciseListItem(id: json['id'], name: json['name']);
  }
}

class ExercisesQueryFilters {
  final int page;
  final int size;
  final String fullTextSearch;
  final List<DifficultyLevel>? difficultyLevels;
  final List<BodySection>? bodySections;
  final List<Classification>? classifications;

  ExercisesQueryFilters({
    this.page = 0,
    this.size = 20,
    this.fullTextSearch = '',
    this.difficultyLevels,
    this.bodySections,
    this.classifications,
  });

  Map<String, dynamic> toQueryParameters() {
    final Map<String, dynamic> params = {
      'page': page.toString(),
      'size': size.toString(),
    };

    if (fullTextSearch.isNotEmpty) {
      params['fullTextSearch'] = fullTextSearch;
    }

    if (difficultyLevels != null && difficultyLevels!.isNotEmpty) {
      params['difficultyLevels'] = difficultyLevels!
          .map((level) => level.toString().split('.').last)
          .toList();
    }

    if (bodySections != null && bodySections!.isNotEmpty) {
      params['bodySections'] = bodySections!
          .map((section) => section.toString().split('.').last)
          .toList();
    }

    if (classifications != null && classifications!.isNotEmpty) {
      params['classifications'] = classifications!
          .map((classification) => classification.toString().split('.').last)
          .toList();
    }

    return params;
  }
}
