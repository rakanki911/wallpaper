import 'package:flutter/material.dart';
import '../services/unsplash_service.dart';
import '../models/wallpaper.dart';
import '../widgets/wallpaper_grid.dart';
import '../widgets/custom_search_bar.dart';
import 'fullscreen_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UnsplashService _service = UnsplashService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Wallpaper> _wallpapers = [];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _fetchWallpapers();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchWallpapers({bool refresh = false}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    if (refresh) {
      _page = 1;
      _hasMore = true;
    }
    try {
      final wallpapers = await _service.fetchWallpapers(
        page: _page,
        perPage: 30,
        query: _query.isEmpty ? null : _query,
      );
      setState(() {
        if (refresh) {
          _wallpapers = wallpapers;
        } else {
          _wallpapers.addAll(wallpapers);
        }
        _hasMore = wallpapers.length == 30;
        _isLoading = false;
        if (!refresh) _page++;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تحميل الصور')),
      );
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300 && _hasMore && !_isLoading) {
      _fetchWallpapers();
    }
  }

  void _onSearch(String value) {
    setState(() {
      _query = value.trim();
    });
    _fetchWallpapers(refresh: true);
  }

  Future<void> _onRefresh() async {
    await _fetchWallpapers(refresh: true);
  }

  void _openFullscreen(Wallpaper wallpaper) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullscreenScreen(wallpaper: wallpaper),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خلفيات عالية الجودة'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: CustomSearchBar(
              controller: _searchController,
              onSubmitted: _onSearch,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: WallpaperGrid(
                wallpapers: _wallpapers,
                controller: _scrollController,
                onTap: _openFullscreen,
                isLoading: _isLoading,
              ),
            ),
          ),
        ],
      ),
    );
  }
}