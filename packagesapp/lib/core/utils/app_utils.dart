import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUtils {
  AppUtils._();

  // Flutter's HapticFeedback is often suppressed on Samsung One UI.
  // We fall back to direct vibration for reliable tactile response.
  static Future<void> hapticLight() async {
    HapticFeedback.lightImpact();
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 30, amplitude: 80);
    }
  }

  static Future<void> hapticMedium() async {
    HapticFeedback.mediumImpact();
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 50, amplitude: 140);
    }
  }

  static Future<void> hapticSelection() async {
    HapticFeedback.selectionClick();
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 20, amplitude: 60);
    }
  }

  static void copyToClipboard(BuildContext context, String text, {String? label}) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${label ?? text} copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static Future<void> dialCode(String code) async {
    hapticMedium();
    final uri = Uri.parse('tel:${Uri.encodeComponent(code)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  static Color hexToColor(String hex) {
    final clean = hex.replaceAll('#', '');
    final val = int.tryParse('FF$clean', radix: 16);
    return val != null ? Color(val) : Colors.grey;
  }

  static String categoryLabel(String category) {
    switch (category) {
      case 'call':
        return 'Call';
      case 'sms':
        return 'SMS';
      case 'internet':
        return 'Internet';
      case 'hybrid':
        return 'Hybrid';
      case 'social':
        return 'Social';
      case 'gaming':
        return 'Gaming';
      case 'free':
      case 'offers':
      case 'free_offers':
        return 'Free Offers';
      default:
        return 'All';
    }
  }

  static IconData categoryIcon(String category) {
    switch (category) {
      case 'call':
        return Icons.phone_outlined;
      case 'sms':
        return Icons.chat_bubble_outline;
      case 'internet':
        return Icons.wifi_outlined;
      case 'hybrid':
        return Icons.apps_outlined;
      case 'social':
        return Icons.share_outlined;
      case 'gaming':
        return Icons.sports_esports_outlined;
      case 'free':
      case 'offers':
      case 'free_offers':
        return Icons.card_giftcard_rounded;
      default:
        return Icons.grid_view_outlined;
    }
  }
}
