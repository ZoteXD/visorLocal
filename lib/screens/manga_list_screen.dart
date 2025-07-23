// lib/screens/manga_list_screen.dart
import 'package:flutter/material.dart';
import 'package:nodrive/data/manga_service.dart';
import 'chapter_list_screen.dart';

class MangaListScreen extends StatelessWidget {
  const MangaListScreen({super.key});

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
              ),
            ),
            const SizedBox(width: 10),
            const Text('Biblioteca'),
          ],
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: MangaService.getAvailableMangas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allMangas = snapshot.data!;
          final featuredMangas = allMangas.where((m) => m['isFeatured'] == true).toList();
          final continueReading = allMangas.where((m) => m['lastRead'] != null).toList();

          return ListView(
            children: [
              _buildSectionTitle('Destacados'),
              _buildHorizontalMangaList(featuredMangas, height: 180),

              _buildSectionTitle('Continuar leyendo'),
              _buildHorizontalMangaList(continueReading, height: 180, showProgress: true),

              _buildSectionTitle('Todos los mangas'),
              _buildGridMangaList(allMangas),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHorizontalMangaList(List<Map<String, dynamic>> mangas, {double height = 180, bool showProgress = false}) {
  return SizedBox(
    height: height + 40, // Añade espacio extra para el texto
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: mangas.length,
      itemBuilder: (context, index) {
        final manga = mangas[index];
        return Container(
          width: 120,
          margin: const EdgeInsets.only(right: 8),
          child: _MangaCard(
            manga: manga,
            showProgress: showProgress,
            onTap: () => _navigateToChapterList(context, manga),
          ),
        );
      },
    ),
  );
}

  Widget _buildGridMangaList(List<Map<String, dynamic>> mangas) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.6,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: mangas.length,
        itemBuilder: (context, index) {
          final manga = mangas[index];
          return _MangaCard(
            manga: manga,
            onTap: () => _navigateToChapterList(context, manga),
          );
        },
      ),
    );
  }

  void _navigateToChapterList(BuildContext context, Map<String, dynamic> manga) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChapterListScreen(
          mangaId: manga['id'],
          mangaTitle: manga['title'],
          chapters: (manga['chapters'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [],
        ),
      ),
    );
  }
}

class _MangaCard extends StatelessWidget {
  final Map<String, dynamic> manga;
  final bool showProgress;
  final VoidCallback onTap;

  const _MangaCard({
    required this.manga,
    this.showProgress = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 180,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Portada con progreso
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AspectRatio(
                      aspectRatio: 2/3,
                      child: _buildCoverImage(),
                    ),
                  ),
                  if (showProgress && (manga['progress'] ?? 0) > 0)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(
                        value: manga['progress']?.toDouble() ?? 0.0,
                        backgroundColor: Colors.black.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              manga['title'] ?? 'Sin título',
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

    Widget _buildCoverImage() {
      final coverImage = manga['cover']?.toString(); 
      print('Intentando cargar portada: $coverImage');
      
      if (coverImage == null || coverImage.isEmpty) {
        print('Portada no especificada en los datos del manga');
        return _buildPlaceholder('Sin portada');
      }

      return Image.asset(
        coverImage,
        fit: BoxFit.cover,
        errorBuilder: (_, error, stackTrace) {
          print('Error al cargar $coverImage: $error');
          return _buildPlaceholder('Error de carga');
        },
      );
    }

  Widget _buildPlaceholder(String message) {
    return Container(
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.broken_image, size: 40, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

} //end