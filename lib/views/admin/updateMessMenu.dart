import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';  // For date formatting

class UpdateMessMenu extends StatefulWidget {
  const UpdateMessMenu({super.key});

  @override
  State<UpdateMessMenu> createState() => _UpdateMessMenuState();
}

class _UpdateMessMenuState extends State<UpdateMessMenu> {
  final List<String> days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
  final List<String> meals = ["breakfast", "lunch", "dinner"];

  String selectedDay = "Monday";  // Default day
  String selectedMeal = "breakfast"; // Default meal
  String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  TextEditingController menuController = TextEditingController();

  // Function to update menu in Firebase
  void updateMenu() async {
    String newMenu = menuController.text.trim();

    if (newMenu.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Menu cannot be empty!"))
      );
      return;
    }

    await FirebaseFirestore.instance.collection("menu").doc(selectedDay).set({
      selectedMeal: newMenu
    }, SetOptions(merge: true));

    await FirebaseFirestore.instance.collection("menu").doc("modified").set({
      "date": currentDate
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Mess menu updated successfully!"))
    );

    menuController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Update Mess Menu")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Day:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: selectedDay,
              items: days.map((day) {
                return DropdownMenuItem(value: day, child: Text(day));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDay = value!;
                });
              },
            ),

            SizedBox(height: 16),

            Text("Select Meal:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: selectedMeal,
              items: meals.map((meal) {
                return DropdownMenuItem(value: meal, child: Text(meal));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedMeal = value!;
                });
              },
            ),

            SizedBox(height: 16),

            TextField(
              controller: menuController,
              decoration: InputDecoration(
                labelText: "Enter New Menu Items",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: updateMenu,
              child: Text("Update Menu"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
