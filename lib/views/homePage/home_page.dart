import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:iitropar/views/homePage/club_home.dart';
import 'package:iitropar/views/homePage/faculty_home.dart';
import 'package:iitropar/views/homePage/student_home.dart';
import 'package:iitropar/utilities/firebase_database.dart';

import '../../database/loader.dart';

abstract class AbstractHome extends StatefulWidget {
  final Color appBarBackgroundColor; // New property for AppBar background color

  const AbstractHome({
    Key? key,
    required this.appBarBackgroundColor, // Constructor parameter for AppBar background color
  }) : super(key: key);
}

abstract class AbstractHomeState extends State<AbstractHome> {
  faculty f = faculty("name", "dep", "email", Set());
  void getDetails() async {
    if (FirebaseAuth.instance.currentUser != null) {
      f = await firebaseDatabase
          .getFacultyDetail(FirebaseAuth.instance.currentUser!.email!);
    }
    if (mounted) setState(() {});
  }

  AbstractHomeState() {
    getDetails();
  }

  CircleAvatar getUserImage(double radius) {
    ImageProvider image;
    //image = const AssetImage('assets/user.png');
    if (FirebaseAuth.instance.currentUser != null &&
        FirebaseAuth.instance.currentUser!.photoURL != null) {
      image =
          NetworkImage(FirebaseAuth.instance.currentUser!.photoURL.toString());
    } else {
      image = const AssetImage('assets/user.png');
    }
    return CircleAvatar(
      backgroundImage: image,
      radius: radius,
    );
  }

  String getUserName() {
    if (Ids.role.compareTo("faculty") == 0) {
      return "Welcome! ${f.name}";
    }
    if (FirebaseAuth.instance.currentUser == null) return "Hey! Guest User";
    if(Ids.role.compareTo("club") == 0){
      return "${FirebaseAuth.instance.currentUser!.displayName.toString()}";
    }
    return "Hey! ${FirebaseAuth.instance.currentUser!.displayName.toString()}";
  }

  List<Widget> buttons();

  Widget getText() {
    if (Ids.role.compareTo("faculty") == 0) {
      return Text(f.department,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: Color(primaryLight), // Set text color to blue
            fontSize: 18, // Set text size to 24// Set text font to bold
          ));
    }
    if(Ids.role.compareTo("club") == 0){
      return Text('',
          textAlign: TextAlign.right,
          style: TextStyle(
            color: Color(primaryLight), // Set text color to blue
            fontSize: 18, // Set text size to 24// Set text font to bold
          ));
    }
    return Text('How are you doing today? ',
        textAlign: TextAlign.right,
        style: TextStyle(
          color: Color(primaryLight), // Set text color to blue
          fontSize: 18, // Set text size to 24// Set text font to bold
        ));
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final iconSize = screenSize.width * 0.2;
    final textSize = screenSize.width * 0.8;

    return Scaffold(
      backgroundColor: Color(secondaryLight),
      appBar: AppBar(
        toolbarHeight: 50,
        elevation: 0,
        backgroundColor: widget.appBarBackgroundColor,
        title: buildTitleBar("HOME", context),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(children: [
                getUserImage(iconSize / 2 - 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        width: textSize,
                        child: Text('${getUserName()}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  Color(primaryLight), // Set text color to blue
                              fontSize: 22, // Set text size to 24
                              fontWeight:
                                  FontWeight.bold, // Set text font to bold
                            ))),
                    SizedBox(
                      width: textSize,
                      child: getText(),
                    )
                  ],
                ),
              ])), // Set text alignment to center
          Divider(
            color: Color(primaryLight),
            height: 30,
            thickness: 1,
            indent: 15,
            endIndent: 15,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Center(
                child: Column(
                  children: [
                    ...buttons(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget themeButtonWidget() {
    return IconButton(
      onPressed: () {
        
      },
      icon: const Icon(
        Icons.home,
      ),
      color: Color(primaryLight),
      iconSize: 28,
    );
  }

  TextStyle appbarTitleStyle() {
    return TextStyle(
        color: Color(primaryLight),
        // fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5);
  }

  Row buildTitleBar(String text, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const HomePage()));
          },
          icon: const Icon(Icons.sync_rounded),
          color: Colors.white, // Change to your preferred color
          iconSize: 28,
        ),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white, // Change to your preferred color
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        signoutButtonWidget(context),
      ],
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static String user = "guest";
  Future<bool> resolveUser() async {
    user = await Ids.resolveUser();
    return true;
  }

  Widget userScreen(BuildContext context) {
    if (user.compareTo('club') == 0) {
      return const ClubHome();
    } else if (user.compareTo('faculty') == 0) {
      return const FacultyHome();
    }
    return const StudentHome();
  }

  @override
  Widget build(BuildContext context) {
    LoadingScreen.setPrompt("Loading Home...");
    LoadingScreen.setTask(resolveUser);
    LoadingScreen.setBuilder(userScreen);
    return LoadingScreen.build(context);
  }
}
