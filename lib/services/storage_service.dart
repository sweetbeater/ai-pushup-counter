import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise_record.dart';

class StorageService {
  static const _key = 'exercise_records';

  Future<void> saveRecord(ExerciseRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await getRecords();
    records.insert(0, record);
    final jsonList = records.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  Future<List<ExerciseRecord>> getRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    return jsonList
        .map((s) => ExerciseRecord.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  /// 해당 운동의 1회 세션 최고 기록
  Future<int> getBestCount(String exerciseId) async {
    final records = await getRecords();
    return records
        .where((r) => r.exerciseId == exerciseId)
        .fold<int>(0, (best, r) => r.count > best ? r.count : best);
  }
}
