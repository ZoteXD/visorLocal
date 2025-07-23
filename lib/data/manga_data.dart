// lib/data/manga_data.dart
import 'package:flutter/services.dart';

class LocalMangaData {
  static Future<List<Map<String, dynamic>>> loadMangas() async {
    final List<Map<String, dynamic>> mangas = [];
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest.listAssets();

    // Debug: Mostrar todos los assets detectados
    print("=== ASSETS DETECTADOS ===");
    assets.where((a) => a.contains('mangas/')).forEach(print);
    print("=== ESTRUCTURA COMPLETA DE ASSETS ===");
    final allDirs = assets.map((a) => a.split('/')).where((parts) => parts.length >= 3 && parts[1] == 'mangas').toList();
    allDirs.forEach((parts) {
      if (parts.length == 3) print('Manga: ${parts[2]}');
      else if (parts.length >= 4) print('Manga: ${parts[2]} | Capítulo: ${parts[3]}');
    });

    // Obtener carpetas únicas de mangas
    final mangaFolders = assets
      .where((a) => a.startsWith('assets/mangas/'))
      .map((a) => a.split('/')[2])
      .toSet() // Esto ya elimina duplicados
      .toList();

    print("=== CARPETAS DE MANGA ENCONTRADAS ===");
    print(mangaFolders);

    for (final folder in mangaFolders) {
      final mangaPath = 'assets/mangas/$folder';
      final coverImage = await _findCoverImage(mangaPath, manifest);
      
      if (coverImage != null) {
        final chapters = await _discoverChapters(mangaPath, folder, manifest);
        
        mangas.add({
          'id': folder.toLowerCase().replaceAll(' ', '_'),
          'title': _formatTitle(folder),
          'cover': coverImage,
          'isFeatured': false,
          'lastRead': null,
          'progress': 0.0,
          'chapters': chapters,
        });
      }
    }

    return mangas;
  }

  static Future<String?> _findCoverImage(String mangaPath, AssetManifest manifest) async {
  final coverNames = ['cover.jpg', 'cover.png', 'portada.jpg'];
  for (final cover in coverNames) {
    final coverPath = '$mangaPath/$cover'; // Ahora busca en manga_path/cover.jpg
    if (manifest.listAssets().contains(coverPath)) {
      return coverPath;
    }
  }
  return null;
}

  static Future<List<Map<String, dynamic>>> _discoverChapters(
  String mangaPath, 
  String folder,
  AssetManifest manifest
) async {
  final List<Map<String, dynamic>> chapters = [];
  final assets = manifest.listAssets();

  // 1. Detectar todas las carpetas de capítulos (c1, ch1, etc.)
  final chapterFolders = assets
      .where((a) => a.startsWith('$mangaPath/'))
      .map((a) => a.split('/'))
      .where((parts) => parts.length > 3) // Ignora archivos en raíz (como cover.jpg)
      .map((parts) => parts[3]) // Nombre de la carpeta del capítulo
      .toSet() // Elimina duplicados
      .toList();

  print("=== CAPÍTULOS DETECTADOS EN $mangaPath ===");
  print(chapterFolders);

  for (final chapter in chapterFolders) {
    final chapterPath = '$mangaPath/$chapter';
    
    // 2. Obtener todas las páginas del capítulo (archivos numerados)
    final pageAssets = assets
        .where((a) => a.startsWith('$chapterPath/'))
        .where((a) => RegExp(r'\/\d+\.(jpg|png|webp)$').hasMatch(a)) // Solo imágenes numeradas
        .toList();

    print("=== PÁGINAS EN $chapterPath ===");
    print(pageAssets);

    if (pageAssets.isNotEmpty) {
      // 3. Ordenar las páginas numéricamente (1.jpg, 2.jpg, etc.)
      pageAssets.sort((a, b) {
        final aNum = int.tryParse(a.split('/').last.split('.').first) ?? 0;
        final bNum = int.tryParse(b.split('/').last.split('.').first) ?? 0;
        return aNum.compareTo(bNum);
      });

      chapters.add({
        'id': chapter.toLowerCase().replaceAll(' ', '_'),
        'title': _formatChapterTitle(chapter),
        'pageCount': pageAssets.length,
        'images': pageAssets, // Usamos las rutas reales encontradas
      });
    }
  }

  // 4. Ordenar capítulos numéricamente
  chapters.sort((a, b) {
  final aNum = int.tryParse(a['title'].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  final bNum = int.tryParse(b['title'].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  return aNum.compareTo(bNum);
});

  return chapters;
}

  static Future<int> _countPages(String chapterPath, AssetManifest manifest) async {
    return manifest.listAssets()
        .where((a) => a.startsWith('$chapterPath/'))
        .length;
  }

  static String _formatTitle(String folderName) {
    return folderName
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  static String _formatChapterTitle(String chapterName) {
    final number = chapterName.replaceAll(RegExp(r'[^0-9]'), '');
    return 'Capítulo ${number.isNotEmpty ? number : chapterName}';
  }

  static List<String> _generateImagePaths(String manga, String chapter, int count) {
    return List.generate(count, (index) {
      final pageNumber = (index + 1).toString();
      return 'assets/mangas/$manga/$chapter/$pageNumber.png';
    });
  }

  static Future<void> markAsFeatured(String mangaId, bool featured) async {
    final mangas = await loadMangas();
    final manga = mangas.firstWhere((m) => m['id'] == mangaId);
    manga['isFeatured'] = featured;
    // Aquí deberías guardar estos cambios (usando SharedPreferences o similar)
  }

  static Future<void> saveReadingProgress(String mangaId, String chapterId, double progress) async {
    final mangas = await loadMangas();
    final manga = mangas.firstWhere((m) => m['id'] == mangaId);
    manga['lastRead'] = {
      'chapterId': chapterId,
      'progress': progress,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    };
    // Guardar estos cambios
  }

}