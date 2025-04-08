// ignore_for_file: non_constant_identifier_names, camel_case_types, file_names

import 'package:flutter/material.dart';
import 'package:iitropar/database/event.dart';
import 'package:iitropar/database/loader.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:iitropar/views/homePage/student_home.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:iitropar/views/faculty/seeSlots.dart';

class studentsEnrolled extends StatefulWidget {
  final String course;
  const studentsEnrolled({super.key, required this.course});

  @override
  State<studentsEnrolled> createState() => _studentsEnrolledState();
}

class _studentsEnrolledState extends State<studentsEnrolled> {
  late List<List<dynamic>> studentList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getStudents();
  }

  void _getStudents() async {
    List<List<dynamic>> students =
    await firebaseDatabase.getStudentsWithName(widget.course);
    setState(() {
      studentList = students;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Students Enrolled"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : studentList.isEmpty
          ? const Center(child: Text("No students enrolled yet."))
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
          columns: const [
            DataColumn(label: Text("Roll No.", style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text("Name", style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: studentList.map((student) {
            return DataRow(cells: [
              DataCell(Text(student[0].toString())), // Roll Number
              DataCell(Text(student[1].toString())), // Name
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
