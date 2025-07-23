// lib/services/local_manga_data.dart
class LocalMangaData {
  static Future<List<Map<String, dynamic>>> loadMangas() async {
    // Datos de ejemplo - reemplaza con tus datos reales
    return [
      {
        'id': 'ririsa',
        'title': '2.5D Ririsa',
        'cover': 'assets/mangas/ririsa/cover.jpg',
        'isFeatured': true,
        'chapters': [
          {
            'id': 'c1',
            'title': 'Capítulo 1',
            'pageCount': 53,
            'images': List.generate(53, (i) => 'assets/mangas/ririsa/c1/${i+1}.jpg')
          },
          {
            'id': 'c2',
            'title': 'Capítulo 2',
            'pageCount': 22,
            'images': List.generate(22, (i) => 'assets/mangas/ririsa/c2/${i+1}.jpg')
          }
        ]
      },
      {
        'id': '100n',
        'title': '100 Novias',
        'cover': 'assets/mangas/100n/cover.jpg',
        'isFeatured': true,
        'chapters': [
          {
            'id': 'c168',
            'title': 'Capítulo 168',
            'pageCount': 53,
            'images': List.generate(53, (i) => 'assets/mangas/100n/c168/${i+1}.jpg')
          },
          {
            'id': 'c169',
            'title': 'Capítulo 169',
            'pageCount': 22,
            'images': List.generate(22, (i) => 'assets/mangas/100n/c169/${i+1}.jpg')
          }
        ]
      },
      {
        'id': 'sono',
        'title': 'Sono',
        'cover': 'assets/mangas/sono/cover.jpg',
        'isFeatured': false,
        'chapters': [
          {
            'id': 'c1',
            'title': 'Primer Capítulo',
            'pageCount': 53,
            'images': List.generate(53, (i) => 'assets/mangas/sono/c1/${i+1}.jpg')
          }
        ]
      },
      {
        'id': 'medalist',
        'title': 'Medalist',
        'cover': 'assets/mangas/medalist/cover.jpg',
        'isFeatured': false,
        'chapters': [
          {
            'id': 'c1',
            'title': 'Primer Capítulo',
            'pageCount': 53,
            'images': List.generate(53, (i) => 'assets/mangas/medalist/c1/${i+1}.jpg')
          }
        ]
      },
      {
        'id': 'oshino',
        'title': 'Oshi no ko',
        'cover': 'assets/mangas/oshino/cover.jpg',
        'isFeatured': true,
        'chapters': [
          {
            'id': 'c1',
            'title': 'Primer Capítulo',
            'pageCount': 53,
            'images': List.generate(53, (i) => 'assets/mangas/oshino/c1/${i+1}.jpg')
          }
        ]
      },
      {
        'id': 'komi',
        'title': 'Komi san',
        'cover': 'assets/mangas/komi/cover.jpg',
        'isFeatured': false,
        'chapters': [
          {
            'id': 'c1',
            'title': 'Primer Capítulo',
            'pageCount': 53,
            'images': List.generate(53, (i) => 'assets/mangas/komi/c1/${i+1}.jpg')
          }
        ]
      },
      {
        'id': 'rent',
        'title': 'Rent a girlfriend',
        'isFeatured': false,
        'chapters': [
          {
            'id': 'c1',
            'title': 'Primer Capítulo',
            'pageCount': 53,
            'images': List.generate(53, (i) => 'assets/mangas/rent/c1/${i+1}.jpg')
          }
        ]
      },
      {
        'id': 'saneka',
        'title': 'My marriage with Saneka',
        'cover': 'assets/mangas/saneka/cover.jpg',
        'isFeatured': false,
        'chapters': [
          {
            'id': 'c1',
            'title': 'Primer Capítulo',
            'pageCount': 53,
            'images': List.generate(53, (i) => 'assets/mangas/saneka/c1/${i+1}.jpg')
          }
        ]
      },
    ];
  }
}