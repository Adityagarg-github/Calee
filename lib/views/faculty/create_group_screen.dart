import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iitropar/database/event.dart';
import 'package:iitropar/database/loader.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:iitropar/views/homePage/student_home.dart';
import 'package:iitropar/views/homePage/home_page.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:iitropar/views/faculty/seeSlots.dart';


import 'package:flutter/material.dart';
import 'package:iitropar/frequently_used.dart'; // Import f

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  faculty? f;
  String? selectedCourse;
  bool isLoading = true;

  List<Color> colors = [
    const Color(0xFF566e7a),
    const Color(0xFF161a26),
    const Color(0xFF599d70),
    const Color(0xFF3367d5),
    const Color(0xFFf9a61a)
  ];

  @override
  void initState() {
    super.initState();
    _loadFacultyData();
  }

  Future<void> _loadFacultyData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      f = await firebaseDatabase.getFacultyDetail(user.email!);
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Group")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : f == null
          ? const Center(child: Text("Failed to load faculty data"))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Course",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: f!.courses.length,
                itemBuilder: (context, index) {
                  final course = f!.courses.elementAt(index);
                  if (course == "None") return Container();
                  final colorIndex = index % colors.length;
                  final isSelected = selectedCourse == course;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCourse = course;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: isSelected ? Colors.amber : colors[colorIndex],
                        border: isSelected
                            ? Border.all(color: Colors.black, width: 2)
                            : null,
                      ),
                      child: ListTile(
                        title: Text(
                          course,
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: Colors.white)
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Current Groups",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: selectedCourse == null
                  ? null
                  : () {
                // TODO: Handle group creation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Group created for $selectedCourse')),
                );
              },
              child: const Text("Create Group"),
            ),
          ],
        ),
      ),
    );
  }
}
