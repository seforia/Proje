class SubjectTopic {
  final String id;
  final String name;
  final String icon;
  final int order;
  final List<String> topics;

  SubjectTopic({
    required this.id,
    required this.name,
    required this.icon,
    required this.order,
    required this.topics,
  });

  static List<SubjectTopic> getDefaultSubjects() {
    return [
      SubjectTopic(
        id: 'matematik',
        name: 'Matematik',
        icon: '🔢',
        order: 1,
        topics: [
          'Toplama',
          'Çıkarma',
          'Çarpım Tablosu',
          'Bölme',
          'Kesirler',
          'Geometri',
          'Ölçme',
        ],
      ),
      SubjectTopic(
        id: 'fen',
        name: 'Fen Bilgisi',
        icon: '🔬',
        order: 2,
        topics: [
          'Canlılar ve Yaşam',
          'Hayvanlar',
          'Bitkiler',
          'İnsan Vücudu',
          'Madde ve Değişim',
          'Dünya ve Evren',
          'Enerji',
        ],
      ),
      SubjectTopic(
        id: 'turkce',
        name: 'Türkçe',
        icon: '📚',
        order: 3,
        topics: [
          'Alfabe',
          'Sesler ve Harfler',
          'Kelime Türleri',
          'Cümleler',
          'Okuma',
          'Yazım Kuralları',
        ],
      ),
      SubjectTopic(
        id: 'ingilizce',
        name: 'İngilizce',
        icon: '🌍',
        order: 4,
        topics: [
          'Alfabe',
          'Sayılar',
          'Renkler',
          'Hayvanlar',
          'Aile',
          'Yiyecekler',
          'Fiiller',
        ],
      ),
      SubjectTopic(
        id: 'sosyal',
        name: 'Sosyal Bilgiler',
        icon: '🌎',
        order: 5,
        topics: [
          'Coğrafya',
          'Tarih',
          'Atatürk',
          'Haritalar',
          'Kültür',
          'Toplum',
        ],
      ),
    ];
  }
}
