import 'dart:convert';

import 'package:localstorage/localstorage.dart';
import '../model/schedule.dart';

class ScheduleService {
  static const String _scheduleKey = 'schedules';

  List<Schedule> getSchedules() {
    final String? storedString = localStorage.getItem(_scheduleKey);
    if (storedString == null) return [];

    final List<dynamic> storedList = json.decode(storedString);
    return storedList.map((item) => Schedule.fromJson(item)).toList();
  }

  Future<void> saveSchedule(Schedule schedule) async {
    final schedules = getSchedules();
    // Check if update or new
    final index = schedules.indexWhere((s) => s.id == schedule.id);
    if (index >= 0) {
      schedules[index] = schedule;
    } else {
      schedules.add(schedule);
    }
    await _saveToStorage(schedules);
  }

  Future<void> deleteSchedule(String id) async {
    final schedules = getSchedules();
    schedules.removeWhere((s) => s.id == id);
    await _saveToStorage(schedules);
  }

  Future<void> _saveToStorage(List<Schedule> schedules) async {
    final List<Map<String, dynamic>> jsonList = schedules
        .map((s) => s.toJson())
        .toList();
    localStorage.setItem(_scheduleKey, json.encode(jsonList));
  }
}
