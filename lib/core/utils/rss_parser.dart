import 'package:xml/xml.dart';
import 'package:html_unescape/html_unescape.dart';
import '../../features/haberler/data/models/haber_model.dart';

class RssParser {
  RssParser._();

  static List<HaberModel> parse(String xmlString, String sourceUrl) {
    try {
      final document = XmlDocument.parse(xmlString);

      // RSS 2.0 (<item>) veya Atom (<entry>) formatÄ±nÄ± destekle
      final items = document.findAllElements('item');
      final entries = document.findAllElements('entry');

      final feedTitle =
          document.findAllElements('title').firstOrNull?.innerText ?? sourceUrl;

      if (items.isNotEmpty) {
        return _parseRssItems(items, feedTitle);
      } else if (entries.isNotEmpty) {
        return _parseAtomEntries(entries, feedTitle);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static List<HaberModel> _parseRssItems(
    Iterable<XmlElement> items,
    String feedTitle,
  ) {
    return items.map((item) {
      final title = item.findElements('title').firstOrNull?.innerText ?? '';
      final description =
          item.findElements('description').firstOrNull?.innerText ?? '';
      final link = item.findElements('link').firstOrNull?.innerText ?? '';
      final pubDate = item.findElements('pubDate').firstOrNull?.innerText;

      DateTime parsedDate;
      try {
        parsedDate = pubDate != null ? _parseRfc822(pubDate) : DateTime.now();
      } catch (_) {
        parsedDate = DateTime.now();
      }

      return HaberModel(
        baslik: _stripHtml(title),
        ozet: _stripHtml(description),
        icerik: description,
        url: link.trim(),
        yayinTarihi: parsedDate,
        kaynak: feedTitle,
      );
    }).toList();
  }

  static List<HaberModel> _parseAtomEntries(
    Iterable<XmlElement> entries,
    String feedTitle,
  ) {
    return entries.map((entry) {
      final title = entry.findElements('title').firstOrNull?.innerText ?? '';
      final summary =
          entry.findElements('summary').firstOrNull?.innerText ??
          entry.findElements('content').firstOrNull?.innerText ??
          '';
      // Atom link: <link rel="alternate" href="..."/>
      final linkEl = entry.findElements('link').firstOrNull;
      final link = linkEl?.getAttribute('href') ?? linkEl?.innerText ?? '';
      final updated =
          entry.findElements('updated').firstOrNull?.innerText ??
          entry.findElements('published').firstOrNull?.innerText;

      DateTime parsedDate;
      try {
        parsedDate = updated != null ? DateTime.parse(updated) : DateTime.now();
      } catch (_) {
        parsedDate = DateTime.now();
      }

      return HaberModel(
        baslik: _stripHtml(title),
        ozet: _stripHtml(summary),
        icerik: summary,
        url: link.trim(),
        yayinTarihi: parsedDate,
        kaynak: feedTitle,
      );
    }).toList();
  }

  static String _stripHtml(String html) {
    if (html.isEmpty) return '';
    var text = html.replaceAll(RegExp(r'<[^>]*>'), '');

    var unescape = HtmlUnescape();
    text = unescape.convert(text);
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// RFC 822 tarih parse (RSS standart format)
  static DateTime _parseRfc822(String dateStr) {
    // "Mon, 21 Mar 2026 09:00:00 +0300" gibi formatlar
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      // Manuel parse deneyelim
      final months = {
        'Jan': 1,
        'Feb': 2,
        'Mar': 3,
        'Apr': 4,
        'May': 5,
        'Jun': 6,
        'Jul': 7,
        'Aug': 8,
        'Sep': 9,
        'Oct': 10,
        'Nov': 11,
        'Dec': 12,
      };
      try {
        final parts = dateStr.replaceAll(',', '').trim().split(RegExp(r'\s+'));
        // parts: [Mon] [21] [Mar] [2026] [09:00:00] [+0300]
        final dayIdx = parts.indexWhere((p) => int.tryParse(p) != null);
        if (dayIdx < 0) return DateTime.now();
        final day = int.parse(parts[dayIdx]);
        final month = months[parts[dayIdx + 1]] ?? 1;
        final year = int.parse(parts[dayIdx + 2]);
        final timeParts = parts[dayIdx + 3].split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        final second = timeParts.length > 2 ? int.parse(timeParts[2]) : 0;
        return DateTime(year, month, day, hour, minute, second);
      } catch (_) {
        return DateTime.now();
      }
    }
  }
}
