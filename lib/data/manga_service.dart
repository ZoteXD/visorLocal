// lib/services/manga_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'local_manga_data.dart'; // Asegúrate de importar el archivo

class MangaService {
  static Future<List<Map<String, dynamic>>> getAvailableMangas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('mangas');
      
      if (saved != null) {
        return (jsonDecode(saved) as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
      }
      
      return await LocalMangaData.loadMangas();
    } catch (e) {
      print('Error loading mangas: $e');
      return await LocalMangaData.loadMangas();
    }
  }

  static Future<void> markAsFeatured(String mangaId, bool featured) async {
    final mangas = await getAvailableMangas();
    final manga = mangas.firstWhere((m) => m['id'] == mangaId);
    manga['isFeatured'] = featured;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mangas', jsonEncode(mangas));
  }

  static Future<void> saveReadingProgress(
    String mangaId, 
    String chapterId, 
    double progress
  ) async {
    final mangas = await getAvailableMangas();
    final manga = mangas.firstWhere((m) => m['id'] == mangaId);
    
    manga['lastRead'] = {
      'chapterId': chapterId,
      'progress': progress,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    };
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('mangas', jsonEncode(mangas));
  }
}