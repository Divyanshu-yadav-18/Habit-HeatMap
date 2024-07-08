import 'package:flutter/material.dart';
import 'package:minimal_habits/Components/Drawer.dart';
import 'package:minimal_habits/Components/habit_tile.dart';
import 'package:minimal_habits/Components/hear_map.dart';
import 'package:minimal_habits/Database/habit_databases.dart';
import 'package:minimal_habits/Modal/habit.dart';
import 'package:minimal_habits/utilities/habit_utilities.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    Provider.of<HabitDatabase>(context, listen: false).readHabit();
    super.initState();
  }

  final TextEditingController textController = TextEditingController();

  void createNewHabit() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textController,
                decoration:
                    const InputDecoration(hintText: "Enter Your New Habit"),
              ),
              actions: [
                //save button
                MaterialButton(
                  onPressed: () {
                    //get new habit
                    String newHabitName = textController.text;

                    //save to database
                    context.read<HabitDatabase>().addHabit(newHabitName);

                    //pop the box
                    Navigator.pop(context);

                    textController.clear();
                  },
                  child: const Text('Save'),
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    textController.clear();
                  },
                  child: const Text('Cancel'),
                )
              ],
            ));
  }

  void checkHabitOnAndOff(bool? value, Habit habit) {
    if (value != null) {
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  void deleteHabitBox(Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are You Sure To Delete'),
        actions: [
          //delete button
          MaterialButton(
            onPressed: () {
              //save to database
              context.read<HabitDatabase>().deleteHabit(habit.id);

              //pop the box
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          )
        ],
      ),
    );
  }

  void editHabitBox(Habit habit) {
    textController.text = habit.name;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              //get new habit
              String newHabitName = textController.text;

              //save to database
              context
                  .read<HabitDatabase>()
                  .updateHabitName(habit.id, newHabitName);

              //pop the box
              Navigator.pop(context);

              textController.clear();
            },
            child: const Text('Save'),
          ),
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
              textController.clear();
            },
            child: const Text('Cancel'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.primary,
        ),
        drawer: const MyDrawer(),
        floatingActionButton: FloatingActionButton(
          onPressed: createNewHabit,
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          child: const Icon(
            Icons.add,
          ),
        ),
        body: ListView(
          children: [
            //H E A T M A P
            _buildHeatMap(),

            //H A B I T L I S T
            _buildHabitlist(),
          ],
        ));
  }

//heat map
  Widget _buildHeatMap() {
    //habit db
    final habitDatabase = context.watch<HabitDatabase>();

    //current habit
    List<Habit> currentHabits = habitDatabase.currentHabit;

    //return heatmap UI
    return FutureBuilder<DateTime?>(
        future: habitDatabase.getFirstLaunchDate(),
        builder: (context, snapshot) {
          //once the data is available build heatmap
          if (snapshot.hasData) {
            return MyHeatMap(
              startDate: snapshot.data!,
              datasets: prepHeatMapDataset(currentHabits),
            );
          } else {
            return Container();
          }
        });
  }

//habit list
  Widget _buildHabitlist() {
    //habit db
    final habitDatabase = context.watch<HabitDatabase>();

    //create list
    List<Habit> currentHabits = habitDatabase.currentHabit;

    return ListView.builder(
        itemCount: currentHabits.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          //get each individual habit
          final habit = currentHabits[index];

          //check if habit is completed
          bool isCompletedToday = isHabitCompletedToday(habit.completedDays);

          return MyHabitTile(
            text: habit.name,
            isCompleted: isCompletedToday,
            onChanged: (value) => checkHabitOnAndOff(value, habit),
            editHabit: (context) => editHabitBox(habit),
            deleteHabit: (context) => deleteHabitBox(habit),
          );
        });
  }
}
