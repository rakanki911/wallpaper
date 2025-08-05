import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:http/http.dart' as http;
import '../models/wallpaper.dart';

class FullscreenScreen extends StatelessWidget {
  final Wallpaper wallpaper;
  const FullscreenScreen({Key? key, required this.wallpaper}) : super(key: key);

  Future<void> _saveImage(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(wallpaper.imageUrl));
      final result = await ImageGallerySaver.saveImage(response.bodyBytes, quality: 100, name: wallpaper.id);
      if (result['isSuccess'] == true || result['isSuccess'] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ الصورة في المعرض')));
      } else {
        throw Exception('فشل الحفظ');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء الحفظ')));
    }
  }

  Future<void> _shareImage(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(wallpaper.imageUrl));
      final bytes = response.bodyBytes;
      final tempDir = await Directory.systemTemp.createTemp();
      final file = await File('${tempDir.path}/${wallpaper.id}.jpg').writeAsBytes(bytes);
      await Share.shareFiles([file.path], text: wallpaper.description.isNotEmpty ? wallpaper.description : 'خلفية من Unsplash');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء المشاركة')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAndroid = Platform.isAndroid;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: wallpaper.id,
              child: CachedNetworkImage(
                imageUrl: wallpaper.imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (isAndroid)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () async {
                      // تعيين كخلفية (يتطلب مكتبة إضافية ودعم أندرويد فقط)
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعيين الخلفية مدعوم فقط في أندرويد.')));
                    },
                    icon: const Icon(Icons.wallpaper),
                    label: const Text('تعيين كخلفية'),
                  ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => _saveImage(context),
                  icon: const Icon(Icons.download),
                  label: const Text('حفظ'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => _shareImage(context),
                  icon: const Icon(Icons.share),
                  label: const Text('مشاركة'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}