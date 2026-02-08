// --- Data Models ---

class TheoryLesson {
  final String id;
  final String lottieAsset;
  final Map<String, dynamic> content;
  final String? imageUrl;

  TheoryLesson({
    required this.id,
    required this.lottieAsset,
    required this.content,
    this.imageUrl,
  });

  String getTitle(String lang) =>
      content[lang]?['title'] ?? content['nl']['title'];
  String getDescription(String lang) =>
      content[lang]?['description'] ?? content['nl']['description'];

  /// From Firestore (or any Map). [map] may be from a document field.
  static TheoryLesson fromMap(Map<String, dynamic> map) {
    final contentRaw = map['content'];
    Map<String, dynamic> content = {};
    if (contentRaw is Map) {
      for (final e in contentRaw.entries) {
        if (e.value is Map) {
          content[e.key.toString()] =
              Map<String, dynamic>.from(e.value as Map);
        }
      }
    }
    return TheoryLesson(
      id: map['id'] as String? ?? '',
      lottieAsset:
          map['lottieAsset'] as String? ?? 'assets/lottie/car.lottie',
      content: content.isNotEmpty
          ? content
          : {'nl': {'title': '', 'description': ''}},
      imageUrl: map['imageUrl'] as String?,
    );
  }
}

class TheoryChapter {
  final String id;
  final Map<String, String> title;
  final String imageUrl; // Asset path for the chapter cover
  final List<TheoryLesson> lessons;

  TheoryChapter({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.lessons,
  });

  String getTitle(String lang) => title[lang] ?? title['nl']!;

  /// From Firestore document (or any Map).
  static TheoryChapter fromMap(Map<String, dynamic> map) {
    final titleRaw = map['title'];
    Map<String, String> titleMap = {};
    if (titleRaw is Map) {
      for (final e in titleRaw.entries) {
        titleMap[e.key.toString()] = e.value?.toString() ?? '';
      }
    }
    if (titleMap.isEmpty) titleMap['nl'] = '';

    final lessonsRaw = map['lessons'];
    List<TheoryLesson> lessonsList = [];
    if (lessonsRaw is List) {
      for (final item in lessonsRaw) {
        if (item is Map) {
          lessonsList
              .add(TheoryLesson.fromMap(Map<String, dynamic>.from(item)));
        }
      }
    }

    return TheoryChapter(
      id: map['id'] as String? ?? '',
      title: titleMap,
      imageUrl: map['imageUrl'] as String? ?? 'assets/illustrations/Background_hero.svg',
      lessons: lessonsList,
    );
  }
}

// --- Dummy Data ---

final List<TheoryChapter> dummyChapters = [
  TheoryChapter(
    id: 'chapter_00',
    title: {
      'nl': 'Inleiding',
      'fr': 'Introduction',
      'en': 'Introduction',
    },
    imageUrl: 'assets/illustrations/Background_hero.svg',
    lessons: [
      TheoryLesson(
        id: 'lesson_00_01',
        lottieAsset: 'assets/lottie/car.lottie',
        content: {
          'nl': {
            'title': 'Over het examen',
            'description':
                'Het theorie-examen is verplicht voor je rijbewijs B (auto). Je legt het af vóór je praktijkexamen; het toetst of je de verkeersregels kent en situaties goed inschat.\n\n'
                'Het examen is meerkeuze: je krijgt een aantal vragen met meerdere antwoordmogelijkheden. Er zijn vragen met alleen tekst en vragen met afbeeldingen (verkeerssituaties, borden). Het aantal vragen, de duur en het maximaal toegelaten aantal fouten zijn in België vastgelegd; informeer bij je examencentrum voor de actuele cijfers.\n\n'
                'Het examen wordt afgenomen in een erkend examencentrum, op de computer. Of het (deels) online kan of alleen op locatie, hangt af van het centrum en de regeling — check dit bij je inschrijving.',
          },
          'fr': {
            'title': "À propos de l'examen",
            'description':
                "L'examen théorique est obligatoire pour le permis B (voiture). Vous le passez avant l'examen pratique; il vérifie que vous connaissez le code de la route et évaluez bien les situations.\n\n"
                "L'examen est à choix multiples : un certain nombre de questions avec plusieurs réponses. Il y a des questions avec du texte et des questions avec des images (situations, panneaux). Le nombre de questions, la durée et le nombre maximum d'erreurs autorisées sont fixés en Belgique; renseignez-vous auprès de votre centre pour les chiffres actuels.\n\n"
                "L'examen a lieu dans un centre agréé, sur ordinateur. S'il peut (en partie) se faire en ligne ou uniquement sur place dépend du centre — vérifiez lors de l'inscription.",
          },
          'en': {
            'title': 'About the exam',
            'description':
                'The theory exam is mandatory for your category B (car) licence. You take it before the practical test; it checks that you know the traffic rules and can assess situations correctly.\n\n'
                'The exam is multiple choice: you get a set number of questions with several answer options. There are text-only questions and questions with images (traffic situations, signs). The number of questions, duration and maximum allowed errors are set in Belgium; check with your exam centre for current figures.\n\n'
                'The exam is taken at an approved exam centre, on computer. Whether it can (partly) be done online or only on-site depends on the centre — check when booking.',
          },
        },
      ),
      TheoryLesson(
        id: 'lesson_00_02',
        lottieAsset: 'assets/lottie/car.lottie',
        content: {
          'nl': {
            'title': 'Voorbereiding',
            'description':
                'Waarom eerst theorie? Omdat je tijdens de rijlessen en het praktijkexamen moet toepassen wat je hier leert: voorrang, snelheid, borden, gedrag. Theorie en praktijk horen bij elkaar.\n\n'
                'Deze app helpt je door de theorie per onderwerp aan te bieden (lessen per hoofdstuk) en daarna te oefenen met quizzen. Zo zie je of je klaar bent voor het echte examen.\n\n'
                'Tip: leer niet alleen uit het hoofd. Probeer de regels te begrijpen — vooral bij voorrang en situaties. Als je begrijpt waaróm iets zo is, onthoud je het beter en maak je minder fouten.',
          },
          'fr': {
            'title': 'Préparation',
            'description':
                "Pourquoi d'abord la théorie? Parce qu'en leçon et à l'examen pratique vous devrez appliquer ce que vous apprenez ici : priorité, vitesse, panneaux, comportement. Théorie et pratique vont de pair.\n\n"
                "Cette app vous aide en proposant la théorie par thème (leçons par chapitre) puis des quiz pour vous entraîner. Vous saurez si vous êtes prêt pour l'examen.\n\n"
                "Conseil : ne mémorisez pas bêtement. Comprenez les règles — surtout pour la priorité et les situations. Comprendre le « pourquoi » aide à retenir et à faire moins d'erreurs.",
          },
          'en': {
            'title': 'Preparation',
            'description':
                'Why theory first? Because during lessons and the practical test you will need to apply what you learn here: priority, speed, signs, behaviour. Theory and practice go together.\n\n'
                'This app helps by offering the theory by topic (lessons per chapter) and then quizzes to practise. You will see if you are ready for the real exam.\n\n'
                'Tip: don\'t just memorise. Try to understand the rules — especially for right of way and situations. Understanding why something is so helps you remember and make fewer mistakes.',
          },
        },
      ),
      TheoryLesson(
        id: 'lesson_00_03',
        lottieAsset: 'assets/lottie/car.lottie',
        content: {
          'nl': {
            'title': 'Examenstrategie',
            'description':
                'Lees elke vraag rustig en volledig voordat je antwoordt. Gok niet zonder te lezen: een verkeerd antwoord telt mee.\n\n'
                'Kijk goed naar de afbeeldingen. Bij vragen met een tekening of foto: welke borden zie je? Wie heeft voorrang? Wat is de situatie? Een detail kan het juiste antwoord bepalen.\n\n'
                'Gebruik de tijd goed: niet te snel doorheen jagen, maar wel doorwerken zodat je alle vragen beantwoordt. Blijf bij twijfel uitgaan van wat je in de theorie hebt geleerd.',
          },
          'fr': {
            'title': "Stratégie à l'examen",
            'description':
                "Lisez chaque question calmement et en entier avant de répondre. Ne devinez pas sans lire : une mauvaise réponse compte.\n\n"
                "Regardez bien les images. Pour les questions avec un dessin ou une photo : quels panneaux voyez-vous? Qui a la priorité? Quelle est la situation? Un détail peut changer la bonne réponse.\n\n"
                "Utilisez bien le temps : ne vous précipitez pas, mais avancez pour répondre à toutes les questions. En cas de doute, fiez-vous à ce que vous avez appris dans la théorie.",
          },
          'en': {
            'title': 'Exam strategy',
            'description':
                'Read each question calmly and fully before answering. Don\'t guess without reading: a wrong answer counts.\n\n'
                'Look carefully at any images. For questions with a drawing or photo: which signs do you see? Who has priority? What is the situation? A detail can determine the correct answer.\n\n'
                'Use the time well: don\'t rush, but keep going so you answer all questions. When in doubt, rely on what you learned in the theory.',
          },
        },
      ),
      TheoryLesson(
        id: 'lesson_00_04',
        lottieAsset: 'assets/lottie/car.lottie',
        content: {
          'nl': {
            'title': 'Na het examen',
            'description':
                'Geslaagd? Gefeliciteerd! Je attest is een bepaalde tijd geldig (in België vaak tot 3 jaar voor het afleggen van het praktijkexamen — informeer bij je examencentrum). Volgende stappen: start met rijlessen en schrijf je in voor het praktijkexamen wanneer je er klaar voor bent.\n\n'
                'Niet geslaagd? Geen paniek. Kijk welke onderwerpen je fout had en oefen die opnieuw in de theorie en met quizzen. Je kunt je opnieuw inschrijven voor het theorie-examen; informeer bij het centrum wanneer dat kan en of er wachttijd is. Bij te veel fouten is het vooral belangrijk om die onderwerpen grondig te herhalen voordat je opnieuw gaat.',
          },
          'fr': {
            'title': "Après l'examen",
            'description':
                "Réussi? Félicitations! Votre attestation reste valable un certain temps (souvent jusqu'à 3 ans en Belgique pour passer l'examen pratique — renseignez-vous au centre). Prochaines étapes : commencez les leçons de conduite et inscrivez-vous à l'examen pratique quand vous êtes prêt.\n\n"
                "Échoué? Pas de panique. Identifiez les thèmes où vous avez fait des erreurs et retravaillez-les avec la théorie et les quiz. Vous pouvez vous réinscrire à l'examen théorique; renseignez-vous sur les délais. En cas de trop d'erreurs, reprenez ces thèmes en profondeur avant de repasser.",
          },
          'en': {
            'title': 'After the exam',
            'description':
                'Passed? Congratulations! Your certificate is valid for a certain period (often up to 3 years in Belgium to take the practical test — check with your centre). Next steps: start driving lessons and register for the practical exam when you are ready.\n\n'
                'Failed? Don\'t panic. See which topics you got wrong and practise them again with the theory and quizzes. You can rebook the theory exam; check with the centre when you can and if there is a waiting period. If you had too many errors, focus on revising those topics thoroughly before trying again.',
          },
        },
      ),
      TheoryLesson(
        id: 'lesson_00_05',
        lottieAsset: 'assets/lottie/car.lottie',
        content: {
          'nl': {
            'title': 'Over de wegcode in deze app',
            'description':
                'We focussen op wat je nodig hebt om te slagen voor het meerkeuze-examen. Dat betekent niet dat we elke regel uit de wegcode tot in de puntjes behandelen — we geven je de kennis die het vaakst terugkomt en die je moet begrijpen om de vragen goed te beantwoorden.\n\n'
                'Overzicht van de hoofdstukken in deze app: Inleiding (hier), Voorrangsregels, Snelheid, Verkeersborden, en later meer. Werk de lessen per hoofdstuk af en test jezelf daarna met de quiz. Zo bouw je stap voor stap de kennis op die je nodig hebt.',
          },
          'fr': {
            'title': "Le code de la route dans cette app",
            'description':
                "Nous nous concentrons sur ce dont vous avez besoin pour réussir l'examen à choix multiples. Nous ne traitons pas chaque règle du code dans les moindres détails — nous vous donnons les connaissances qui reviennent le plus et qu'il faut comprendre pour bien répondre.\n\n"
                "Aperçu des chapitres : Introduction (ici), règles de priorité, vitesse, panneaux, et d'autres à venir. Parcourez les leçons par chapitre puis testez-vous avec le quiz. Vous construisez ainsi progressivement les connaissances nécessaires.",
          },
          'en': {
            'title': 'The road code in this app',
            'description':
                'We focus on what you need to pass the multiple-choice exam. That does not mean covering every rule in the road code in full — we give you the knowledge that comes up most often and that you need to understand to answer the questions correctly.\n\n'
                'Overview of the chapters in this app: Introduction (here), right of way, speed, traffic signs, and more to come. Work through the lessons per chapter and then test yourself with the quiz. That way you build up the knowledge you need step by step.',
          },
        },
      ),
    ],
  ),
  TheoryChapter(
    id: 'chapter_01',
    title: {
      'nl': '1. Voorrangsregels',
      'fr': '1. Règles de Priorité',
      'en': '1. Right of Way Rules',
    },
    imageUrl:
        'assets/illustrations/Background_hero.svg', // Using existing asset as placeholder
    lessons: [
      TheoryLesson(
        id: 'lesson_01_01',
        lottieAsset: 'assets/lottie/car.lottie',
        content: {
          'nl': {
            'title': 'Voorrang van Rechts',
            'description':
                'Op een gelijkwaardig kruispunt (zonder borden of lichten) heeft de bestuurder die van rechts komt altijd voorrang. Dit geldt voor alle voertuigen, inclusief fietsers.',
          },
          'fr': {
            'title': 'Priorité de Droite',
            'description':
                'À une intersection équivalente (sans panneaux ni feux), le conducteur venant de droite a toujours la priorité. Cela s\'applique à tous les véhicules, y compris les cyclistes.',
          },
          'en': {
            'title': 'Right of Way',
            'description':
                'At an equivalent intersection (without signs or lights), the driver coming from the right always has priority. This applies to all vehicles, including cyclists.',
          },
        },
      ),
      TheoryLesson(
        id: 'lesson_01_02',
        lottieAsset: 'assets/lottie/car.lottie',
        content: {
          'nl': {
            'title': 'Stopbord',
            'description':
                'Bij een stopbord moet je volledig tot stilstand komen. Je moet voorrang verlenen aan alle bestuurders op de kruisende weg. Pas als de weg vrij is, mag je verder rijden.',
          },
          'fr': {
            'title': 'Panneau Stop',
            'description':
                'À un panneau stop, vous devez vous arrêter complètement. Vous devez céder la priorité à tous les conducteurs sur la route transversale. Vous ne pouvez continuer que lorsque la voie est libre.',
          },
          'en': {
            'title': 'Stop Sign',
            'description':
                'At a stop sign, you must come to a complete stop. You must yield to all drivers on the intersecting road. You may only proceed when the road is clear.',
          },
        },
      ),
    ],
  ),
  TheoryChapter(
    id: 'chapter_02',
    title: {
      'nl': '2. Snelheid',
      'fr': '2. Vitesse',
      'en': '2. Speed',
    },
    imageUrl: 'assets/illustrations/Background_hero.svg',
    lessons: [
      TheoryLesson(
        id: 'lesson_02_01',
        lottieAsset: 'assets/lottie/car.lottie',
        content: {
          'nl': {
            'title': 'Binnen de Bebouwde Kom',
            'description':
                'Binnen de bebouwde kom mag je maximaal 50 km/u, tenzij anders aangegeven (bijv. zone 30).',
          },
          'fr': {
            'title': 'En Agglomération',
            'description':
                'En agglomération, la vitesse est limitée à 50 km/h, sauf indication contraire (ex. zone 30).',
          },
          'en': {
            'title': 'Inside Built-up Areas',
            'description':
                'Inside built-up areas, the limit is 50 km/h, unless otherwise indicated (e.g., zone 30).',
          },
        },
      ),
      TheoryLesson(
        id: 'lesson_02_02',
        lottieAsset: 'assets/lottie/car.lottie',
        content: {
          'nl': {
            'title': 'Snelwegen',
            'description':
                'Op snelwegen is de minimumsnelheid 70 km/u en de maximumsnelheid 120 km/u.',
          },
          'fr': {
            'title': 'Autoroutes',
            'description':
                'Sur les autoroutes, la vitesse minimale est de 70 km/h et la maximale de 120 km/h.',
          },
          'en': {
            'title': 'Highways',
            'description':
                'On highways, the minimum speed is 70 km/h and the maximum speed is 120 km/h.',
          },
        },
      ),
    ],
  ),
  TheoryChapter(
    id: 'chapter_03',
    title: {
      'nl': '3. Verkeersborden',
      'fr': '3. Panneaux de Signalisation',
      'en': '3. Traffic Signs',
    },
    imageUrl: 'assets/illustrations/Background_hero.svg',
    lessons: [
      TheoryLesson(
        id: 'lesson_03_01',
        lottieAsset: 'assets/lottie/car.lottie',
        content: {
          'nl': {
            'title': 'Gevaarsborden',
            'description':
                'Driehoekige borden met een rode rand waarschuwen voor gevaar. Ze staan meestal 150m voor het gevaarlijke punt.',
          },
          'fr': {
            'title': 'Panneaux de Danger',
            'description':
                'Les panneaux triangulaires à bord rouge avertissent d\'un danger. Ils sont généralement placés 150m avant le point dangereux.',
          },
          'en': {
            'title': 'Warning Signs',
            'description':
                'Triangular signs with a red border warn of danger. They are usually placed 150m before the dangerous point.',
          },
        },
      ),
    ],
  ),
];
