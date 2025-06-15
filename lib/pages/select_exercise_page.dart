import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:power_plan_fe/model/body_section.dart';
import 'package:power_plan_fe/model/classification.dart';
import 'package:power_plan_fe/model/difficutly_level.dart';
import 'package:power_plan_fe/model/exercise.dart';
import 'package:power_plan_fe/services/api/exercise_api.dart';

class SelectExercisePage extends StatefulWidget {
  final ExerciseApi exerciseApi;
  final Function(Exercise) onExerciseSelected;

  const SelectExercisePage({
    Key? key,
    required this.exerciseApi,
    required this.onExerciseSelected,
  }) : super(key: key);

  @override
  _SelectExercisePageState createState() => _SelectExercisePageState();
}

class _SelectExercisePageState extends State<SelectExercisePage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Exercise> _exercises = [];
  bool _isLoading = false;
  bool _hasMoreData = true;
  String _errorMessage = '';

  // Filters
  ExercisesQueryFilters _filters = ExercisesQueryFilters();
  bool _showFilters = false;

  // Filter selections
  List<DifficultyLevel> _selectedDifficultyLevels = [];
  List<BodySection> _selectedBodySections = [];
  List<Classification> _selectedClassifications = [];

  @override
  void initState() {
    super.initState();
    _loadExercises();

    _scrollController.addListener(_scrollListener);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoading && _hasMoreData) {
        _loadMoreExercises();
      }
    }
  }

  Future<void> _onSearchChanged() async {
    // Debounce search input
    await Future.delayed(const Duration(milliseconds: 500));
    if (_searchController.text != _filters.fullTextSearch) {
      setState(() {
        _filters = ExercisesQueryFilters(
          page: 0,
          size: 20,
          fullTextSearch: _searchController.text,
          difficultyLevels: _selectedDifficultyLevels.isEmpty
              ? null
              : _selectedDifficultyLevels,
          bodySections: _selectedBodySections.isEmpty
              ? null
              : _selectedBodySections,
          classifications: _selectedClassifications.isEmpty
              ? null
              : _selectedClassifications,
        );
        _exercises = [];
        _hasMoreData = true;
      });
      _loadExercises();
    }
  }

  Future<void> _loadExercises() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final exercises = await widget.exerciseApi.getExercises(
        filters: _filters,
      );

      setState(() {
        _exercises = exercises;
        _isLoading = false;
        _hasMoreData = exercises.length >= _filters.size;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler beim Laden der Übungen: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreExercises() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final nextPage = _filters.page + 1;
      final newFilters = ExercisesQueryFilters(
        page: nextPage,
        size: _filters.size,
        fullTextSearch: _filters.fullTextSearch,
        difficultyLevels: _filters.difficultyLevels,
        bodySections: _filters.bodySections,
        classifications: _filters.classifications,
      );

      final moreExercises = await widget.exerciseApi.getExercises(
        filters: newFilters,
      );

      setState(() {
        _exercises.addAll(moreExercises);
        _filters = newFilters;
        _isLoading = false;
        _hasMoreData = moreExercises.length >= _filters.size;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler beim Laden weiterer Übungen: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filters = ExercisesQueryFilters(
        page: 0,
        size: 20,
        fullTextSearch: _searchController.text,
        difficultyLevels: _selectedDifficultyLevels.isEmpty
            ? null
            : _selectedDifficultyLevels,
        bodySections: _selectedBodySections.isEmpty
            ? null
            : _selectedBodySections,
        classifications: _selectedClassifications.isEmpty
            ? null
            : _selectedClassifications,
      );
      _exercises = [];
      _hasMoreData = true;
      _showFilters = false;
    });
    _loadExercises();
  }

  void _resetFilters() {
    setState(() {
      _selectedDifficultyLevels = [];
      _selectedBodySections = [];
      _selectedClassifications = [];
    });
  }

  void _toggleFilter(dynamic filter, List<dynamic> selectedList) {
    setState(() {
      if (selectedList.contains(filter)) {
        selectedList.remove(filter);
      } else {
        selectedList.add(filter);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Übung auswählen'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            _showFilters
                ? CupertinoIcons.list_bullet
                : CupertinoIcons.slider_horizontal_3,
            size: 22,
          ),
          onPressed: () {
            setState(() {
              _showFilters = !_showFilters;
            });
          },
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: 'Übung suchen...',
                onSubmitted: (_) => _loadExercises(),
              ),
            ),

            // Filters section
            if (_showFilters) _buildFiltersSection(),

            // Filter chips (show selected filters)
            if (_selectedDifficultyLevels.isNotEmpty ||
                _selectedBodySections.isNotEmpty ||
                _selectedClassifications.isNotEmpty)
              _buildFilterChips(),

            // Exercise list
            Expanded(
              child: _errorMessage.isNotEmpty
                  ? _buildErrorMessage()
                  : _exercises.isEmpty && !_isLoading
                  ? _buildEmptyState()
                  : _buildExerciseList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        border: Border(
          top: BorderSide(color: CupertinoColors.systemGrey4),
          bottom: BorderSide(color: CupertinoColors.systemGrey4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Difficulty levels
          const Text(
            'Schwierigkeitsgrad:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: DifficultyLevel.values.map((level) {
                final isSelected = _selectedDifficultyLevels.contains(level);
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    color: isSelected
                        ? CupertinoColors.activeBlue
                        : CupertinoColors.systemGrey5,
                    borderRadius: BorderRadius.circular(20),
                    child: Text(
                      _getDifficultyLevelName(level),
                      style: TextStyle(
                        color: isSelected
                            ? CupertinoColors.white
                            : CupertinoColors.label,
                        fontSize: 14,
                      ),
                    ),
                    onPressed: () =>
                        _toggleFilter(level, _selectedDifficultyLevels),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Body sections
          const Text(
            'Körperbereich:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: BodySection.values.map((section) {
                final isSelected = _selectedBodySections.contains(section);
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    color: isSelected
                        ? CupertinoColors.activeBlue
                        : CupertinoColors.systemGrey5,
                    borderRadius: BorderRadius.circular(20),
                    child: Text(
                      _getBodySectionName(section),
                      style: TextStyle(
                        color: isSelected
                            ? CupertinoColors.white
                            : CupertinoColors.label,
                        fontSize: 14,
                      ),
                    ),
                    onPressed: () =>
                        _toggleFilter(section, _selectedBodySections),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Classifications
          const Text(
            'Klassifikation:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: Classification.values.map((classification) {
                final isSelected = _selectedClassifications.contains(
                  classification,
                );
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    color: isSelected
                        ? CupertinoColors.activeBlue
                        : CupertinoColors.systemGrey5,
                    borderRadius: BorderRadius.circular(20),
                    child: Text(
                      _getClassificationName(classification),
                      style: TextStyle(
                        color: isSelected
                            ? CupertinoColors.white
                            : CupertinoColors.label,
                        fontSize: 14,
                      ),
                    ),
                    onPressed: () =>
                        _toggleFilter(classification, _selectedClassifications),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Filter action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: const Text('Zurücksetzen'),
                onPressed: _resetFilters,
              ),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: CupertinoColors.activeBlue,
                child: const Text(
                  'Anwenden',
                  style: TextStyle(color: CupertinoColors.white),
                ),
                onPressed: _applyFilters,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    List<Widget> chips = [];

    // Add difficulty level chips
    for (final level in _selectedDifficultyLevels) {
      chips.add(
        _buildFilterChip(_getDifficultyLevelName(level), () {
          setState(() {
            _selectedDifficultyLevels.remove(level);
            _applyFilters();
          });
        }),
      );
    }

    // Add body section chips
    for (final section in _selectedBodySections) {
      chips.add(
        _buildFilterChip(_getBodySectionName(section), () {
          setState(() {
            _selectedBodySections.remove(section);
            _applyFilters();
          });
        }),
      );
    }

    // Add classification chips
    for (final classification in _selectedClassifications) {
      chips.add(
        _buildFilterChip(_getClassificationName(classification), () {
          setState(() {
            _selectedClassifications.remove(classification);
            _applyFilters();
          });
        }),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(spacing: 8, runSpacing: 8, children: chips),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CupertinoColors.systemGrey4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              CupertinoIcons.xmark_circle_fill,
              size: 16,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList() {
    return Stack(
      children: [
        ListView.separated(
          controller: _scrollController,
          itemCount: _exercises.length + (_hasMoreData ? 1 : 0),
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            if (index >= _exercises.length) {
              return _hasMoreData
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(child: CupertinoActivityIndicator()),
                    )
                  : const SizedBox.shrink();
            }

            final exercise = _exercises[index];
            return CupertinoListTile(
              title: Text(exercise.name),
              trailing: const CupertinoListTileChevron(),
              onTap: () {
                widget.onExerciseSelected(exercise);
                Navigator.of(context).pop();
              },
            );
          },
        ),
        if (_isLoading && _exercises.isEmpty)
          const Center(child: CupertinoActivityIndicator()),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            CupertinoIcons.search,
            size: 48,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Keine Übungen gefunden',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Versuchen Sie, Ihre Suchkriterien zu ändern',
            style: TextStyle(color: CupertinoColors.systemGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 48,
              color: CupertinoColors.systemRed,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: CupertinoColors.systemRed),
            ),
            const SizedBox(height: 16),
            CupertinoButton(
              child: const Text('Erneut versuchen'),
              onPressed: _loadExercises,
            ),
          ],
        ),
      ),
    );
  }

  String _getDifficultyLevelName(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.BEGINNER:
        return 'Anfänger';
      case DifficultyLevel.INTERMEDIATE:
        return 'Fortgeschritten';
      case DifficultyLevel.ADVANCED:
        return 'Sehr Fortgeschritten';
      case DifficultyLevel.EXPERT:
        return 'Experte';
    }
  }

  String _getBodySectionName(BodySection section) {
    switch (section) {
      case BodySection.UPPER_BODY:
        return 'Oberkörper';
      case BodySection.MIDSECTION:
        return 'Rumpf';
      case BodySection.LOWER_BODY:
        return 'Unterkörper';
      case BodySection.FULL_BODY:
        return 'Ganzkörper';
      case BodySection.UNSORTED:
        return 'Sonstige';
    }
  }

  String _getClassificationName(Classification classification) {
    switch (classification) {
      case Classification.BALANCE:
        return 'Balance';
      case Classification.BALLISTICS:
        return 'Ballistik';
      case Classification.BODYBUILDING:
        return 'Bodybuilding';
      case Classification.CALISTHENICS:
        return 'Calisthenics';
      case Classification.GRINDS:
        return 'Grinds';
      case Classification.POSTURAL:
        return 'Haltung';
      case Classification.MOBILITY:
        return 'Mobilität';
      case Classification.OLYMPIC_WEIGHTLIFTING:
        return 'Olympisches Gewichtheben';
      case Classification.PLYOMETRIC:
        return 'Plyometrik';
      case Classification.POWERLIFTING:
        return 'Powerlifting';
      case Classification.ANIMAL_FLOW:
        return 'Animal Flow';
      case Classification.UNSORTED:
        return 'Sonstige';
    }
  }
}
