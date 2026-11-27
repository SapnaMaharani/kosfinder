
import 'package:url_launcher/url_launcher.dart';

class ContactHelper {
  /// Mengubah nomor 08xxxxxxxx menjadi 628xxxxxxxx.
  static String normalizePhone(String phone) {
    String normalized = phone.replaceAll(RegExp(r'[^0-9]'), '');

    if (normalized.startsWith('0')) {
      normalized = '62${normalized.substring(1)}';
    } else if (normalized.startsWith('8')) {
      normalized = '62$normalized';
    }

    return normalized;
  }

  /// Membuka WhatsApp dengan nomor pemilik kos.
  static Future<bool> openWhatsApp(String phone) async {
    final normalizedPhone = normalizePhone(phone);

    final uri = Uri.parse(
      'https://wa.me/$normalizedPhone',
    );

    if (await canLaunchUrl(uri)) {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }

    return false;
  }

  /// Membuka aplikasi telepon.
  static Future<bool> makePhoneCall(String phone) async {
    final normalizedPhone = normalizePhone(phone);
    final uri = Uri(scheme: 'tel', path: normalizedPhone);

    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }

    return false;
  }
}
