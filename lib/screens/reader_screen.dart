// lib/screens/reader_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReaderScreen extends StatefulWidget {
  final String chapterTitle;
  final List<String> images;

  const ReaderScreen({
    required this.chapterTitle,
    required this.images,
    Key? key,
  }) : super(key: key);

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final PageController _pageController = PageController();
  final ScrollController _indicatorController = ScrollController();
  bool _isCascadeMode = false;
  int _currentPage = 0;
  final Map<String, String> _imageCache = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageChanged);
    _preloadImages().then((_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  Future<void> _preloadImages() async {
    await Future.wait(
      widget.images.map((imagePath) => _verifyImagePath(imagePath)),
    );
  }

  Future<String?> _verifyImagePath(String originalPath) async {
  print('Verificando ruta: $originalPath');
  if (_imageCache.containsKey(originalPath)) {
    return _imageCache[originalPath];
  }

  try {
    await rootBundle.load(originalPath);
    print('Imagen encontrada: $originalPath');
    _imageCache[originalPath] = originalPath;
    return originalPath;
  } catch (e) {
    print('Error al cargar $originalPath: $e');
    final extensionsToTry = ['.png', '.jpg', '.jpeg', '.webp'];
    final pathWithoutExtension = originalPath.replaceAll(
      RegExp(r'\.(png|jpg|jpeg|webp)$'),
      '',
    );

    for (final ext in extensionsToTry) {
      final alternativePath = '$pathWithoutExtension$ext';
      try {
        await rootBundle.load(alternativePath);
        print('Imagen encontrada con extensión alternativa: $alternativePath');
        _imageCache[originalPath] = alternativePath;
        return alternativePath;
      } catch (e) {
        print('Error con alternativa $alternativePath: $e');
        continue;
      }
    }
  }
  print('No se encontró ninguna variante para $originalPath');
  return null;
}

  void _onPageChanged() {
    final newPage = _pageController.page?.round() ?? 0;
    if (newPage != _currentPage && mounted) {
      setState(() => _currentPage = newPage);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollIndicatorToCurrent();
      });
    }
  }

  void _scrollIndicatorToCurrent() {
    if (!_indicatorController.hasClients) return;
    
    final double itemWidth = 16;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double targetPosition = _currentPage * itemWidth - 
        (screenWidth / 2) + 
        (itemWidth / 2);
    
    _indicatorController.animateTo(
      targetPosition.clamp(0.0, _indicatorController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'appLogo',
              child: Image.asset(
                'assets/icon/logo_Enchilada.png',
                height: 25,
                errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.image_not_supported),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                widget.chapterTitle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isCascadeMode ? Icons.view_agenda : Icons.view_carousel),
            onPressed: _toggleViewMode,
            tooltip: _isCascadeMode ? 'Modo página' : 'Modo cascada',
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _isCascadeMode 
              ? _buildCascadeView() 
              : _buildPageView(),
      bottomNavigationBar: _isLoading ? null : _buildPageIndicator(),
    );
  }

  Widget _buildPageIndicator() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: SingleChildScrollView(
          controller: _indicatorController,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(widget.images.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 16,
                height: 16,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index 
                      ? Theme.of(context).colorScheme.primary 
                      : Colors.grey.withOpacity(0.5),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  void _toggleViewMode() {
    setState(() => _isCascadeMode = !_isCascadeMode);
  }

  Widget _buildPageView() {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.images.length,
      onPageChanged: (index) {
        if (mounted) {
          setState(() => _currentPage = index);
        }
      },
      itemBuilder: (context, index) {
        return FutureBuilder<String?>(
          future: _verifyImagePath(widget.images[index]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final effectivePath = snapshot.data;
            
            return InteractiveViewer(
              panEnabled: true,
              scaleEnabled: true,
              minScale: 0.5,
              maxScale: 3.0,
              boundaryMargin: const EdgeInsets.all(20),
              child: effectivePath != null
                  ? Image.asset(
                      effectivePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => 
                          _buildErrorWidget(),
                    )
                  : _buildErrorWidget(),
            );
          },
        );
      },
    );
  }

  Widget _buildCascadeView() {
    return SingleChildScrollView(
      child: Column(
        children: widget.images.map((imagePath) {
          return FutureBuilder<String?>(
            future: _verifyImagePath(imagePath),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final effectivePath = snapshot.data;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: InteractiveViewer(
                  panEnabled: true,
                  scaleEnabled: true,
                  minScale: 0.5,
                  maxScale: 3.0,
                  boundaryMargin: const EdgeInsets.all(20),
                  child: effectivePath != null
                      ? Image.asset(
                          effectivePath,
                          fit: BoxFit.fitWidth,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) => 
                              _buildErrorWidget(),
                        )
                      : _buildErrorWidget(),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.broken_image, size: 50, color: Colors.grey),
          const SizedBox(height: 10),
          Text(
            'No se pudo cargar la imagen',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    _indicatorController.dispose();
    super.dispose();
  }
}