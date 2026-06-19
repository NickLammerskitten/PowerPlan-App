import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show
        Divider,
        Material,
        ReorderableListView,
        ReorderableDragStartListener,
        DefaultMaterialLocalizations,
        DefaultWidgetsLocalizations;
import 'package:power_plan_fe/model/plan.dart';
import 'package:power_plan_fe/model/set_entry_draft.dart';
import 'package:power_plan_fe/pages/widgets/set_editor.dart';
import 'package:power_plan_fe/pages/select_exercise_page.dart';
import 'package:power_plan_fe/services/api/exercise_api.dart';
import 'package:power_plan_fe/services/api/plan_api.dart';
import 'package:power_plan_fe/services/api_service.dart';

class PlanEditPage extends StatefulWidget {
  const PlanEditPage({Key? key, required this.id}) : super(key: key);

  final String id;

  @override
  _PlanEditPageState createState() => _PlanEditPageState();
}

class _PlanEditPageState extends State<PlanEditPage> {
  static const int _maxWeeks = 18;

  final PlanApi _planApi = PlanApi(ApiService());
  final ExerciseApi _exerciseApi = ExerciseApi(ApiService());
  final ScrollController _scrollController = ScrollController();
  late Future<Plan> _planFuture;

  /// Local working copies of the sets keyed by their backend id.
  final Map<String, SetEntryDraft> _drafts = {};

  String? _errorMessage;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Reloads the plan while preserving the current scroll position.
  Future<void> _refreshKeepScroll() async {
    final offset =
        _scrollController.hasClients ? _scrollController.offset : 0.0;
    await _refresh();
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      _scrollController.jumpTo(offset.clamp(0.0, max));
    });
  }

  @override
  void initState() {
    super.initState();
    _planFuture = _load();
  }

  Future<Plan> _load() async {
    final plan = await _planApi.fetchPlan(widget.id);
    _drafts.clear();
    for (final week in plan.weeks) {
      for (final day in week.trainingDays) {
        for (final entry in day.exerciseEntries) {
          for (final set in entry.sets) {
            _drafts[set.id] = SetEntryDraft.fromView(set);
          }
        }
      }
    }
    return plan;
  }

  Future<void> _refresh() async {
    final future = _load();
    setState(() {
      _planFuture = future;
    });
    await future;
  }

  Future<void> _addSet(String exerciseEntryId) async {
    final draft = SetEntryDraft.defaultSet();
    try {
      await _planApi.addSet(widget.id, exerciseEntryId, draft);
      await _refresh();
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler beim Hinzufügen des Sets: $e';
      });
    }
  }

  Future<void> _saveSet(String setId) async {
    final draft = _drafts[setId];
    if (draft == null) return;
    if (!draft.isValid()) {
      setState(() {
        _errorMessage = 'Set ist ungültig – bitte Eingaben prüfen.';
      });
      return;
    }
    try {
      await _planApi.editSet(widget.id, setId, draft);
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Fehler beim Speichern des Sets: $e';
        });
      }
    }
  }

  Future<void> _deleteSet(String setId) async {
    try {
      await _planApi.removeSet(widget.id, setId);
      await _refresh();
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler beim Löschen des Sets: $e';
      });
    }
  }

  Future<void> _addDay(String weekId, int nextDayNumber) async {
    try {
      await _planApi.addDay(widget.id, weekId, 'Tag $nextDayNumber');
      await _refreshKeepScroll();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Fehler beim Hinzufügen des Tages: $e';
        });
      }
    }
  }

  Future<void> _removeDay(String dayId) async {
    try {
      await _planApi.removeDay(widget.id, dayId);
      await _refreshKeepScroll();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Fehler beim Löschen des Tages: $e';
        });
      }
    }
  }

  Future<void> _renameDay(TrainingDayView day, String weekId) async {
    final controller = TextEditingController(text: day.name);
    final newName = await showCupertinoDialog<String>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Tag umbenennen'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: CupertinoTextField(
            controller: controller,
            autofocus: true,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Abbrechen'),
            onPressed: () => Navigator.of(ctx).pop(null),
          ),
          CupertinoDialogAction(
            child: const Text('Speichern'),
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
          ),
        ],
      ),
    );
    if (newName == null || newName.isEmpty || newName == day.name) return;
    try {
      await _planApi.editDay(widget.id, day.id, weekId: weekId, name: newName);
      await _refreshKeepScroll();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Fehler beim Umbenennen des Tages: $e';
        });
      }
    }
  }

  Future<void> _confirmRemoveDay(TrainingDayView day) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Tag löschen'),
        content: Text('Tag "${day.name}" wirklich löschen?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Abbrechen'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Löschen'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _removeDay(day.id);
    }
  }

  Future<void> _addExercise(String trainingDayId) async {
    await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => SelectExercisePage(
          exerciseApi: _exerciseApi,
          onExerciseSelected: (exercise) async {
            try {
              await _planApi.addExercise(
                widget.id,
                trainingDayId: trainingDayId,
                exerciseId: exercise.id,
              );
              await _refreshKeepScroll();
            } catch (e) {
              if (mounted) {
                setState(() {
                  _errorMessage = 'Fehler beim Hinzufügen der Übung: $e';
                });
              }
            }
          },
        ),
      ),
    );
  }

  Future<void> _removeExercise(String exerciseEntryId) async {
    try {
      await _planApi.removeExercise(widget.id, exerciseEntryId);
      await _refreshKeepScroll();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Fehler beim Löschen der Übung: $e';
        });
      }
    }
  }

  Future<void> _confirmRemoveExercise(ExerciseEntryView entry) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Übung löschen'),
        content: Text('Übung "${entry.exercise.name}" wirklich löschen?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Abbrechen'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Löschen'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _removeExercise(entry.id);
    }
  }

  /// Reorders an exercise within its training day.
  Future<void> _reorderExercise(
    TrainingDayView day,
    int oldIndex,
    int newIndex,
  ) async {
    var target = newIndex;
    if (target > oldIndex) target -= 1;
    if (target == oldIndex) return;
    final entries = day.exerciseEntries;
    if (oldIndex < 0 || oldIndex >= entries.length) return;
    if (target < 0 || target >= entries.length) return;

    final moved = entries[oldIndex];
    // Determine id of the entry that should be *before* the moved one in the
    // new order. Build a list without the moved entry to compute it cleanly.
    final without = [...entries]..removeAt(oldIndex);
    final beforeId = target == 0 ? null : without[target - 1].id;
    try {
      await _planApi.moveExercise(
        widget.id,
        moved.id,
        exerciseIdBefore: beforeId,
      );
      await _refreshKeepScroll();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Fehler beim Verschieben der Übung: $e';
        });
      }
    }
  }

  /// Reorders a day within its week.
  Future<void> _reorderDay(
    WeekView week,
    int oldIndex,
    int newIndex,
  ) async {
    var target = newIndex;
    if (target > oldIndex) target -= 1;
    if (target == oldIndex) return;
    final days = week.trainingDays;
    if (oldIndex < 0 || oldIndex >= days.length) return;
    if (target < 0 || target >= days.length) return;

    final moved = days[oldIndex];
    final without = [...days]..removeAt(oldIndex);
    final beforeId = target == 0 ? null : without[target - 1].id;
    try {
      await _planApi.moveDay(widget.id, moved.id, dayIdBefore: beforeId);
      await _refreshKeepScroll();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Fehler beim Verschieben des Tages: $e';
        });
      }
    }
  }

  Future<void> _addWeek() async {
    try {
      await _planApi.addWeek(widget.id);
      await _refreshKeepScroll();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Fehler beim Hinzufügen der Woche: $e';
        });
      }
    }
  }

  Future<void> _removeWeek(String weekId) async {
    try {
      await _planApi.removeWeek(widget.id, weekId);
      await _refreshKeepScroll();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Fehler beim Löschen der Woche: $e';
        });
      }
    }
  }

  Future<void> _confirmRemoveWeek(String weekId, int weekNumber) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Woche löschen'),
        content: Text('Woche $weekNumber wirklich löschen?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Abbrechen'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Löschen'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _removeWeek(weekId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Plan Bearbeiten'),
      ),
      child: SafeArea(
        child: FutureBuilder<Plan>(
          future: _planFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CupertinoActivityIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No data found'));
            }

            final plan = snapshot.data!;
            return ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildHeader(plan),
                const SizedBox(height: 16),
                if (_errorMessage != null) _buildErrorMessage(),
                ..._buildWeeks(plan),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(Plan plan) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Name des Plans:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            plan.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: CupertinoColors.systemRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: CupertinoColors.systemRed),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  List<Widget> _buildWeeks(Plan plan) {
    final widgets = <Widget>[];
    for (var w = 0; w < plan.weeks.length; w++) {
      final week = plan.weeks[w];
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Text(
                'Woche ${w + 1}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _confirmRemoveWeek(week.id, w + 1),
                child: const Icon(
                  CupertinoIcons.trash,
                  size: 20,
                  color: CupertinoColors.systemRed,
                ),
              ),
            ],
          ),
        ),
      );
      if (week.trainingDays.isNotEmpty) {
        widgets.add(
          Material(
            color: const Color(0x00000000),
            child: Localizations.override(
              context: context,
              delegates: const [
                DefaultMaterialLocalizations.delegate,
                DefaultWidgetsLocalizations.delegate,
              ],
              child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: week.trainingDays.length,
              onReorder: (oldIndex, newIndex) =>
                  _reorderDay(week, oldIndex, newIndex),
              itemBuilder: (context, index) {
                final day = week.trainingDays[index];
                return KeyedSubtree(
                  key: ValueKey('day-${day.id}'),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildDay(day, week.id)),
                      ReorderableDragStartListener(
                        index: index,
                        child: const Padding(
                          padding: EdgeInsets.only(
                            left: 4,
                            top: 24,
                            right: 4,
                          ),
                          child: Icon(
                            CupertinoIcons.line_horizontal_3,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            ),
          ),
        );
      }
      widgets.add(_buildAddDayButton(week.id, week.trainingDays.length + 1));
    }
    if (plan.weeks.length < _maxWeeks) {
      widgets.add(
      Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
        child: CupertinoButton(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: CupertinoColors.activeBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          onPressed: _addWeek,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                CupertinoIcons.add,
                size: 16,
                color: CupertinoColors.activeBlue,
              ),
              SizedBox(width: 8),
              Text(
                'Woche hinzufügen',
                style: TextStyle(color: CupertinoColors.activeBlue),
              ),
            ],
          ),
        ),
      ),
    );
    }
    return widgets;
  }

  Widget _buildAddDayButton(String weekId, int nextDayNumber) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: CupertinoColors.activeBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        onPressed: () => _addDay(weekId, nextDayNumber),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              CupertinoIcons.add,
              size: 16,
              color: CupertinoColors.activeBlue,
            ),
            SizedBox(width: 8),
            Text(
              'Tag hinzufügen',
              style: TextStyle(color: CupertinoColors.activeBlue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDay(TrainingDayView day, String weekId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _renameDay(day, weekId),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          day.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        CupertinoIcons.pencil,
                        size: 16,
                        color: CupertinoColors.systemGrey,
                      ),
                    ],
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _confirmRemoveDay(day),
                child: const Icon(
                  CupertinoIcons.trash,
                  size: 18,
                  color: CupertinoColors.systemRed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (day.exerciseEntries.isEmpty)
            const Text(
              'Keine Übungen.',
              style: TextStyle(
                color: CupertinoColors.systemGrey,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Material(
              color: const Color(0x00000000),
              child: Localizations.override(
                context: context,
                delegates: const [
                  DefaultMaterialLocalizations.delegate,
                  DefaultWidgetsLocalizations.delegate,
                ],
                child: ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                itemCount: day.exerciseEntries.length,
                onReorder: (oldIndex, newIndex) =>
                    _reorderExercise(day, oldIndex, newIndex),
                itemBuilder: (context, index) {
                  final entry = day.exerciseEntries[index];
                  return KeyedSubtree(
                    key: ValueKey('exercise-${entry.id}'),
                    child: _buildExerciseEntry(entry, index),
                  );
                },
              ),
              ),
            ),
          _buildAddExerciseButton(day.id),
        ],
      ),
    );
  }

  Widget _buildAddExerciseButton(String trainingDayId) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        color: CupertinoColors.activeBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        onPressed: () => _addExercise(trainingDayId),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              CupertinoIcons.add,
              size: 14,
              color: CupertinoColors.activeBlue,
            ),
            SizedBox(width: 4),
            Text(
              'Übung hinzufügen',
              style: TextStyle(
                color: CupertinoColors.activeBlue,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseEntry(ExerciseEntryView entry, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CupertinoColors.systemGrey4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.exercise.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    CupertinoIcons.line_horizontal_3,
                    size: 18,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _confirmRemoveExercise(entry),
                child: const Icon(
                  CupertinoIcons.trash,
                  size: 18,
                  color: CupertinoColors.systemRed,
                ),
              ),
            ],
          ),
          if (entry.sets.isNotEmpty) const Divider(height: 16),
          ...entry.sets.asMap().entries.map((mapEntry) {
            final setIndex = mapEntry.key;
            final set = mapEntry.value;
            final draft = _drafts[set.id]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SetEditor(
                  setIndex: setIndex,
                  draft: draft,
                  onChanged: () {
                    setState(() {});
                    _saveSet(set.id);
                  },
                  onDelete: () => _deleteSet(set.id),
                ),
                if (setIndex < entry.sets.length - 1)
                  const Divider(height: 16),
              ],
            );
          }),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 10,
              ),
              color: CupertinoColors.activeBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              onPressed: () => _addSet(entry.id),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    CupertinoIcons.add,
                    size: 14,
                    color: CupertinoColors.activeBlue,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Set hinzufügen',
                    style: TextStyle(
                      color: CupertinoColors.activeBlue,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
