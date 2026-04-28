import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../database_helper.dart';
import '../models/routine.dart';
import 'routine_detail_screen.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  List<Routine> _routines = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = await DatabaseHelper.instance.database;
    db.listenable().addListener(_onDbChange);
    _readRoutines(db);
  }

  void _onDbChange() async {
    final db = await DatabaseHelper.instance.database;
    _readRoutines(db);
  }

  void _readRoutines(Box db) {
    final raw = List<dynamic>.from(db.get('routines') ?? []);
    if (mounted) {
      setState(() {
        _routines = raw
            .map((e) => Routine.fromMap(Map<dynamic, dynamic>.from(e)))
            .toList();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    DatabaseHelper.instance.database.then((db) {
      db.listenable().removeListener(_onDbChange);
    });
    super.dispose();
  }

  Future<void> _addRoutine() async {
    final name = await _showNameDialog(context, title: 'New Routine');
    if (name == null || name.trim().isEmpty) return;

    final routine = Routine(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      exercises: [],
    );

    final all = await DatabaseHelper.instance.getRoutines();
    all.add(routine.toMap());
    await DatabaseHelper.instance.saveRoutines(all);
  }

  Future<void> _deleteRoutine(Routine routine) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        title: const Text('Delete Routine?'),
        content: Text('Are you sure you want to delete "${routine.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final all = await DatabaseHelper.instance.getRoutines();
    all.removeWhere((r) => r['id'] == routine.id);
    await DatabaseHelper.instance.saveRoutines(all);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
    }

    return Scaffold(
      body: _routines.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.list_alt, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No routines yet',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Tap + to create your first routine.',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _routines.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final routine = _routines[index];
                return _RoutineTile(
                  routine: routine,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RoutineDetailScreen(routine: routine),
                    ),
                  ),
                  onDelete: () => _deleteRoutine(routine),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRoutine,
        backgroundColor: Colors.greenAccent.shade700,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _RoutineTile extends StatelessWidget {
  final Routine routine;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _RoutineTile({
    required this.routine,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final exerciseCount = routine.exercises.length;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F1F),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.fitness_center,
                  color: Colors.greenAccent, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(routine.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(
                    exerciseCount == 0
                        ? 'No exercises yet'
                        : '$exerciseCount exercise${exerciseCount == 1 ? '' : 's'}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: Colors.redAccent, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

Future<String?> _showNameDialog(BuildContext context,
    {required String title, String? initial}) async {
  final controller = TextEditingController(text: initial ?? '');
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1F1F1F),
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          hintText: 'e.g. Push Day',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent.shade700,
            foregroundColor: Colors.black,
          ),
          onPressed: () => Navigator.pop(ctx, controller.text),
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
