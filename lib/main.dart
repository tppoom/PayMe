import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logic/expense_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ExpenseProvider(),
      child: const PayMeApp(),
    ),
  );
}

class PayMeApp extends StatelessWidget {
  const PayMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) => MaterialApp(
        title: 'PayMe',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF8DA1), // Cuter Pink
            brightness: Brightness.light,
            surface: const Color(0xFFFFF0F3), // Soft Pink BG
          ),
          scaffoldBackgroundColor: const Color(0xFFFFF0F3),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
            surface: const Color(0xFF0A0A1A),
          ),
          scaffoldBackgroundColor: const Color(0xFF0A0A1A),
          useMaterial3: true,
        ),
        themeMode: provider.themeMode,
        home: const HomeScreen(),
      ),
    );
  }
}
