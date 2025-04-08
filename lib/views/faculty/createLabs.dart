import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iitropar/utilities/firebase_database.dart';

class createLabs extends StatefulWidget {
  const createLabs({super.key});

  @override
  State<createLabs> createState() => _createLabsState();
}

class _createLabsState extends State<createLabs> {
  List<String> courseList = [];
  List<String> groupList = [];
  final List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

  String? selectedCourse;
  String? selectedGroup;
  String? selectedDay;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  final TextEditingController venueController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFacultyCourses();
  }

  Future<void> _loadFacultyCourses() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final faculty = await firebaseDatabase.getFacultyDetail(user.email!);
      setState(() {
        courseList = (faculty?.courses.where((c) => c != "None").toList() ?? []).cast<String>();
        isLoading = false;
      });
    }
  }

  Future<void> _loadGroupsForCourse(String courseCode) async {
    final doc = await FirebaseFirestore.instance
        .collection('coursecode')
        .doc(courseCode)
        .collection('meta')
        .doc('groups')
        .get();

    if (doc.exists) {
      final data = doc.data();
      if (data != null && data.containsKey('groups')) {
        setState(() {
          groupList = List<String>.from(data['groups']);
          selectedGroup = null;
        });
      }
    } else {
      setState(() {
        groupList = [];
        selectedGroup = null;
      });
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  Future<void> _submitLab() async {
    if (selectedCourse == null ||
        selectedGroup == null ||
        selectedDay == null ||
        startTime == null ||
        endTime == null ||
        venueController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final labRef = FirebaseFirestore.instance
        .collection('coursecode')
        .doc(selectedCourse)
        .collection(selectedGroup!)
        .doc('lab_info');

    await labRef.set({
      'day': selectedDay,
      'start_time': startTime!.format(context),
      'end_time': endTime!.format(context),
      'venue': venueController.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Lab scheduled successfully")),
    );

    setState(() {
      selectedDay = null;
      startTime = null;
      endTime = null;
      venueController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Lab")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              hint: const Text("Select Course"),
              value: selectedCourse,
              isExpanded: true,
              items: courseList.map((course) {
                return DropdownMenuItem(
                  value: course,
                  child: Text(course),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCourse = value;
                  selectedGroup = null;
                  groupList = [];
                });
                _loadGroupsForCourse(value!);
              },
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              hint: const Text("Select Group"),
              value: selectedGroup,
              isExpanded: true,
              items: groupList.map((group) {
                return DropdownMenuItem(
                  value: group,
                  child: Text(group),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedGroup = value;
                });
              },
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              hint: const Text("Select Day"),
              value: selectedDay,
              isExpanded: true,
              items: days.map((day) {
                return DropdownMenuItem(
                  value: day,
                  child: Text(day),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDay = value;
                });
              },
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => _pickTime(true),
                  child: Text("Start: ${startTime?.format(context) ?? 'Pick'}"),
                ),
                ElevatedButton(
                  onPressed: () => _pickTime(false),
                  child: Text("End: ${endTime?.format(context) ?? 'Pick'}"),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: venueController,
              decoration: const InputDecoration(
                labelText: "Enter Venue",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _submitLab,
                child: const Text("Submit Lab"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
