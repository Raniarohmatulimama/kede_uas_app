/// Cloudinary Configuration
///
/// Cloudinary API Key: duqcxzhkr
/// Folder Name: kede_app
class CloudinaryConfig {
  // Cloudinary credentials
  static const String cloudName = 'duqcxzhkr';
  static const String apiKey =
      'YOUR_CLOUDINARY_API_KEY'; // Optional, untuk upload programmatic
  static const String uploadPreset =
      'kede_app'; // Folder name untuk organize uploads

  // Base URL untuk Cloudinary resources
  static const String baseUrl = 'https://res.cloudinary.com/$cloudName';

  // Upload URL
  static const String uploadUrl =
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  /// Generate Cloudinary image URL dengan optimizations
  ///
  /// Parameters:
  /// - publicId: Public ID dari image yang sudah di-upload
  /// - width: Optional - lebar image (px)
  /// - height: Optional - tinggi image (px)
  /// - crop: Optional - mode crop (fill, fit, scale, etc)
  /// - quality: Optional - kualitas image (auto, 80, etc)
  /// - format: Optional - format output (auto, webp, jpg, etc)
  static String getImageUrl(
    String publicId, {
    int? width,
    int? height,
    String crop = 'fill',
    String quality = 'auto',
    String format = 'auto',
  }) {
    // Build transformation string
    final List<String> transformations = [];

    if (width != null || height != null) {
      final w = width ?? 'auto';
      final h = height ?? 'auto';
      transformations.add('w_$w,h_$h,c_$crop');
    }

    transformations.add('q_$quality');
    transformations.add('f_$format');

    final transformation = transformations.join('/');
    return '$baseUrl/image/upload/$transformation/$publicId';
  }

  /// Generate Cloudinary image URL untuk thumbnail
  static String getThumbnailUrl(String publicId, {int size = 200}) {
    return getImageUrl(
      publicId,
      width: size,
      height: size,
      crop: 'fill',
      quality: 'auto',
      format: 'auto',
    );
  }

  /// Generate Cloudinary image URL untuk display
  static String getDisplayUrl(String publicId) {
    return getImageUrl(
      publicId,
      width: 500,
      height: 500,
      crop: 'scale',
      quality: 'auto',
      format: 'auto',
    );
  }

  /// Extract public ID dari Cloudinary URL
  /// Contoh: https://res.cloudinary.com/duqcxzhkr/image/upload/v1234/kede_app/xyz123
  /// Return: kede_app/xyz123
  static String extractPublicId(String url) {
    try {
      if (!url.contains('cloudinary.com')) return url;

      final parts = url.split('/');
      final uploadIndex = parts.indexOf('upload');

      if (uploadIndex == -1) return url;

      // Skip version (v1234) if exists
      int startIndex = uploadIndex + 1;
      if (parts[startIndex].startsWith('v')) {
        startIndex++;
      }

      // Join remaining parts sebagai public ID
      return parts.sublist(startIndex).join('/');
    } catch (e) {
      print('[CloudinaryConfig] Error extracting public ID: $e');
      return url;
    }
  }

  /// Validate if URL is Cloudinary URL
  static bool isCloudinaryUrl(String url) {
    return url.contains('cloudinary.com') && url.contains(cloudName);
  }
}
