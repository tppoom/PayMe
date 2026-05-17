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
        locale: provider.locale,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE91E63), // More balanced, professional pink
            primary: const Color(0xFFE91E63),
            secondary: const Color(0xFFAD1457),
            surface: const Color(0xFFFFF1F6), // Very soft pink background
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFFFF1F6),
          useMaterial3: true,
          // Explicitly theme buttons to avoid default white/grey
          segmentedButtonTheme: SegmentedButtonThemeData(
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: const Color(0xFFE91E63),
              selectedForegroundColor: Colors.white,
              backgroundColor: const Color(0xFFFFD1DC),
              foregroundColor: const Color(0xFFAD1457),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              foregroundColor: Colors.white,
            ),
          ),
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
