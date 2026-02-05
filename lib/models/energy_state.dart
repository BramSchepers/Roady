import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnergyState {
  static final EnergyState _instance = EnergyState._internal();
  factory EnergyState() => _instance;

  EnergyState._internal() {
    _loadState();
  }

  // ValueNotifiers for UI updates
  final ValueNotifier<double> progress = ValueNotifier<double>(0.0);
  final ValueNotifier<List<String>> completedLessons =
      ValueNotifier<List<String>>([]);

  /// Laatst getoonde waarde op de fuel-gauge (bij verlaten home). Wordt gebruikt
  /// om de vul-animatie te starten wanneer de gebruiker terug naar home gaat.
  double lastDisplayedPercentageForGauge = 0.0;

  // Keys for SharedPreferences
  static const String _keyEnergyLevel = 'energy_level';
  static const String _keyCompletedLessons = 'completed_lessons';

  /// Loads the saved state from local storage
  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();

    // Load energy level (default to 0.0 if not found)
    progress.value = prefs.getDouble(_keyEnergyLevel) ?? 0.0;

    // Load completed lessons list
    completedLessons.value = prefs.getStringList(_keyCompletedLessons) ?? [];
  }

  /// Adds progress and marks a lesson as completed.
  /// If [lessonId] is provided, it checks if the lesson was already completed
  /// to avoid double counting.
  Future<void> addProgress(double amount, {String? lessonId}) async {
    final prefs = await SharedPreferences.getInstance();

    // If lesson ID is provided and already completed, do nothing
    if (lessonId != null && completedLessons.value.contains(lessonId)) {
      debugPrint('Lesson $lessonId already completed. No energy added.');
      return;
    }

    // Update energy
    double newValue = progress.value + amount;
    if (newValue > 1.0) newValue = 1.0;
    progress.value = newValue;
    await prefs.setDouble(_keyEnergyLevel, newValue);

    // Update completed lessons list
    if (lessonId != null) {
      final newList = List<String>.from(completedLessons.value);
      newList.add(lessonId);
      completedLessons.value = newList;
      await prefs.setStringList(_keyCompletedLessons, newList);
      debugPrint('Marked lesson $lessonId as completed.');
    }
  }

  /// Repairs progress to [value] and persists (e.g. when derived from completedLessons).
  /// Only updates if [value] is greater than current progress.
  Future<void> repairProgress(double value) async {
    if (value <= progress.value) return;
    final clamped = value > 1.0 ? 1.0 : value;
    progress.value = clamped;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyEnergyLevel, clamped);
  }

  /// Resets progress (useful for testing)
  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    progress.value = 0.0;
    completedLessons.value = [];
    lastDisplayedPercentageForGauge = 0.0;
    await prefs.remove(_keyEnergyLevel);
    await prefs.remove(_keyCompletedLessons);
  }
}
