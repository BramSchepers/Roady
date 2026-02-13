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
  /// Aantal geslaagde examens (voor beker op fuel dashboard).
  final ValueNotifier<int> passedExamsCount = ValueNotifier<int>(0);

  /// True als er op het dashboard iets nieuws is (fuel omhoog of nieuwe beker) dat de gebruiker nog niet heeft gezien.
  final ValueNotifier<bool> hasUnseenDashboardUpdates = ValueNotifier<bool>(false);

  /// Laatst getoonde waarde op de fuel-gauge (bij verlaten home). Wordt gebruikt
  /// om de vul-animatie te starten wanneer de gebruiker terug naar home gaat.
  double lastDisplayedPercentageForGauge = 0.0;

  // Keys for SharedPreferences
  static const String _keyEnergyLevel = 'energy_level';
  static const String _keyCompletedLessons = 'completed_lessons';
  static const String _keyPendingViewedLessonId = 'pending_viewed_lesson_id';
  static const String _keyPassedExamsCount = 'passed_exams_count';

  /// Loads the saved state from local storage.
  /// Als er een pending viewed lesson is (app werd gesloten terwijl les open stond), die nu markeren.
  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();

    progress.value = prefs.getDouble(_keyEnergyLevel) ?? 0.0;
    completedLessons.value = prefs.getStringList(_keyCompletedLessons) ?? [];
    passedExamsCount.value = prefs.getInt(_keyPassedExamsCount) ?? 0;

    final pendingId = prefs.getString(_keyPendingViewedLessonId);
    if (pendingId != null && pendingId.isNotEmpty) {
      await prefs.remove(_keyPendingViewedLessonId);
      await addProgress(0.0, lessonId: pendingId);
    }
  }

  /// Opslaan welke les open stond (voor als app wordt gesloten/killed).
  Future<void> savePendingViewedLessonId(String lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPendingViewedLessonId, lessonId);
  }

  /// Clearen bij normaal sluiten player (X of back).
  Future<void> clearPendingViewedLessonId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPendingViewedLessonId);
  }

  /// Adds progress and marks a lesson as completed.
  /// If [lessonId] is provided, adds it to the list (en notificeert UI). Energie alleen bij als les nog niet voltooid was.
  Future<void> addProgress(double amount, {String? lessonId}) async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyCompleted = lessonId != null && completedLessons.value.contains(lessonId);

    // Energie alleen toevoegen als les nog niet voltooid (geen dubbele telling)
    if (!alreadyCompleted) {
      double newValue = progress.value + amount;
      if (newValue > 1.0) newValue = 1.0;
      progress.value = newValue;
      hasUnseenDashboardUpdates.value = true; // Fuel omhoog → toon badge op huis-icoon
      await prefs.setDouble(_keyEnergyLevel, newValue);
    } else {
      debugPrint('Lesson $lessonId already completed. No energy added.');
    }

    // Lijst altijd bijwerken en notifier zetten zodat UI (vinkjes) ververst
    if (lessonId != null) {
      final newList = List<String>.from(completedLessons.value);
      if (!newList.contains(lessonId)) {
        newList.add(lessonId);
        debugPrint('Marked lesson $lessonId as completed.');
      }
      completedLessons.value = newList;
      await prefs.setStringList(_keyCompletedLessons, newList);
    }
  }

  /// Repairs progress to [value] and persists (e.g. when derived from completedLessons).
  /// Only updates if [value] is greater than current progress.
  Future<void> repairProgress(double value) async {
    if (value <= progress.value) return;
    final clamped = value > 1.0 ? 1.0 : value;
    progress.value = clamped;
    hasUnseenDashboardUpdates.value = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyEnergyLevel, clamped);
  }

  /// Verhoogt het aantal geslaagde examens met 1 en slaat op (bij geslaagd examen).
  Future<void> incrementPassedExams() async {
    final prefs = await SharedPreferences.getInstance();
    final newCount = passedExamsCount.value + 1;
    passedExamsCount.value = newCount;
    hasUnseenDashboardUpdates.value = true; // Nieuwe beker → toon badge op huis-icoon
    await prefs.setInt(_keyPassedExamsCount, newCount);
  }

  /// Cleart de "onbezochte dashboard-updates" vlag (aanroepen wanneer gebruiker home/dashboard opent).
  void clearUnseenDashboardUpdates() {
    hasUnseenDashboardUpdates.value = false;
  }

  /// Resets progress (useful for testing). Behouden aantal geslaagde examens niet gereset.
  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    progress.value = 0.0;
    completedLessons.value = [];
    lastDisplayedPercentageForGauge = 0.0;
    await prefs.remove(_keyEnergyLevel);
    await prefs.remove(_keyCompletedLessons);
    await prefs.remove(_keyPendingViewedLessonId);
  }
}
