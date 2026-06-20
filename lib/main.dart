import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:harmfilter_flutter/router.dart';
import 'package:provider/provider.dart';
import 'package:harmfilter_flutter/services/theme_service.dart';
import 'package:harmfilter_flutter/services/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:harmfilter_flutter/widgets/hf_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  if (kIsWeb) {
    // Web: Firebase is initialized here directly. No need for index.html scripts.
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyANpOPmWzfC-kwcDYvX2Z16oMJVt8ccVEE",
        authDomain: "harm-filter.firebaseapp.com",
        projectId: "harm-filter",
        storageBucket: "harm-filter.firebasestorage.app",
        messagingSenderId: "1023906358934",
        appId: "1:1023906358934:web:aca4b41fb447c5a8bc44b7",
        measurementId: "G-2PP36SZ22Q",
      ),
    );
  } else {
    // Mobile: Use google-services.json
    await Firebase.initializeApp();
  }

  // Initialize ThemeService so saved preferences load before UI renders
  final themeService = ThemeService();
  await themeService.init();

  // Initialize AuthService for persistence
  await authService.init();

  runApp(
    ChangeNotifierProvider.value(value: themeService, child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use a Consumer so the MaterialApp's ThemeData is rebuilt
    // whenever ThemeService notifies listeners (accent changes, themeMode).
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        final accent = themeService.accentColor;
        return MaterialApp.router(
          title: 'Harm Filter',
          debugShowCheckedModeBanner: false,
          theme: HFTheme.lightTheme(accentColor: accent),
          darkTheme: HFTheme.darkTheme(accentColor: accent),
          themeMode: themeService.themeMode,
          routerConfig: router,
        );
      },
    );
  }
}
