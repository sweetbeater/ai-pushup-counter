class ExerciseRecord {
  final DateTime date;
  final int count;
  final int durationSeconds;

  const ExerciseRecord({
    required this.date,
    required this.count,
    required this.durationSeconds,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'count': count,
        'durationSeconds': durationSeconds,
      };

  factory ExerciseRecord.fromJson(Map<String, dynamic> json) => ExerciseRecord(
        date: DateTime.parse(json['date'] as String),
        count: json['count'] as int,
        durationSeconds: json['durationSeconds'] as int,
      );
}
