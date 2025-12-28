import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/firebase_config.dart';
import 'splash_screen.dart';
import 'user/user_page.dart';
import 'home/HomePage.dart';
import 'theme_provider.dart';
import 'providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: const KedeGroceryApp(),
    ),
  );
}

class KedeGroceryApp extends StatelessWidget {
  const KedeGroceryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorScheme = themeProvider.isLight
        ? ColorScheme.fromSeed(seedColor: themeProvider.primaryColor)
        : ColorScheme.dark(primary: themeProvider.primaryColor);
    return MaterialApp(
      title: 'Kede - Grocery App',
      theme: ThemeData(
        primaryColor: themeProvider.primaryColor,
        scaffoldBackgroundColor: themeProvider.isLight
            ? const Color(0xFFFAFEFC)
            : Colors.black,
        fontFamily: 'Poppins',
        colorScheme: colorScheme,
        brightness: themeProvider.isLight ? Brightness.light : Brightness.dark,
      ),

      // Start app with the splash screen which will navigate onward.
      home: const SplashScreen(),
      // Named routes for cross-file navigation (avoid circular imports)
      routes: {
        '/user': (context) => const ProfilePage(),
        '/home': (context) => const HomePage(),
      },

      debugShowCheckedModeBanner: false,
    );
  }
}
