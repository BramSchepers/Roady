// --- Data Models ---

class TheoryLesson {
  final String id;
  final String lottieAsset;
  final Map<String, dynamic> content;

  TheoryLesson({
    required this.id,
    required this.lottieAsset,
    required this.content,
  });

  String getTitle(String lang) =>
      content[lang]?['title'] ?? content['nl']['title'];
  String getDescription(String lang) =>
      content[lang]?['description'] ?? content['nl']['description'];
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
}

// --- Dummy Data ---

final List<TheoryChapter> dummyChapters = [
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
