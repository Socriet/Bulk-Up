import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../models/routine.dart';
import '../models/exercise.dart';

class RoutineDetailScreen extends StatefulWidget {
  final Routine routine;
  const RoutineDetailScreen({super.key, required this.routine});

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  late Routine _routine;
  // Tracks which exercises have been marked done this session
  final Set<String> _doneThisSession = {};

  @override
  void initState() {
    super.initState();
    _routine = widget.routine;
  }

  // Reload the routine from Hive so edits persist correctly
  Future<void> _reload() async {
    final all = await DatabaseHelper.instance.getRoutines();
    final updated = all.firstWhere(
      (r) => r['id'] == _routine.id,
      orElse: () => _routine.toMap(),
    );
    if (mounted) setState(() => _routine = Routine.fromMap(updated));
  }

  Future<void> _markDone(Exercise exercise) async {
    await DatabaseHelper.instance.addXP(
      exercise.xpValue,
      exercise.name,
      exercise.volume,
    );
    setState(() => _doneThisSession.add(exercise.id));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${exercise.name} done! +${exercise.xpValue} XP 💪'),
        backgroundColor: Colors.greenAccent.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _addExercise() async {
    final result = await showDialog<Exercise>(
      context: context,
      builder: (_) => const _ExerciseDialog(),
    );
    if (result == null) return;

    final all = await DatabaseHelper.instance.getRoutines();
    final idx = all.indexWhere((r) => r['id'] == _routine.id);
    if (idx == -1) return;

    final exercises = List<Map<dynamic, dynamic>>.from(
        all[idx]['exercises'] as List);
    exercises.add(result.toMap());
    all[idx] = Map<dynamic, dynamic>.from(all[idx])
      ..['exercises'] = exercises;
    await DatabaseHelper.instance.saveRoutines(all);
    await _reload();
  }

  Future<void> _editExercise(Exercise exercise) async {
    final result = await showDialog<Exercise>(
      context: context,
      builder: (_) => _ExerciseDialog(initial: exercise),
    );
    if (result == null) return;

    final all = await DatabaseHelper.instance.getRoutines();
    final idx = all.indexWhere((r) => r['id'] == _routine.id);
    if (idx == -1) return;

    final exercises = List<Map<dynamic, dynamic>>.from(
        all[idx]['exercises'] as List);
    final eIdx = exercises.indexWhere((e) => e['id'] == exercise.id);
    if (eIdx != -1) exercises[eIdx] = result.toMap();
    all[idx] = Map<dynamic, dynamic>.from(all[idx])
      ..['exercises'] = exercises;
    await DatabaseHelper.instance.saveRoutines(all);
    await _reload();
  }

  Future<void> _deleteExercise(Exercise exercise) async {
    final all = await DatabaseHelper.instance.getRoutines();
    final idx = all.indexWhere((r) => r['id'] == _routine.id);
    if (idx == -1) return;

    final exercises = List<Map<dynamic, dynamic>>.from(
        all[idx]['exercises'] as List);
    exercises.removeWhere((e) => e['id'] == exercise.id);
    all[idx] = Map<dynamic, dynamic>.from(all[idx])
      ..['exercises'] = exercises;
    await DatabaseHelper.instance.saveRoutines(all);
    await _reload();
  }

  void _resetSession() {
    setState(() => _doneThisSession.clear());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Session reset — ready to go again!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exercises = _routine.exercises
        .map((e) => Exercise.fromMap(e))
        .toList();
    final allDone = exercises.isNotEmpty &&
        exercises.every((e) => _doneThisSession.contains(e.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(_routine.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (_doneThisSession.isNotEmpty)
            TextButton.icon(
              onPressed: _resetSession,
              icon: const Icon(Icons.refresh, color: Colors.grey),
              label: const Text('Reset', style: TextStyle(color: Colors.grey)),
            ),
        ],
      ),
      body: exercises.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_box_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No exercises yet',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Tap + to add your first exercise.',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : Column(
              children: [
                // Progress indicator when session is active
                if (_doneThisSession.isNotEmpty)
                  _SessionProgress(
                    done: _doneThisSession.length,
                    total: exercises.length,
                    allDone: allDone,
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: exercises.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      final isDone = _doneThisSession.contains(exercise.id);
                      return _ExerciseTile(
                        exercise: exercise,
                        isDone: isDone,
                        onDone: isDone ? null : () => _markDone(exercise),
                        onEdit: () => _editExercise(exercise),
                        onDelete: () => _deleteExercise(exercise),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExercise,
        backgroundColor: Colors.greenAccent.shade700,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ── Session progress banner ───────────────────────────────────────────────────

class _SessionProgress extends StatelessWidget {
  final int done;
  final int total;
  final bool allDone;

  const _SessionProgress({
    required this.done,
    required this.total,
    required this.allDone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: allDone
          ? Colors.greenAccent.shade700.withOpacity(0.15)
          : const Color(0xFF1F1F1F),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allDone ? '🎉 Workout complete!' : '$done / $total done',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: allDone ? Colors.greenAccent : Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: done / total,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade800,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.greenAccent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Exercise tile ─────────────────────────────────────────────────────────────

class _ExerciseTile extends StatelessWidget {
  final Exercise exercise;
  final bool isDone;
  final VoidCallback? onDone;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExerciseTile({
    required this.exercise,
    required this.isDone,
    required this.onDone,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isDone ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F1F),
          borderRadius: BorderRadius.circular(12),
          border: isDone
              ? Border.all(color: Colors.greenAccent.withOpacity(0.4))
              : null,
        ),
        child: Row(
          children: [
            // Exercise info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isDone)
                        const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Icon(Icons.check_circle,
                              color: Colors.greenAccent, size: 16),
                        ),
                      Expanded(
                        child: Text(
                          exercise.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration:
                                isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${exercise.sets} sets × ${exercise.reps} reps × ${exercise.weight} kg',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${exercise.volume.toStringAsFixed(0)} kg volume  •  +${exercise.xpValue} XP',
                    style: const TextStyle(
                        color: Colors.greenAccent, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Action buttons
            Column(
              children: [
                // Done button
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDone
                          ? Colors.grey.shade800
                          : Colors.greenAccent.shade700,
                      foregroundColor:
                          isDone ? Colors.grey : Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: onDone,
                    child: Text(
                      isDone ? 'Done ✓' : 'Done',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Edit / Delete row
                Row(
                  children: [
                    GestureDetector(
                      onTap: onEdit,
                      child: const Icon(Icons.edit_outlined,
                          color: Colors.grey, size: 18),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: onDelete,
                      child: const Icon(Icons.delete_outline,
                          color: Colors.redAccent, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Add / Edit exercise dialog ─────────────────────────────────────────────────

class _ExerciseDialog extends StatefulWidget {
  final Exercise? initial;
  const _ExerciseDialog({this.initial});

  @override
  State<_ExerciseDialog> createState() => _ExerciseDialogState();
}

class _ExerciseDialogState extends State<_ExerciseDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _sets;
  late final TextEditingController _reps;
  late final TextEditingController _weight;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial?.name ?? '');
    _sets = TextEditingController(
        text: widget.initial?.sets.toString() ?? '3');
    _reps = TextEditingController(
        text: widget.initial?.reps.toString() ?? '10');
    _weight = TextEditingController(
        text: widget.initial?.weight.toString() ?? '20');
  }

  @override
  void dispose() {
    _name.dispose();
    _sets.dispose();
    _reps.dispose();
    _weight.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final exercise = Exercise(
      id: widget.initial?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _name.text.trim(),
      sets: int.parse(_sets.text),
      reps: int.parse(_reps.text),
      weight: double.parse(_weight.text),
    );
    Navigator.pop(context, exercise);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1F1F1F),
      title: Text(widget.initial == null ? 'Add Exercise' : 'Edit Exercise'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Exercise name',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Required'
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _DialogField(controller: _sets, label: 'Sets', min: 1, max: 20)),
                  const SizedBox(width: 8),
                  Expanded(child: _DialogField(controller: _reps, label: 'Reps', min: 1, max: 100)),
                  const SizedBox(width: 8),
                  Expanded(child: _DialogField(controller: _weight, label: 'kg', min: 0, max: 1000, isDecimal: true)),
                ],
              ),
              const SizedBox(height: 12),
              // Live XP preview
              _DialogXpPreview(
                setsCtrl: _sets,
                repsCtrl: _reps,
                weightCtrl: _weight,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent.shade700,
            foregroundColor: Colors.black,
          ),
          onPressed: _save,
          child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class _DialogXpPreview extends StatefulWidget {
  final TextEditingController setsCtrl;
  final TextEditingController repsCtrl;
  final TextEditingController weightCtrl;

  const _DialogXpPreview({
    required this.setsCtrl,
    required this.repsCtrl,
    required this.weightCtrl,
  });

  @override
  State<_DialogXpPreview> createState() => _DialogXpPreviewState();
}

class _DialogXpPreviewState extends State<_DialogXpPreview> {
  @override
  void initState() {
    super.initState();
    widget.setsCtrl.addListener(_u);
    widget.repsCtrl.addListener(_u);
    widget.weightCtrl.addListener(_u);
  }

  void _u() => setState(() {});

  @override
  void dispose() {
    widget.setsCtrl.removeListener(_u);
    widget.repsCtrl.removeListener(_u);
    widget.weightCtrl.removeListener(_u);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = int.tryParse(widget.setsCtrl.text) ?? 0;
    final r = int.tryParse(widget.repsCtrl.text) ?? 0;
    final w = double.tryParse(widget.weightCtrl.text) ?? 0;
    final xp = ((s * r * w) / 10).floor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.greenAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('XP per completion:',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
          Text('+$xp XP',
              style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ],
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final double min;
  final double max;
  final bool isDecimal;

  const _DialogField({
    required this.controller,
    required this.label,
    required this.min,
    required this.max,
    this.isDecimal = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
          labelText: label, border: const OutlineInputBorder()),
      keyboardType:
          TextInputType.numberWithOptions(decimal: isDecimal),
      textAlign: TextAlign.center,
      validator: (v) {
        if (v == null || v.isEmpty) return '?';
        final n = double.tryParse(v);
        if (n == null || n < min || n > max) return '!';
        return null;
      },
    );
  }
}
