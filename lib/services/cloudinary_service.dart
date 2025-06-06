import 'dart:io';
import 'package:dio/dio.dart';

class CloudinaryService {
  // Replace with your Cloudinary details
  static const String cloudName = 'deybfqdcd';
  static const String uploadPreset = 'nutriNudge'; // Create this in Cloudinary dashboard
  static const String apiUrl = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  final Dio _dio = Dio();

  // Upload file to Cloudinary
  Future<String?> uploadImage(File imageFile,String uid) async {
    try {
      String fileName = '$uid.jpg';
      
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
        'upload_preset': uploadPreset,
        'folder': 'flutter_app', // Optional: organize images in folders
      });

      print('Starting upload to Cloudinary...');
      
      Response response = await _dio.post(
        apiUrl,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          sendTimeout: Duration(seconds: 30),
          receiveTimeout: Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        String imageUrl = response.data['secure_url'];
        print('Upload successful: $imageUrl');
        return imageUrl;
      } else {
        print('Upload failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  // Get optimized image URL
  String getOptimizedImageUrl(String originalUrl, {
    int? width,
    int? height,
    String quality = 'auto',
  }) {
    if (!originalUrl.contains('cloudinary.com')) return originalUrl;
    
    // Extract public_id from URL
    final uri = Uri.parse(originalUrl);
    final segments = uri.pathSegments;
    final uploadIndex = segments.indexOf('upload');
    
    if (uploadIndex == -1) return originalUrl;
    
    final publicIdWithExtension = segments.sublist(uploadIndex + 1).join('/');
    final publicId = publicIdWithExtension.split('.').first;
    
    // Build transformation
    List<String> transformations = [];
    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    transformations.add('q_$quality');
    transformations.add('f_auto');
    
    final transformationString = transformations.join(',');
    
    return 'https://res.cloudinary.com/$cloudName/image/upload/$transformationString/$publicId';
  }
}