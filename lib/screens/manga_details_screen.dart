import 'package:flutter/material.dart';
import 'package:nodrive/data/manga_service.dart';

class MangaDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> manga;

  const MangaDetailsScreen({required this.manga, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(manga['title']),
        actions: [
          IconButton(
            icon: Icon(
              manga['isFeatured'] == true ? Icons.star : Icons.star_border,
              color: Colors.yellow,
            ),
            onPressed: () async {
              await MangaService.markAsFeatured(
                manga['id'], 
                !(manga['isFeatured'] == true)
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(manga['cover']),
            
          ],
        ),
      ),
    );
  }
}