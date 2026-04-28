class Routine {
  final String id;
  final String name;
  final List<Map<dynamic, dynamic>> exercises;

  Routine({
    required this.id,
    required this.name,
    required this.exercises,
  });

  Map<dynamic, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'exercises': exercises,
    };
  }

  factory Routine.fromMap(Map<dynamic, dynamic> map) {
    return Routine(
      id: map['id'] as String,
      name: map['name'] as String,
      exercises: List<Map<dynamic, dynamic>>.from(
        (map['exercises'] as List).map((e) => Map<dynamic, dynamic>.from(e)),
      ),
    );
  }

  Routine copyWith({String? name, List<Map<dynamic, dynamic>>? exercises}) {
    return Routine(
      id: id,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
    );
  }
}
