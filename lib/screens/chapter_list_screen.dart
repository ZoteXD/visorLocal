// lib/screens/chapter_list_screen.dart
import 'package:flutter/material.dart';
import 'reader_screen.dart';

class ChapterListScreen extends StatelessWidget {
  final String mangaId;
  final String mangaTitle;
  final List<Map<String, dynamic>> chapters;

  const ChapterListScreen({
    required this.mangaId,
    required this.mangaTitle,
    required this.chapters,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Hero(
              tag: 'appLogo',
              child: Image.asset(
                'assets/icon/logo_Enchilada.png',
                height: 30,
                errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.image_not_supported),
              ),
            ),
            const SizedBox(width: 10),
            Text(mangaTitle),
          ],
        ),
        centerTitle: true,
      ),
      body: chapters.isEmpty
          ? const Center(child: Text('No hay capítulos disponibles'))
          : ListView.builder(
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    title: Text(chapter['title']?.toString() ?? 'Capítulo sin título'),
                    subtitle: Text('${chapter['pageCount'] ?? 'N/A'} páginas'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReaderScreen(
                            chapterTitle: chapter['title']?.toString() ?? 'Capítulo sin título',
                            images: (chapter['images'] as List<dynamic>).cast<String>(),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}