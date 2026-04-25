class UserStats {
  final int totalXp;
  final int level;

  UserStats({
    required this.totalXp,
    required this.level,
  });

  Map<dynamic, dynamic> toMap() {
    return {
      'total_xp': totalXp,
      'level': level,
    };
  }

  factory UserStats.fromMap(Map<dynamic, dynamic> map) {
    return UserStats(
      totalXp: map['total_xp'],
      level: map['level'],
    );
  }
}