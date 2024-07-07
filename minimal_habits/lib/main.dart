import 'package:flutter/material.dart';
import 'package:minimal_habits/Database/habit_databases.dart';
import 'package:minimal_habits/Pages/home_page.dart';
import 'package:minimal_habits/Theme/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //initialize database

  final habitDatabase = HabitDatabase();
  try {
    await HabitDatabase.initialize();
    await habitDatabase.saveFirstLaunchDate();
    // Rest of your main function
  } catch (e) {
    print('Error initializing database: $e');
    // Handle the error appropriately
  }

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => HabitDatabase()),
      ChangeNotifierProvider(create: (context) => ThemeProvider())
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
