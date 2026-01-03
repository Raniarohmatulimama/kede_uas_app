import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/cloudinary_config.dart';

class CloudinaryService {
  /// Upload image ke Cloudinary
  ///
  /// Returns Map dengan:
  /// - success: bool
  /// - publicId: String (jika success)
  /// - url: String (full URL, jika success)
  /// - message: String (error message jika gagal)
  static Future<Map<String, dynamic>> uploadImage(
    File imageFile, {
    String? resourceType = 'image',
    Map<String, String>? tags,
  }) async {
    try {
      print('[Cloudinary] Starting upload from: ${imageFile.path}');

      // Prepare form request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(CloudinaryConfig.uploadUrl),
      );

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      // Add fields
      request.fields['upload_preset'] = CloudinaryConfig.uploadPreset;
      request.fields['folder'] = CloudinaryConfig.uploadPreset;
      request.fields['resource_type'] = resourceType ?? 'image';

      // Add tags if provided
      if (tags != null && tags.isNotEmpty) {
        request.fields['tags'] = tags.keys.join(',');
      }

      print('[Cloudinary] Sending request to Cloudinary...');

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('[Cloudinary] Response status: ${response.statusCode}');
      print('[Cloudinary] Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Parse response
        final Map<String, dynamic> data = _parseJsonResponse(response.body);

        if (data['error'] != null) {
          return {
            'success': false,
            'message': 'Upload failed: ${data['error']['message']}',
          };
        }

        final publicId = data['public_id'] as String?;
        final secureUrl = data['secure_url'] as String?;

        if (publicId == null || secureUrl == null) {
          return {
            'success': false,
            'message': 'Invalid response from Cloudinary',
          };
        }

        print('[Cloudinary] Upload success! Public ID: $publicId');

        return {
          'success': true,
          'publicId': publicId,
          'url': secureUrl,
          'data': data, // Full response data
        };
      } else {
        final error = _parseJsonResponse(response.body);
        return {
          'success': false,
          'message':
              'Upload failed (${response.statusCode}): ${error['error']?['message'] ?? 'Unknown error'}',
        };
      }
    } catch (e) {
      print('[Cloudinary] Upload error: $e');
      return {'success': false, 'message': 'Upload error: $e'};
    }
  }

  /// Delete image dari Cloudinary (membutuhkan API key)
  ///
  /// Note: Ini memerlukan authenticated API call dengan API secret
  /// Lebih aman dilakukan dari backend
  static Future<Map<String, dynamic>> deleteImage(String publicId) async {
    try {
      print('[Cloudinary] Attempting to delete: $publicId');
      print(
        '[Cloudinary] Note: Image deletion requires authenticated API call',
      );
      print('[Cloudinary] Please delete from backend or Cloudinary dashboard');

      return {
        'success': false,
        'message':
            'Image deletion should be done from backend/server for security',
      };
    } catch (e) {
      return {'success': false, 'message': 'Delete error: $e'};
    }
  }

  /// Get optimized URL untuk thumbnail
  static String getThumbnailUrl(String publicId, {int size = 200}) {
    return CloudinaryConfig.getThumbnailUrl(publicId, size: size);
  }

  /// Get optimized URL untuk display
  static String getDisplayUrl(String publicId) {
    return CloudinaryConfig.getDisplayUrl(publicId);
  }

  /// Get custom optimized URL
  static String getOptimizedUrl(
    String publicId, {
    int? width,
    int? height,
    String crop = 'fill',
    String quality = 'auto',
    String format = 'auto',
  }) {
    return CloudinaryConfig.getImageUrl(
      publicId,
      width: width,
      height: height,
      crop: crop,
      quality: quality,
      format: format,
    );
  }

  /// Extract public ID dari URL
  static String extractPublicId(String url) {
    return CloudinaryConfig.extractPublicId(url);
  }

  /// Check jika URL adalah Cloudinary URL
  static bool isCloudinaryUrl(String url) {
    return CloudinaryConfig.isCloudinaryUrl(url);
  }

  /// Parse JSON response dengan error handling
  static Map<String, dynamic> _parseJsonResponse(String body) {
    try {
      // Simple JSON parse (bisa diimprove dengan json package)
      if (body.startsWith('{')) {
        return _parseJson(body);
      }
      return {
        'error': {'message': 'Invalid response format'},
      };
    } catch (e) {
      print('[Cloudinary] Error parsing response: $e');
      return {
        'error': {'message': e.toString()},
      };
    }
  }

  /// Simple JSON parser (avoid json dependency)
  static Map<String, dynamic> _parseJson(String json) {
    // For now, using simple approach
    // In production, use jsonDecode from dart:convert
    try {
      // This is a simple implementation
      // For full JSON support, import 'dart:convert' and use jsonDecode
      Map<String, dynamic> jsonDecode(String json) {
        // Fallback JSON parser
        // Extract key values manually
        final map = <String, dynamic>{};

        if (json.contains('"public_id"')) {
          final match = RegExp(r'"public_id"\s*:\s*"([^"]+)"').firstMatch(json);
          if (match != null) map['public_id'] = match.group(1);
        }

        if (json.contains('"secure_url"')) {
          final match = RegExp(
            r'"secure_url"\s*:\s*"([^"]+)"',
          ).firstMatch(json);
          if (match != null) map['secure_url'] = match.group(1);
        }

        if (json.contains('"url"')) {
          final match = RegExp(r'"url"\s*:\s*"([^"]+)"').firstMatch(json);
          if (match != null) map['url'] = match.group(1);
        }

        if (json.contains('"error"')) {
          map['error'] = {'message': 'Upload error'};
        }

        return map;
      }

      return jsonDecode(json);
    } catch (e) {
      print('[Cloudinary] JSON parse error: $e');
      return {};
    }
  }
}
