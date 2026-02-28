import 'package:flutter/material.dart';

class Schedule {
  final String id;
  final String title;
  final String description;
  final TimeOfDay time;

  Schedule({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'time': '${time.hour}:${time.minute}',
    };
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    if (json['time'] == null) {
      // Fallback or handle error if time is missing
      return Schedule(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        time: TimeOfDay.now(),
      );
    }
    final timeParts = (json['time'] as String).split(':');
    return Schedule(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
    );
  }
}
