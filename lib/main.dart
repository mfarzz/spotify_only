import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:spotify_only/config/app_router.dart';
import 'package:spotify_only/providers/auth_provider.dart';
import 'package:spotify_only/providers/home_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load .env file
  await dotenv.load(fileName: ".env");
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SpotifyAuthProvider>(
          create: (ctx) {
            final provider = SpotifyAuthProvider();
            provider.initialize(); // ✅ inisialisasi di sini
            return provider;
          },
        ),
        ChangeNotifierProvider<HomeProvider>(
          create: (_) => HomeProvider(), // ✅ tambahan provider
        ),
        // Tambahkan provider lain di sini jika diperlukan
      ],
      child: Builder(
        builder: (context) {
          // Router harus diambil setelah provider terpasang
          final router = AppRouter.getRouter(context);

          return MaterialApp.router(
            title: 'Spotify App',
            theme: ThemeData(
              primarySwatch: Colors.green,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              colorScheme: ColorScheme.fromSwatch(
                primarySwatch: Colors.green,
                accentColor: const Color(0xFF1DB954),
                brightness: Brightness.light,
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.green,
              primaryColor: const Color(0xFF1DB954),
              colorScheme: ColorScheme.dark(
                primary: const Color(0xFF1DB954),
                secondary: const Color(0xFF1DB954),
              ),
              scaffoldBackgroundColor: const Color(0xFF121212),
            ),
            themeMode: ThemeMode.dark,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
