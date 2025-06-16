import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:nutrition_app/firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrition_app/screens/loading.dart';
import 'package:nutrition_app/screens/nutrichef/dashboard.dart';
import 'package:nutrition_app/screens/admin/document_verification_admin.dart';
import 'package:nutrition_app/screens/admin/admin_login.dart';
import 'package:nutrition_app/screens/admin/admin_dashboard.dart';
import 'package:nutrition_app/widgets/auth_checker.dart';
import 'package:google_fonts/google_fonts.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final Color seedColor = const Color.fromARGB(255, 166, 242, 79);

final TextTheme lightTextTheme = TextTheme(
  displayLarge: GoogleFonts.montserrat(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.brown.shade800,
  ),
  displayMedium: GoogleFonts.montserrat(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.brown.shade900,
  ),
  headlineSmall: GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.brown.shade500,
  ),
  titleMedium: GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  ),
  bodyLarge: GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.grey.shade800,
  ),
  bodyMedium: GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.grey.shade700,
  ),
  labelLarge: GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  ),
);

final ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
  ),
  textTheme: lightTextTheme,
  useMaterial3: true,
  scaffoldBackgroundColor: Color(0xFFFFF8E1),
  appBarTheme: AppBarTheme(
    backgroundColor: seedColor,
    foregroundColor: Colors.brown.shade900,
    elevation: 2,
    titleTextStyle: lightTextTheme.displayMedium,
    iconTheme: IconThemeData(color: Colors.brown.shade800),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: seedColor,
    foregroundColor: Colors.brown.shade900,
  ),
);

final Color surfaceColor = const Color.fromARGB(255, 35, 40, 44);
final Color scaffoldBgColor = const Color.fromARGB(255, 50, 58, 60);

final ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.dark,
    surface: surfaceColor,
  ),
  useMaterial3: true,
  scaffoldBackgroundColor: scaffoldBgColor,
  appBarTheme: AppBarTheme(
    backgroundColor: surfaceColor,
    elevation: 3,
    titleTextStyle: GoogleFonts.montserrat(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: const Color(0xFFFFF8E1),
    ),
    iconTheme: IconThemeData(color: const Color(0xFFFFF8E1)),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: seedColor,
    foregroundColor: Colors.black87,
  ),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.montserrat(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: seedColor.withOpacity(0.95),
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Colors.brown,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: Colors.grey[300],
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Colors.grey[350],
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: Colors.grey[400],
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Colors.grey[500],
    ),
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'NutriNudge',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        home: AuthChecker(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/admin/login': (context) => AdminLogin(),
          '/admin/dashboard': (context) => AdminDashboard(),
          '/admin/verifications': (context) => DocumentVerificationAdmin(),
        },
      ),
    );
  }
}
