class Workout {
  final String exercise;
  final int sets;
  final int reps;
  final double weight;
  final double volume;
  final int xpEarned;
  final String date;

  Workout({
    required this.exercise,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.volume,
    required this.xpEarned,
    required this.date,
  });

  Map<dynamic, dynamic> toMap() {
    return {
      'exercise': exercise,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'volume': volume,
      'xp_earned': xpEarned,
      'date': date,
    };
  }

  factory Workout.fromMap(Map<dynamic, dynamic> map) {
    return Workout(
      exercise: map['exercise'],
      sets: map['sets'],
      reps: map['reps'],
      weight: map['weight'],
      volume: map['volume'],
      xpEarned: map['xp_earned'],
      date: map['date'],
    );
  }
}