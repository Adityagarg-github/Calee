// ignore_for_file: camel_case_types, non_constant_identifier_names
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:iitropar/utilities/firebase_services.dart';
import 'package:iitropar/views/landing_page.dart';
import 'package:intl/intl.dart';
import 'database/local_db.dart';

DateTime getTodayDateTime() {
  return DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day);
}

String TimeString(TimeOfDay t) {
  return "${t.hour}:${t.minute}";
}

TimeOfDay StringTime(String t) {
  List<String> t_split = t.split(':');
  return TimeOfDay(hour: int.parse(t_split[0]), minute: int.parse(t_split[1]));
}

List<String> allCourses = [
  'HS301',
  'CE403',
  'CE302',
  'CE405',
  'CE406',
  'CE407',
  'CP301',
  'CP302',
  'NO103',
  'CE602',
  'CE552',
  'HS505',
  'HS506',
  'HS507',
  'HS475',
  'HS406',
  'HS463',
  'HS405',
  'MA703',
  'MA628',
  'MA605',
  'MA424',
  'BM607',
  'BM609',
  'BM614',
  'BM612',
  'CY427',
  'CY452',
  'CY516',
  'CH304',
  'CH305',
  'CH331',
  'CH420',
  'CP301',
  'CP302',
  'NO103',
  'CH507',
  'CH506',
  'HS505',
  'HS506',
  'HS507',
  'HS475',
  'HS406',
  'HS463',
  'HS405',
  'MA703',
  'MA628',
  'MA605',
  'MA424',
  'PH451',
  'BM607',
  'BM609',
  'BM614',
  'BM612',
  'CY427',
  'CY452',
  'CY516',
  'CS304',
  'CS201',
  'CS305',
  'CS301',
  'CS306',
  'CS101',
  'CP301',
  'CP302',
  'NO103',
  'CS616',
  'CS517',
  'CS535',
  'CS539',
  'CS604',
  'CS503',
  'CS201',
  'CS533',
  'MA102',
  'CS543',
  'MA102',
  'CS546',
  'CS201',
  'CS550',
  'CS531',
  'CS204',
  'CS712',
  'CS603',
  'CS302',
  'CS536',
  'CS549',
  'CS521',
  'HS505',
  'HS506',
  'HS507',
  'HS475',
  'HS406',
  'HS463',
  'HS405',
  'MA703',
  'MA628',
  'MA605',
  'MA517',
  'MA421',
  'PH457',
  'BM607',
  'BM609',
  'BM614',
  'BM612',
  'CY427',
  'CY452',
  'CY516',
  'CP301',
  'EE309',
  'EE307',
  'EE306',
  'EE304',
  'EE308',
  'EE310',
  'HS104',
  'GE111',
  'CP302',
  'NO103',
  'HS505',
  'HS506',
  'HS507',
  'HS475',
  'HS406',
  'HS463',
  'HS405',
  'MA703',
  'MA628',
  'MA605',
  'MA517',
  'MA302',
  'MA421',
  'PH457',
  'PH451',
  'PH612',
  'BM607',
  'BM609',
  'BM614',
  'BM612',
  'CY427',
  'CY452',
  'CY516',
  'EE639',
  'EE628',
  'EE647',
  'EE536',
  'EE646',
  'EE661',
  'EE531',
  'CP301',
  'MA302',
  'MA303',
  'CS503',
  'CS201',
  'CP302',
  'NO103',
  'MA703',
  'MA628',
  'MA605',
  'MA516',
  'MA629',
  'HS505',
  'HS506',
  'HS507',
  'HS406',
  'HS463',
  'HS475',
  'HS405',
  'BM607',
  'BM609',
  'BM614',
  'BM612',
  'CY427',
  'CY452',
  'CY516',
  'ME304',
  'ME201',
  'ME305',
  'GE102',
  'ME306',
  'ME301',
  'ME307',
  'ME303',
  'ME308',
  'GE201',
  'CP301',
  'GE111',
  'HS104',
  'CP302',
  'NO103',
  'ME472',
  'ME504',
  'ME512',
  'ME515',
  'ME542',
  'ME576',
  'ME580',
  'ME505',
  'HS505',
  'HS506',
  'HS507',
  'HS406',
  'HS463',
  'HS475',
  'HS405',
  'MA703',
  'MA628',
  'MA605',
  'MA302',
  'MA424',
  'PH457',
  'PH451',
  'PH612',
  'BM607',
  'BM609',
  'BM614',
  'BM612',
  'CY427',
  'CY452',
  'CY516',
  'MM306',
  'MM307',
  'MM308',
  'MM309',
  'MM310',
  'MM311',
  'CP301',
  'GE111',
  'HS104',
  'CP302',
  'NO103',
  'MM431',
  'GE201',
  'HS505',
  'HS506',
  'HS507',
  'HS406',
  'HS463',
  'HS475',
  'HS405',
  'MA703',
  'MA628',
  'MA605',
  'MA424',
  'BM607',
  'BM609',
  'BM614',
  'BM612',
  'CY427',
  'CY452',
  'CY516'
];
List<DropdownMenuItem<String>> departments = [
  const DropdownMenuItem(
      value: "BioMedical Engineering", child: Text("BioMedical Engineering")),
  const DropdownMenuItem(
      value: "Chemical Engineering", child: Text("Chemical Engineering")),
  const DropdownMenuItem(
      value: "Civil Engineering", child: Text("Civil Engineering")),
  const DropdownMenuItem(
      value: "Electrical Engineering", child: Text("Electrical Engineering")),
  const DropdownMenuItem(
      value: "Computer Science & Engineering",
      child: Text("Computer Science & Engineering")),
  const DropdownMenuItem(
      value: "Metallurgical and Materials Engineering",
      child: Text("Metallurgical and Materials Engineering")),
  const DropdownMenuItem(value: "Chemistry", child: Text("Chemistry")),
  const DropdownMenuItem(value: "Physics", child: Text("Physics")),
  const DropdownMenuItem(value: "Mathematics", child: Text("Mathematics")),
  const DropdownMenuItem(
      value: "Humanities and Social Sciences",
      child: Text("Humanities and Social Sciences")),
  const DropdownMenuItem(
      value: "Mechanical Engineering", child: Text("Mechanical Engineering")),
  const DropdownMenuItem(value: "other", child: Text("other")),
];
String dateString(DateTime d) {
  return DateFormat('yyyy-MM-dd').format(d);
}

DateTime stringDate(String d) {
  int year = int.parse(d.substring(0, 4));
  int month = int.parse(d.substring(5, 7));
  int day = int.parse(d.substring(8, 10));
  return DateTime(year, month, day);
}

class holidays {
  late DateTime date;
  late String desc;
  holidays(date, this.desc) {
    this.date = DateFormat('yyyy-MM-dd').parse(date);
  }
}

class semesterDur {
  DateTime? startDate;
  DateTime? endDate;
}

class changedDay {
  late DateTime date;
  late String day_to_followed;
  changedDay(date, this.day_to_followed) {
    this.date = DateFormat('yyyy-MM-dd').parse(date);
  }
}

class faculty {
  late String name;
  late String department;
  late String email;
  late Set<dynamic> courses;
  faculty(email, name, dep, courses) {
    this.name = name;
    this.department = dep;
    this.email = email;
    this.courses = courses;
  }
}

class Ids {
  static List<String> admins = [
    "tempv9999@gmail.com",
    "adityagarg.07052004@gmail.com",
    "depiitrpr1@gmail.com"
  ];
  static Future<List<dynamic>> fclub = firebaseDatabase.getClubIds();
  static Future<List<dynamic>> faculty = firebaseDatabase.getFacultyIDs();

  static String role = "guest";
  static bool assigned = false;
  static String name = ""; //only for faculty
  static String dep = ""; //only for faculty

  static Future<String> resolveUser() async {
    if (assigned == true) return role;
    String user;
    if (FirebaseAuth.instance.currentUser == null) {
      user = "guest";
      role = user;
      assigned = true;
      return role;
    }
    return _emailCheck(FirebaseAuth.instance.currentUser!.email!);
  }

  static Future<String> _emailCheck(String email) async {
    String check1 = await firebaseDatabase.emailCheck(email);

    if(email=="2022csb1062@iitrpr.ac.in"){
      role = "student";
      assigned = true;
      return "student";
    }

    if (check1 != "") {
      role = check1;
      assigned = true;
      return check1;
    }

    if (email.endsWith("iitrpr.ac.in")) {
      role = "student";
      assigned = true;
      return "student";
    }

    assigned = true;
    return "guest";
  }
}

class MenuItem {
  String name;
  String description;

  MenuItem(this.name, this.description);
}

class Menu {
  static Map<String, List<MenuItem>> menu = {
    'Monday': [
      MenuItem('Breakfast',
          'Aloo Pyaz Paratha,Ketchup,Pickle,Sprouts,Bournvita&Coffee,Bread,Butter,Jam,Milk,Tea'),
      MenuItem('Lunch',
          'Veg Biryani/Egg Biryani,Chana Dal,Mix Raita,Chapati,Salad'),
      MenuItem('Dinner',
          'Aloo Black Chana,Puri,Black Masur Dal,Rice,Chapati,Salad,Boondi Ladoo')
    ],
    'Tuesday': [
      MenuItem('Breakfast',
          'Uttapam,Sambhar,Red Coconut Chutney,Banana(2 Nos),Cornflakes,Bournvita&Coffee,Bread,Butter,Jam,Milk,Tea'),
      MenuItem(
          'Lunch', 'Rajma,Lauki Chana,Curd (200gm),Rice,Chapati,Salad'),
      MenuItem(
          'Dinner', 'Aloo Baingan,Arhar Dal,Rice,Chapati,Salad,Seviyan/Badam milk')
    ],
    'Wednesday': [
      MenuItem('Breakfast',
          'Pav Bhaji,Puri,Khichdi,Ketchup/Pickle,Banana/Boiled Eggs(2 Nos),Bournvita&Coffee,Bread,Butter,Jam,Milk,Tea'),
      MenuItem('Lunch',
          'Kadhi Pakoda,Jeera Aloo,Fryums/Papad,Jeera Rice,Chapati,Salad'),
      MenuItem('Dinner',
          'Kadhai Paneer/Chicken Curry,Green Sabut Moong,Rice,Chapati,Salad,Gulab Jamun')
    ],
    'Thursday': [
      MenuItem('Breakfast',
          'Idli Vada,Sambhar,Red Coconut Chutney,Sprouts,Bournvita&Coffee,Bread,Butter,Jam,Milk,Tea'),
      MenuItem('Lunch',
          'Masala Pumpkin,Lobia Dal,Fruit Raita,Rice,Chapati,Salad'),
      MenuItem('Dinner',
          'Lauki Kofta,Moong Dal,Rice,Chapati,Salad,Seviyan/Badam Milk')
    ],
    'Friday': [
      MenuItem('Breakfast',
          'Mix Paratha,Ketchup,Pickle,Sprouts,BournVita&Coffee,Bread,Butter,Jam,Milk,Tea'),
      MenuItem(
          'Lunch', 'Black Chana Curry,Bhindi Aloo Masala,Veg Raita,Rice,Chapati,Salad'),
      MenuItem(
          'Dinner', 'Amritsari Chole,Moth Dal,Rice,Chapati,Salad,Sooji Halwa')
    ],
    'Saturday': [
      MenuItem('Breakfast',
          'Poha,Ketchup,Dalia,Omelette/Banana(2 Nos),Bournvita&Coffee,Bread,Butter,Jam,Milk,Tea'),
      MenuItem('Lunch',
          'White Chana,Aloo-Capsicum,Bhatura,Green Chutney,Boondi Raita,Rice,Chapati,Salad'),
      MenuItem('Dinner',
          'Mix Dal,Soya Badi/Dum-Aloo,Pulao,Chapati,Salad,Rice Kheer')
    ],
    'Sunday': [
      MenuItem('Breakfast',
          'Dosa,Sambhar,Red Coconut Chutney,Banana/Boiled Eggs(2 Nos),Bournvita&Coffee,Bread,Butter,Jam,Milk,Tea'),
      MenuItem('Lunch',
          'Dal Makhani,Masala Beans,Curd(200 grams),Rice,Chapati,Salad'),
      MenuItem('Dinner',
          'Paneer Do Pyaza/Butter Chicken,Black Urad Dal,Chapati,Rice,Salad,Ice cream (2 scoops)')
    ]
  };

  static Future<void> loadMenu() async {
    try {
      Map<String, Map<String, dynamic>> fetchedMenu = await firebaseDatabase.getFullMenu();

      Map<String, List<MenuItem>> tempMenu = {};
      fetchedMenu.forEach((day, meals) {
        tempMenu[day] = [
          MenuItem("Breakfast", meals["breakfast"] ?? ""),
          MenuItem("Lunch", meals["lunch"] ?? ""),
          MenuItem("Dinner", meals["dinner"] ?? ""),
        ];
      });

      menu = tempMenu; // Update the static menu
    } catch (e) {
      print("Error loading menu");
    }
  }
  static Future<Map<String, List<MenuItem>>> fetchMenu() async {
    await loadMenu(); // Fetch data from Firebase
    return menu; // Return the updated menu
  }
}

Widget AdminCard(BuildContext context, Widget route, String text) {
  return CupertinoButton(
    child: Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(primaryLight),
            // Colors.amber,
            Colors.black.withOpacity(0.69)
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    ),
    onPressed: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => route));
    },
  );
}

class LoadingScreen {
  static Future<bool> Function()? _task;
  static String? _msg;
  static Widget Function(BuildContext) _builder =
      (context) => const Placeholder();

  LoadingScreen._privatConstructor();

  static void setPrompt(String message) {
    _msg = message;
  }

  static void setTask(Future<bool> Function() task) {
    _task = task;
  }

  static void setBuilder(Widget Function(BuildContext context) builder) {
    _builder = builder;
  }

  static bool isLoaded = false;

  static Widget build(BuildContext context) {
    return FutureBuilder(
      future: _task!(),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Column(
            children: [
              Expanded(
                child: Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //const CircularProgressIndicator(),
                        Image.asset(
                          'assets/iitropar_logo.png',
                          height: 200,
                        ),
                        const SizedBox(
                          height: 5,
                          width: 100,
                          child: LinearProgressIndicator(
                            minHeight: 2,
                            backgroundColor: Colors.grey,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blueGrey),
                          ),
                        ),
                        Text((_msg != null) ? _msg! : 'Loading...'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return _builder(context);
        }
      },
    );
  }
}

Future<bool> _signout() async {
  if (Ids.role == 'student') {
    await EventDB().deleteOf('course');
    await EventDB().deleteOf('exam');
  } else if (Ids.role == 'faculty') {
    await EventDB().deleteOf('course');
  }
  await FirebaseServices().signOut();
  return true;
}

Widget signoutButtonWidget(BuildContext context) {
  return IconButton(
    icon: const Icon(Icons.logout),
    color: Colors.white,
    iconSize: 28,
    onPressed: () {
      _showConfirmationDialog(context);
    },
  );
}

Future<void> _showConfirmationDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              LoadingScreen.setTask(_signout);
              LoadingScreen.setPrompt('Signing Out');
              LoadingScreen.setBuilder((context) => const RootPage());
              RootPage.signin(true);

              Navigator.of(context).pop();
              Navigator.of(context, rootNavigator: true).pushReplacement(
                  MaterialPageRoute(
                      builder: LoadingScreen.build,
                      settings: const RouteSettings(name: '/')));
            },
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('No'),
          ),
        ],
      );
    },
  );
}

// Widget themeButtonWidget() {
//   return IconButton(
//     onPressed: () async {
//         if ((await Ids.resolveUser()).compareTo('student') == 0) {
//           var cl = await firebaseDatabase.getCourses(
//               FirebaseAuth.instance.currentUser!.email!.split('@')[0]);
//           await Loader.saveCourses(cl);
//           await Loader.loadMidSem(
//             DateTime(2023, 2, 27),
//             const TimeOfDay(hour: 9, minute: 30),
//             const TimeOfDay(hour: 12, minute: 30),
//             const TimeOfDay(hour: 14, minute: 30),
//             const TimeOfDay(hour: 16, minute: 30),
//             cl,
//           );
//         } else if ((await Ids.resolveUser()).compareTo('faculty') == 0) {
//           var fd = await firebaseDatabase
//               .getFacultyDetail(FirebaseAuth.instance.currentUser!.email!);
//           List<String> cl = List.from(fd.courses);
//           await Loader.saveCourses(cl);
//         }

//     },
//     icon: const Icon(
//       Icons.sync_rounded,
//     ),
//     color: Color(primaryLight),
//     iconSize: 28,
//   );
// }

// TextStyle appbarTitleStyle() {
//   return TextStyle(
//       color: Color(primaryLight),
//       // fontSize: 24,
//       fontWeight: FontWeight.bold,
//       letterSpacing: 1.5);
// }

// Row buildTitleBar(String text, BuildContext context) {
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       themeButtonWidget(),
//       Flexible(
//         child: SizedBox(
//           height: 30,
//           child: FittedBox(
//             child: Text(
//               text,
//               style: appbarTitleStyle(),
//             ),
//           ),
//         ),
//       ),
//       signoutButtonWidget(context),
//     ],
//   );
// }

class ExtraClass {
  String venue;
  String description;
  String courseID;
  DateTime date;
  TimeOfDay startTime;
  TimeOfDay endTime;
  ExtraClass(
      {required this.courseID,
      required this.date,
      required this.startTime,
      required this.endTime,
      required this.description,
      required this.venue});
}

class formChecks {
  static bool isbeforeDate(DateTime d1, DateTime d2) {
    DateTime _d1 = DateTime(d1.year, d1.month, d1.day);
    DateTime _d2 = DateTime(d2.year, d2.month, d2.day);
    return _d1.isBefore(_d2); // returns true if d1 before d2
  }

  static bool beforeCurDate(DateTime d) {
    DateTime _d = DateTime(d.year, d.month, d.day);
    DateTime cur_day =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return _d.isBefore(cur_day);
  }

  static bool email_check(String email) {
    RegExp r = RegExp(r'^[A-Za-z0-9._%+-]+@iitrpr\.ac\.in$');
    return r.hasMatch(email);
  }
}

String formatDateWord(DateTime date) {
  final formatter = DateFormat('dd MMM yyyy', 'en_US');
  return formatter.format(date);
}

