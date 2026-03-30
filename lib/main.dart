import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:biznet/providers/auth_provider.dart';
import 'package:biznet/providers/home_provider.dart';
import 'package:biznet/providers/search_provider.dart';
import 'package:biznet/providers/review_provider.dart';
import 'package:biznet/providers/business_provider.dart';
import 'package:biznet/routes/app_router.dart';
import 'package:biznet/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  await Hive.openBox('authBox');

  // Test Firestore connection
  _testFirestoreConnection();

  runApp(const MyApp());
}

Future<void> _testFirestoreConnection() async {
  try {
    final db = FirebaseFirestore.instance;
    // Attempt to fetch a public document to test connectivity
    await db.collection('test').doc('connection').get(const GetOptions(source: Source.server));
    print('Firestore connection test successful (Public Read)');
  } catch (e) {
    print('Current Firebase Project ID: ${Firebase.app().options.projectId}');
    print('Firestore connection test failed: $e');
    if (e.toString().contains('permission-denied')) {
      print('PERMISSION_DENIED: This might be expected if you are not logged in, but the test document should be public.');
    }
    if (e.toString().contains('NOT_FOUND') || e.toString().contains('unavailable')) {
      print('CRITICAL: Project ID mismatch or Database not found. Ensure your app is configured for project: theta-yen-489914-p3');
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthProvider _authProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    _router = AppRouter.createRouter(_authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => BusinessProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: 'BIZNET',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1E2E4F),
                primary: const Color(0xFF1E2E4F),
              ),
              // Use default text theme to avoid google_fonts asset dependency during debugging
              textTheme: ThemeData.light().textTheme,
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E2E4F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              cardTheme: const CardThemeData(
                color: Colors.white,
                shadowColor: Colors.black26,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E2E4F), brightness: Brightness.dark),
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFF121212),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1E2E4F),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E2E4F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              cardTheme: const CardThemeData(
                color: Color(0xFF1E2E4F),
                shadowColor: Colors.black26,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              listTileTheme: const ListTileThemeData(
                iconColor: Colors.white,
                textColor: Colors.white,
              ),
            ),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
