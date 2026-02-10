import '../models/quiz_models.dart';

class QuizRepository {
  // Singleton pattern
  static final QuizRepository _instance = QuizRepository._internal();
  static QuizRepository get instance => _instance;
  QuizRepository._internal();

  Future<List<QuizQuestion>> getQuestionsByMode(QuizMode mode, {String? chapterId}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    switch (mode) {
      case QuizMode.trafficSigns:
        return _mockTrafficSignQuestions;
      case QuizMode.chapter:
        // In a real app, filter by chapterId. For now, return generic questions.
        return _mockGeneralQuestions;
      case QuizMode.random:
        // Combine all and shuffle
        final all = [..._mockTrafficSignQuestions, ..._mockGeneralQuestions, ..._mockHazardQuestions];
        all.shuffle();
        return all.take(10).toList();
      case QuizMode.exam:
         // Exam structure: 25 hazard, 12 knowledge, 28 insight (example)
         // For mock, just return a mix
        final all = [..._mockHazardQuestions, ..._mockTrafficSignQuestions, ..._mockGeneralQuestions];
        return all.take(20).toList();
    }
  }

  // --- Mock Data ---

  final List<QuizQuestion> _mockTrafficSignQuestions = [
    const QuizQuestion(
      id: 'ts_1',
      text: 'Wat betekent dit bord?',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Netherlands_traffic_sign_B1.svg/1200px-Netherlands_traffic_sign_B1.svg.png', // Voorrangsweg
      options: ['Voorrangsweg', 'Voorrangskruispunt', 'Einde voorrangsweg'],
      correctOptionIndex: 0,
      explanation: 'Dit bord (B1) geeft aan dat je op een voorrangsweg rijdt. Bestuurders van zijwegen moeten jou voorrang verlenen.',
      type: QuestionType.multipleChoice,
    ),
    const QuizQuestion(
      id: 'ts_2',
      text: 'Mag je hier inhalen?',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/Netherlands_traffic_sign_F1.svg/1200px-Netherlands_traffic_sign_F1.svg.png', // Verbod motorvoertuigen in te halen
      options: ['Ja', 'Nee', 'Alleen tractoren'],
      correctOptionIndex: 1,
      explanation: 'Bord F1: Verbod voor motorvoertuigen om elkaar in te halen.',
      type: QuestionType.yesNo,
    ),
    const QuizQuestion(
      id: 'ts_3',
      text: 'Wat is de maximumsnelheid na dit bord?',
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Netherlands_traffic_sign_A1-50.svg/600px-Netherlands_traffic_sign_A1-50.svg.png',
      options: ['30 km/u', '50 km/u', '80 km/u'],
      correctOptionIndex: 1,
      explanation: 'Het bord A1 geeft een maximumsnelheid aan, in dit geval 50 km/u.',
      type: QuestionType.multipleChoice,
    ),
  ];

  final List<QuizQuestion> _mockGeneralQuestions = [
    const QuizQuestion(
      id: 'gen_1',
      text: 'Wanneer moet je je dimlichten aan doen?',
      options: ['Alleen \'s nachts', 'Bij slecht zicht en in het donker', 'Alleen als het regent'],
      correctOptionIndex: 1,
      explanation: 'Je moet dimlicht voeren bij nacht en wanneer het zicht door mist, sneeuwval of regen ernstig wordt belemmerd.',
      type: QuestionType.multipleChoice,
    ),
    const QuizQuestion(
      id: 'gen_2',
      text: 'Hoeveel alcohol mag een beginnend bestuurder in zijn bloed hebben?',
      options: ['0,2 promille', '0,5 promille', '0,0 promille'],
      correctOptionIndex: 0,
      explanation: 'Voor beginnende bestuurders (eerste 5 jaar) geldt een limiet van 0,2 promille.',
      type: QuestionType.multipleChoice,
    ),
    const QuizQuestion(
      id: 'gen_3',
      text: 'Mag je met mistachterlicht rijden bij zware regen?',
      options: ['Ja', 'Nee'],
      correctOptionIndex: 1,
      explanation: 'Nee, mistachterlicht mag ALLEEN bij mist of sneeuwval met zicht minder dan 50 meter. Bij regen verblindt het te veel.',
      type: QuestionType.yesNo,
    ),
  ];

  final List<QuizQuestion> _mockHazardQuestions = [
    const QuizQuestion(
      id: 'haz_1',
      text: 'Wat doe je in deze situatie?',
      imageUrl: 'https://www.theorietoppers.nl/images/gevaarherkenning-voorbeeld.jpg', // Placeholder
      options: ['Remmen', 'Gas loslaten', 'Niets'],
      correctOptionIndex: 1,
      explanation: 'Je ziet spelende kinderen op de stoep. Ze rennen nog niet de weg op, maar je moet alert zijn. Gas loslaten is hier de juiste preventieve maatregel.',
      type: QuestionType.hazardPerception,
    ),
    const QuizQuestion(
      id: 'haz_2',
      text: 'Er rolt een bal de straat op. Wat doe je?',
      options: ['Remmen', 'Gas loslaten', 'Niets'],
      correctOptionIndex: 0,
      explanation: 'Direct remmen! Waar een bal is, volgt vaak een kind.',
      type: QuestionType.hazardPerception,
    ),
  ];
}
