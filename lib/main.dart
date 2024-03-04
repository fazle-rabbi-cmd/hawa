// import 'package:flutter/material.dart';
// import 'package:hawa/screens/HomeScreen.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   late bool _isDarkTheme = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadTheme();
//   }
//
//   Future<void> _loadTheme() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
//     });
//   }
//
//   void _toggleTheme(bool isDark) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('isDarkTheme', isDark);
//     setState(() {
//       _isDarkTheme = isDark;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Hawa',
//       theme: _isDarkTheme ? ThemeData.dark() : ThemeData.light(),
//       home: HomeScreen(
//         isDarkTheme: _isDarkTheme,
//         toggleTheme: _toggleTheme,
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:hawa/screens/HomeScreen.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:hawa/widgets/SplashScreenWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hawa',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: AnimatedSplashScreen(
        // splash: Image.asset(
        //     'assets/weather-app_icon.png'), // Replace with your splash screen logo
        // splashIconSize: 200,
        splash: SplashScreenWidget(), // Your splash screen widget
        nextScreen: const AppContent(),
        splashTransition: SplashTransition.fadeTransition,
        duration: 1000,
        backgroundColor: Colors.white,
      ),
    );
  }
}

class AppContent extends StatefulWidget {
  const AppContent({super.key});

  @override
  _AppContentState createState() => _AppContentState();
}

class _AppContentState extends State<AppContent> {
  late bool _isDarkTheme = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    });
  }

  void _toggleTheme(bool isDark) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', isDark);
    setState(() {
      _isDarkTheme = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreen(
      isDarkTheme: _isDarkTheme,
      toggleTheme: _toggleTheme,
    );
  }
}
