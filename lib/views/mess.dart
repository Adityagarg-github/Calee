import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:iitropar/utilities/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';
import '../database/loader.dart';

class MessMenuPage extends StatefulWidget {
  final Color appBarBackgroundColor;

  const MessMenuPage({
    Key? key,
    required this.appBarBackgroundColor,
  }) : super(key: key);

  @override
  State<MessMenuPage> createState() => _MessMenuPageState();
}

class _MessMenuPageState extends State<MessMenuPage>
    with SingleTickerProviderStateMixin {
  final List<String> _daysOfWeek = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday'
  ];


  Map<String, List<MenuItem>> _menu = Menu.menu;
  String modifyDate = "Fetching...";

  @override
  void initState() {
    super.initState();
    loadMenuAndFetchLastModified();
  }

  Future<void> loadMenuAndFetchLastModified() async {
    await Menu.fetchMenu();
    setState(() {
      _menu = Menu.menu;
    });
    getLastModified();
  }

  Future<void> getLastModified() async {
    var doc = await FirebaseFirestore.instance.collection('menu').doc("modified").get();
    setState(() {
      modifyDate = doc.data()?["date"] ?? "Unknown Date";
    });
  }

  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'Mon'), Tab(text: 'Tue'), Tab(text: 'Wed'),
    Tab(text: 'Thu'), Tab(text: 'Fri'), Tab(text: 'Sat'), Tab(text: 'Sun'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: initialDay(),
      length: myTabs.length,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          elevation: 0,
          backgroundColor: widget.appBarBackgroundColor,
          title: _buildTitleBar("MESS MENU", context),
          bottom: const TabBar(
            labelColor: Colors.black,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
            unselectedLabelColor: Colors.white,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(color: Colors.white, width: 1.5),
              insets: EdgeInsets.symmetric(horizontal: 48),
            ),
            tabs: myTabs,
          ),
        ),
        body: TabBarView(
          children: _daysOfWeek.map((day) => _buildMenuList(day, modifyDate)).toList(),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _buildTitleBar(String text, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => loadMenuAndFetchLastModified(),
          icon: const Icon(Icons.sync_rounded),
          color: Colors.white,
          iconSize: 28,
        ),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        signoutButtonWidget(context),
      ],
    );
  }

  Widget _buildLastUpdatedWidget(String lastUpdatedDate) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.update, color: Colors.blue),
          const SizedBox(width: 10),
          Text(
            'Last Updated: $lastUpdatedDate',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(String day, String lastUpdatedDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLastUpdatedWidget(lastUpdatedDate),
        Expanded(
          child: ListView.builder(
            itemCount: _menu[day]?.length ?? 0,
            itemBuilder: (context, index) {
              final meal = _menu[day]![index];

              return Column(
                children: [
                  const SizedBox(height: 20),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 5,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ExpansionTile(
                      title: Text(
                        meal.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      leading: const Icon(Icons.food_bank_rounded),
                      subtitle: Text(checkTime(meal.name)),
                      initiallyExpanded: meal.name == mealOpen(),
                      children: _buildFoodItems(meal.description),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFoodItems(String description) {
    List<String> foodItems = description.split(", ").map((e) => e.trim()).toList();
    return foodItems.map((item) => ListTile(
      title: Text(item, style: TextStyle(color: Color(primaryLight))),
      leading: const Icon(Icons.check_circle, color: Colors.green),
    )).toList();
  }

  String mealOpen() {
    TimeOfDay now = TimeOfDay.now();
    if (now.hour <= 9 || now.hour >= 21) return "Breakfast";
    if (now.hour < 14 && now.hour > 9) return "Lunch";
    return "Dinner";
  }

  String checkTime(String name) {
    switch (name) {
      case 'Breakfast': return "7:30 AM to 9:15 AM";
      case 'Lunch': return "12:30 PM to 2:15 PM";
      default: return "7:30 PM to 9:15 PM";
    }
  }

  int initialDay() {
    DateTime now = DateTime.now();
    return now.weekday == 7 ? 0 : now.weekday - 1;
  }
}
