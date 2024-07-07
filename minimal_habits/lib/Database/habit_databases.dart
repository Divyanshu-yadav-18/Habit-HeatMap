import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:minimal_habits/Modal/app_setting.dart';
import 'package:minimal_habits/Modal/habit.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;
  /*

    S E T U P

  */

  // I N I T I A L I S I N G  D A T A B A S E
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [HabitSchema, AppSettingSchema],
      directory: dir.path,
    );
  }

  // save first date of app startup (for heatmap)
  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();
    if (existingSettings == null) {
      final settings = AppSetting()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  // Get first date of app startup (fo heatmap)
  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

  /*
    C R U D  O P E R A T I O N
  */

  //List of habits
  final List<Habit> currentHabit = [];

  //C R E A T E - add a new habit
  Future<void> addHabit(String habitName) async {
    //creat new habit
    final newHabit = Habit()..name = habitName;
    //save the habit
    await isar.writeTxn(() => isar.habits.put(newHabit));
    //re read
    readHabit();
  }

  //R E A D - read saved habits from db
  Future<void> readHabit() async {
    //fetch all habit from db
    List<Habit> fetchedHabits = await isar.habits.where().findAll();

    //give to current habit
    currentHabit.clear();
    currentHabit.addAll(fetchedHabits);

    notifyListeners();
  }

  // U P D A T E - check habit on and off

  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    //find the specific habit
    final habit = await isar.habits.get(id);

    //update completion staus
    if (habit != null) {
      await isar.writeTxn(() async {
        //if habit is completed ->add dateandtime to cpmpleted habit
        if (isCompleted && !habit.completedDays.contains(DateTime.now())) {
          //today
          final today = DateTime.now();
          //add current date if its not in list already

          habit.completedDays.add(
            DateTime(
              today.year,
              today.month,
              today.day,
            ),
          );
        }
        //if habit is not completed -> remove the current date from list
        else {
          habit.completedDays.removeWhere(
            (date) =>
                date.year == DateTime.now().year &&
                date.month == DateTime.now().month &&
                date.day == DateTime.now().day,
          );
        }
        //save updated habit to db
        await isar.habits.put(habit);
      });
    }
    //reread from db
    readHabit();
  }

  // U P D A T E - edit habit name
  Future<void> updateHabitName(int id, String newName) async {
    //find the specific habit
    final habit = await isar.habits.get(id);

    //update habit name
    if (habit != null) {
      await isar.writeTxn(() async {
        habit.name = newName;
        //save updated habit to db
        await isar.habits.put(habit);
      });
    }

    readHabit();
  }

  // D E L E T E - delete habit
  Future<void> deleteHabit(int id) async {
    await isar.writeTxn(() async {
      await isar.habits.delete(id);
    });
    readHabit();
  }
}
