import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../domain/entities/haber.dart';

class HaberDetayScreen extends StatelessWidget {
  final Haber haber;

  const HaberDetayScreen({super.key, required this.haber});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tarihFormat = DateFormat('dd.MM.yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Haber Detayı')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              haber.baslik,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  tarihFormat.format(haber.yayinTarihi),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.source,
                  size: 16,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    haber.kaynak,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Html(
              data: haber.icerik.isNotEmpty ? haber.icerik : haber.ozet,
              style: {
                'body': Style(
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                  fontSize: FontSize(16.0),
                  lineHeight: const LineHeight(1.6),
                ),
                'img': Style(
                  padding: HtmlPaddings.zero,
                  margin: Margins.zero,
                ),
              },
              onLinkTap: (url, _, __) {
                if (url != null) {
                  launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                }
              },
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(haber.url);
                  if (!await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  )) {
                    try {
                      await launchUrl(uri, mode: LaunchMode.platformDefault);   
                    } catch (_) {}
                  }
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Haberin Kaynağına Git'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}