import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wallpaper.dart';

class UnsplashService {
  static const String _accessKey = 'qJV5htp3KxtTiffxqk4qGei9uq4UZOaboIPPSKeNv3Y';
  static const String _baseUrl = 'https://api.unsplash.com';

  Future<List<Wallpaper>> fetchWallpapers({int page = 1, int perPage = 30, String? query}) async {
    final url = query == null || query.isEmpty
        ? '$_baseUrl/photos?page=$page&per_page=$perPage&client_id=$_accessKey'
        : '$_baseUrl/search/photos?page=$page&per_page=$perPage&query=$query&client_id=$_accessKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = query == null || query.isEmpty ? data : data['results'];
      return results.map((json) => Wallpaper.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load wallpapers');
    }
  }
}