class ExerciseRecord {
  final DateTime date;
  final int count;
  final int durationSeconds;
  final String exerciseId;
  final String exerciseName;

  const ExerciseRecord({
    required this.date,
    required this.count,
    required this.durationSeconds,
    this.exerciseId = 'pushup',
    this.exerciseName = '팔굽혀펴기',
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'count': count,
        'durationSeconds': durationSeconds,
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
      };

  factory ExerciseRecord.fromJson(Map<String, dynamic> json) => ExerciseRecord(
        date: DateTime.parse(json['date'] as String),
        count: json['count'] as int,
        durationSeconds: json['durationSeconds'] as int,
        exerciseId: json['exerciseId'] as String? ?? 'pushup',
        exerciseName: json['exerciseName'] as String? ?? '팔굽혀펴기',
      );
}
