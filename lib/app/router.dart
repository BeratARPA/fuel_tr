import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/fiyatlar/presentation/screens/anasayfa_screen.dart';
import '../features/fiyatlar/presentation/screens/il_detay_screen.dart';
import '../features/fiyatlar/presentation/screens/karsilastirma_screen.dart';
import '../features/haberler/presentation/screens/haberler_screen.dart';
import '../features/haberler/domain/entities/haber.dart';
import '../features/haberler/presentation/screens/haber_detay_screen.dart';
import '../features/ayarlar/presentation/screens/ayarlar_screen.dart';
import '../features/hesaplama/presentation/screens/hesaplama_screen.dart';
import '../features/fiyatlar/presentation/screens/doviz_etki_screen.dart';
import '../features/fiyatlar/presentation/screens/isi_haritasi_screen.dart';
import '../features/fiyatlar/presentation/screens/otv_hesaplayici_screen.dart';
import '../features/istasyonlar/presentation/screens/yakin_istasyonlar_screen.dart';
import '../features/yakit_defteri/presentation/screens/yakit_defteri_screen.dart';
import 'shell_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/fiyatlar',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ShellScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/fiyatlar',
              builder: (context, state) => const AnasayfaScreen(),
              routes: [
                GoRoute(
                  path: 'yakin-istasyonlar',
                  builder: (context, state) => const YakinIstasyonlarScreen(),
                ),
                GoRoute(
                  path: 'doviz-etkisi',
                  builder: (context, state) => const DovizEtkiScreen(),
                ),
                GoRoute(
                  path: 'otv-hesaplayici',
                  builder: (context, state) => const OtvHesaplayiciScreen(),
                ),
                GoRoute(
                  path: 'isi-haritasi',
                  builder: (context, state) => const IsiHaritasiScreen(),
                ),
                GoRoute(
                  path: 'yakit-defteri',
                  builder: (context, state) => const YakitDefteriScreen(),
                ),
                GoRoute(
                  path: 'il/:ilKodu',
                  builder: (context, state) {
                    final ilKodu = state.pathParameters['ilKodu']!;
                    final ilAdi = state.uri.queryParameters['ilAdi'] ?? ilKodu;
                    return IlDetayScreen(ilKodu: ilKodu, ilAdi: ilAdi);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/karsilastir',
              builder: (context, state) => const KarsilastirmaScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/haberler',
              builder: (context, state) => const HaberlerScreen(),
              routes: [
                GoRoute(
                  path: 'detay',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final haber = state.extra as Haber;
                    return HaberDetayScreen(haber: haber);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/hesaplama',
              builder: (context, state) => const HesaplamaScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/ayarlar',
              builder: (context, state) => const AyarlarScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
