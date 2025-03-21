import 'package:flutter/material.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:iitropar/views/faculty/findSlot.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/views/faculty/scheduleCourse.dart';
import 'package:iitropar/views/faculty/showClasses.dart';
import '../../utilities/colors.dart';
import 'home_page.dart';
import 'package:iitropar/views/faculty/studentsEnrolled.dart';

class FacultyHome extends AbstractHome {
  const FacultyHome({Key? key})
      : super(
    key: key,
    appBarBackgroundColor: const Color(0xFFAD1457),
  );

  @override
  State<AbstractHome> createState() => _FacultyHomeState();
}

class _FacultyHomeState extends AbstractHomeState {
  semesterDur? sm;
  List<Color> colors = [
    const Color(0xFF566e7a),
    const Color(0xFF161a26),
    const Color(0xFF599d70),
    const Color(0xFF3367d5),
    const Color(0xFFf9a61a)
  ];
  void getSemesterDur() async {
    sm = await firebaseDatabase.getSemDur();
    if (mounted) setState(() {});
  }

  Widget allCourses() {
    getSemesterDur();
    List<dynamic> coursesList = f.courses.toList();
    if (coursesList.isEmpty) {
      return const Text('Contact Admin for addition of courses');
    }
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xff555555),
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            blurStyle: BlurStyle.outer,
            color: Color(primaryLight),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              "Your Courses",
              style: TextStyle(
                  color: Color(primaryLight),
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SingleChildScrollView(
            child: SizedBox(
              height: 150,
              child: ListView.builder(
                // shrinkWrap: true,
                // physics: NeverScrollableScrollPhysics(),
                itemCount: coursesList.length,
                itemBuilder: (BuildContext context, int index) {
                  if (coursesList[index] == "None") return Container();
                  final colorIndex = index % colors.length;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              studentsEnrolled(course: coursesList[index]),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        //color: Colors.black,
                        color: colors[colorIndex],
                      ),
                      child: ListTile(
                        title: Text(
                          coursesList[index],
                          style: TextStyle(color: Color(secondaryLight)),
                          //style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const Text(
            "To add new course, contact Admin",
            overflow: TextOverflow.fade,
          ),
        ],
      ),
    );
  }

  @override
  List<Widget> buttons() {
    List<Widget> l = List.empty(growable: true);

    l.add(
      Container(
        width: double.infinity,
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Semester Start Date',
            ),
            SizedBox(height: 4.0),
            Text(
              '${sm == null ? '' : formatDateWord(sm!.startDate!)}',
            ),
            SizedBox(height: 8.0),
            Text(
              'Semester End Date',
            ),
            SizedBox(height: 4.0),
            Text(
              '${sm == null ? '' : formatDateWord(sm!.endDate!)}',
            ),
          ],
        ),
      ),
    );
    l.add(allCourses());
    l.add(
      const SizedBox(
        height: 10,
      ),
    );
    l.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Card(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => findSlots(f.courses),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: const [
                      Icon(Icons.check_circle_outline),
                      SizedBox(height: 8.0),
                      Text(
                        'Check Free Slots',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Card(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseSchedule(courses: f.courses),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: const [
                      Icon(Icons.calendar_today),
                      SizedBox(height: 8.0),
                      Text(
                        'Schedule Extra Class',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    l.add(
      const SizedBox(
        height: 5,
      ),
    );
    l.add(
      Center(
        child: Card(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyClass(courses: f.courses),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.list),
                  SizedBox(height: 8.0),
                  Text(
                    'See added extra classes',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return l;
  }
}
