import 'package:intl/intl.dart';
import '../../l10n/generated/app_localizations.dart';

class DateFormatter {
  DateFormatter._();

  static final _trDateFormat = DateFormat('dd/MM/yyyy');

  static String toEpdkFormat(DateTime date) => _trDateFormat.format(date);

  static String toDisplay(DateTime date, [String locale = 'tr']) =>
      DateFormat('dd MMM yyyy, HH:mm', locale).format(date);

  static String toShort(DateTime date, [String locale = 'tr']) =>
      DateFormat('dd MMM', locale).format(date);

  /// Locale-aware zaman farkı
  static String zamanFarki(DateTime date, [AppLocalizations? l]) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (l != null) {
      if (diff.inMinutes < 1) return l.azOnce;
      if (diff.inMinutes < 60) return l.dkOnce(diff.inMinutes);
      if (diff.inHours < 24) return l.saatOnce(diff.inHours);
      if (diff.inDays < 7) return l.gunOnce(diff.inDays);
    } else {
      // Fallback Türkçe
      if (diff.inMinutes < 1) return 'Az önce';
      if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
      if (diff.inHours < 24) return '${diff.inHours} saat önce';
      if (diff.inDays < 7) return '${diff.inDays} gün önce';
    }
    return toShort(date, l?.localeName ?? 'tr');
  }
}
