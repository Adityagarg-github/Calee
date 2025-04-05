import 'package:flutter/material.dart';
import 'package:iitropar/utilities/firebase_database.dart';


class StudentsList extends StatefulWidget {
  final String course;
  const StudentsList({super.key, required this.course});

  @override
  State<StudentsList> createState() => _StudentsListState();
}

class _StudentsListState extends State<StudentsList> {
  List<List<dynamic>> studentList = [];
  Set<String> selectedRolls = {};
  final TextEditingController _groupNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getStudents();
  }

  void _getStudents() async {
    List<List<dynamic>> students = await firebaseDatabase.getStudentsWithName(widget.course);
    setState(() {
      studentList = students;
    });
  }

  void _createGroup() async {
    final groupName = _groupNameController.text.trim();
    if (groupName.isEmpty || selectedRolls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a group name and select students")),
      );
      return;
    }

    for (var student in selectedRolls) {
      await firebaseDatabase.addGroupToStudentCourse(
        roll: student,
        courseCode: widget.course,
        groupName: groupName,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Group '$groupName' created successfully")),
    );

    setState(() {
      selectedRolls.clear();
      _groupNameController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Assign Students to Group")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                labelText: "Enter Group Name",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: studentList.length,
              itemBuilder: (context, index) {
                final roll = studentList[index][0];
                final name = studentList[index][1];
                final isSelected = selectedRolls.contains(roll);

                return ListTile(
                  title: Text("$name ($roll)"),
                  trailing: Checkbox(
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedRolls.add(roll);
                        } else {
                          selectedRolls.remove(roll);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _createGroup,
            child: const Text("Create Group"),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
