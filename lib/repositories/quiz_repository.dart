import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/quiz_models.dart';

class QuizRepository {
  // Singleton pattern
  static final QuizRepository _instance = QuizRepository._internal();
  static QuizRepository get instance => _instance;
  QuizRepository._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionId = 'quizQuestions';

  /// Fetches questions from Firestore based on the QuizMode.
  Future<List<QuizQuestion>> getQuestionsByMode(QuizMode mode,
      {String? chapterId}) async {
    try {
      Query query = _firestore.collection(_collectionId);

      switch (mode) {
        case QuizMode.trafficSigns:
          query = query.where('category', isEqualTo: 'traffic_signs');
          break;
        case QuizMode.chapter:
          // Assuming 'general' for now, or could be filtered by chapterId if added to model
          query = query.where('category', isEqualTo: 'general');
          break;
        case QuizMode.random:
          // Fetch all or a subset? For now, fetch all and shuffle client-side
          // Optimization: could limit or use random IDs in future
          break;
        case QuizMode.exam:
          query = query.where('useInExam', isEqualTo: 1);
          break;
      }

      final snapshot = await query.get();
      final questions = <QuizQuestion>[];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          data['id'] = doc.id;
          final q = QuizQuestion.fromMap(Map<String, dynamic>.from(data));
          if (q.options.isNotEmpty && q.text.isNotEmpty) {
            questions.add(q);
          }
        } catch (e) {
          if (kDebugMode) {
            print('QuizRepository: skip invalid doc ${doc.id}: $e');
          }
        }
      }

      if (mode == QuizMode.random) {
        questions.shuffle();
        return questions.take(10).toList();
      } else if (mode == QuizMode.exam) {
        questions.shuffle();
        return questions.take(50).toList();
      }

      return questions;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching quiz questions: $e');
      }
      return [];
    }
  }

  /// One-time seed method to upload hardcoded questions to Firestore.
  /// Call this from main.dart or a debug screen.
  Future<void> seedInitialData() async {
    try {
      final snapshot =
          await _firestore.collection(_collectionId).limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        if (kDebugMode) {
          print('Quiz questions already seeded.');
        }
        return;
      }

      if (kDebugMode) {
        print('Seeding quiz questions...');
      }

      final batch = _firestore.batch();

      // Helper to add to batch
      void addToBatch(List<QuizQuestion> questions, String category) {
        for (var q in questions) {
          final docRef = _firestore.collection(_collectionId).doc(q.id);
          // Create a new map with the correct category overrides
          final data = q.toMap();
          data['category'] = category;
          batch.set(docRef, data);
        }
      }

      addToBatch(_mockTrafficSignQuestions, 'traffic_signs');
      addToBatch(_mockGeneralQuestions, 'general');
      addToBatch(_mockHazardQuestions, 'hazard');

      await batch.commit();
      if (kDebugMode) {
        print('Seeding complete!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error seeding quiz questions: $e');
      }
    }
  }

  // --- Mock Data (Preserved for Seeding) ---

  final List<QuizQuestion> _mockTrafficSignQuestions = [
    const QuizQuestion(
      id: 'ts_1',
      text: 'Wat betekent dit bord?',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Netherlands_traffic_sign_B1.svg/1200px-Netherlands_traffic_sign_B1.svg.png',
      options: ['Voorrangsweg', 'Voorrangskruispunt', 'Einde voorrangsweg'],
      correctOptionIndex: 0,
      explanation:
          'Dit bord (B1) geeft aan dat je op een voorrangsweg rijdt. Bestuurders van zijwegen moeten jou voorrang verlenen.',
      type: QuestionType.multipleChoice,
      category: 'traffic_signs',
      pointsDeductionIfWrong: 1,
      useInExam: 1,
    ),
    const QuizQuestion(
      id: 'ts_2',
      text: 'Mag je hier inhalen?',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/Netherlands_traffic_sign_F1.svg/1200px-Netherlands_traffic_sign_F1.svg.png',
      options: ['Ja', 'Nee', 'Alleen tractoren'],
      correctOptionIndex: 1,
      explanation:
          'Bord F1: Verbod voor motorvoertuigen om elkaar in te halen.',
      type: QuestionType.yesNo,
      category: 'traffic_signs',
      pointsDeductionIfWrong: 1,
      useInExam: 1,
    ),
    const QuizQuestion(
      id: 'ts_3',
      text: 'Wat is de maximumsnelheid na dit bord?',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Netherlands_traffic_sign_A1-50.svg/600px-Netherlands_traffic_sign_A1-50.svg.png',
      options: ['30 km/u', '50 km/u', '80 km/u'],
      correctOptionIndex: 1,
      explanation:
          'Het bord A1 geeft een maximumsnelheid aan, in dit geval 50 km/u.',
      type: QuestionType.multipleChoice,
      category: 'traffic_signs',
      pointsDeductionIfWrong: 5,
      useInExam: 1,
    ),
  ];

  final List<QuizQuestion> _mockGeneralQuestions = [
    const QuizQuestion(
      id: 'gen_1',
      text: 'Wanneer moet je je dimlichten aan doen?',
      options: [
        'Alleen \'s nachts',
        'Bij slecht zicht en in het donker',
        'Alleen als het regent'
      ],
      correctOptionIndex: 1,
      explanation:
          'Je moet dimlicht voeren bij nacht en wanneer het zicht door mist, sneeuwval of regen ernstig wordt belemmerd.',
      type: QuestionType.multipleChoice,
      category: 'general',
      pointsDeductionIfWrong: 1,
      useInExam: 1,
    ),
    const QuizQuestion(
      id: 'gen_2',
      text:
          'Hoeveel alcohol mag een beginnend bestuurder in zijn bloed hebben?',
      options: ['0,2 promille', '0,5 promille', '0,0 promille'],
      correctOptionIndex: 0,
      explanation:
          'Voor beginnende bestuurders (eerste 5 jaar) geldt een limiet van 0,2 promille.',
      type: QuestionType.multipleChoice,
      category: 'general',
      pointsDeductionIfWrong: 1,
      useInExam: 1,
    ),
    const QuizQuestion(
      id: 'gen_3',
      text: 'Mag je met mistachterlicht rijden bij zware regen?',
      options: ['Ja', 'Nee'],
      correctOptionIndex: 1,
      explanation:
          'Nee, mistachterlicht mag ALLEEN bij mist of sneeuwval met zicht minder dan 50 meter. Bij regen verblindt het te veel.',
      type: QuestionType.yesNo,
      category: 'general',
      pointsDeductionIfWrong: 1,
      useInExam: 1,
    ),
  ];

  final List<QuizQuestion> _mockHazardQuestions = [
    const QuizQuestion(
      id: 'haz_1',
      text: 'Wat doe je in deze situatie?',
      imageUrl:
          'https://www.theorietoppers.nl/images/gevaarherkenning-voorbeeld.jpg',
      options: ['Remmen', 'Gas loslaten', 'Niets'],
      correctOptionIndex: 1,
      explanation:
          'Je ziet spelende kinderen op de stoep. Ze rennen nog niet de weg op, maar je moet alert zijn. Gas loslaten is hier de juiste preventieve maatregel.',
      type: QuestionType.hazardPerception,
      category: 'hazard',
      pointsDeductionIfWrong: 1,
      useInExam: 1,
    ),
    const QuizQuestion(
      id: 'haz_2',
      text: 'Er rolt een bal de straat op. Wat doe je?',
      options: ['Remmen', 'Gas loslaten', 'Niets'],
      correctOptionIndex: 0,
      explanation: 'Direct remmen! Waar een bal is, volgt vaak een kind.',
      type: QuestionType.hazardPerception,
      category: 'hazard',
      pointsDeductionIfWrong: 1,
      useInExam: 1,
    ),
  ];
}
