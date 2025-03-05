import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iitropar/frequently_used.dart';
import 'package:iitropar/utilities/colors.dart';
import 'package:iitropar/views/event_calendar.dart';
import 'package:iitropar/views/events.dart';
import 'package:iitropar/views/homePage/home_page.dart';
import 'package:iitropar/views/mess.dart';
import 'package:iitropar/views/quicklinks.dart';
import 'package:iitropar/views/groups.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'homePage/admin_page.dart';

class MainLandingPage extends StatelessWidget {
  const MainLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      screens: _buildScreens(),
      items: _navbarItems(),
      navBarStyle: NavBarStyle.style9,
      backgroundColor: Color(secondaryLight),
      screenTransitionAnimation: const ScreenTransitionAnimation(
          animateTabTransition: false,
          duration: Duration(seconds: 1),
          curve: Curves.ease),
    );
  }

  List<Widget> _buildScreens() {
    if (Ids.role == "admin") {
      return [
        const AdminHomePage(),
        const EventCalendarScreen(appBarBackgroundColor: Color(0xFF0D47A1)),
        const Events(appBarBackgroundColor: Color(0xFF0D47A1)),
        const MessMenuPage(appBarBackgroundColor: Color(0xFF0D47A1)),
        const QuickLinks(appBarBackgroundColor: Color(0xFF0D47A1))
      ];
    }
    else if (Ids.role == "faculty") {
      return [
        const HomePage(),
        const EventCalendarScreen(appBarBackgroundColor: Color(0xFFAD1457)),
        const Events(appBarBackgroundColor: Color(0xFFAD1457)),
        const MessMenuPage(appBarBackgroundColor: Color(0xFFAD1457)),
        const QuickLinks(appBarBackgroundColor: Color(0xFFAD1457))
      ];
    }
    else if (Ids.role == "club") {
      return [
        const HomePage(),
        const EventCalendarScreen(appBarBackgroundColor: Color(0xFF32A83C)),
        const Events(appBarBackgroundColor: Color(0xFF32A83C)),
        const MessMenuPage(appBarBackgroundColor: Color(0xFF32A83C)),
        const QuickLinks(appBarBackgroundColor: Color(0xFF32A83C))
      ];
    }
    else {
      return [
        const HomePage(),
        const EventCalendarScreen(appBarBackgroundColor: Color(0xFF42A5F5)),
        const Events(appBarBackgroundColor: Color(0xFF42A5F5)),
        const Groups(),
        const MessMenuPage(appBarBackgroundColor: Color(0xFF42A5F5)),
        const QuickLinks(appBarBackgroundColor: Color(0xFF42A5F5))
      ];
    }
  }

  List<PersistentBottomNavBarItem> _navbarItems() {
    if(Ids.role == "admin") {
      return [
        PersistentBottomNavBarItem(
            icon: const Icon(CupertinoIcons.home),
            title: 'Home',
            activeColorPrimary: Color(primaryLight),
            inactiveColorPrimary: Colors.grey[400]),
        PersistentBottomNavBarItem(
            icon: const Icon(CupertinoIcons.calendar),
            title: 'Calendar',
            activeColorPrimary: Color(primaryLight),
            inactiveColorPrimary: Colors.grey[400]),
        PersistentBottomNavBarItem(
            icon: const Icon(Icons.event),
            title: 'Events',
            activeColorPrimary: Color(primaryLight),
            inactiveColorPrimary: Colors.grey[400]),
        PersistentBottomNavBarItem(
            icon: const Icon(Icons.food_bank_rounded),
            title: 'Mess Menu',
            activeColorPrimary: Color(primaryLight),
            inactiveColorPrimary: Colors.grey[400]),
        PersistentBottomNavBarItem(
            icon: const Icon(CupertinoIcons.link),
            title: 'Quick Links',
            activeColorPrimary: Color(primaryLight),
            inactiveColorPrimary: Colors.grey[400]),
      ];
    }
    else if(Ids.role == "faculty" || Ids.role == "club") {
      return [
        PersistentBottomNavBarItem(
            icon: const Icon(CupertinoIcons.home),
            title: 'Home',
            activeColorPrimary: Color(primaryLight),
            inactiveColorPrimary: Colors.grey[400]),
        PersistentBottomNavBarItem(
            icon: const Icon(CupertinoIcons.calendar),
            title: 'Calendar',
            activeColorPrimary: Color(primaryLight),
            inactiveColorPrimary: Colors.grey[400]),
        PersistentBottomNavBarItem(
            icon: const Icon(Icons.event),
            title: 'Events',
            activeColorPrimary: Color(primaryLight),
            inactiveColorPrimary: Colors.grey[400]),
        PersistentBottomNavBarItem(
            icon: const Icon(Icons.food_bank_rounded),
            title: 'Mess Menu',
            activeColorPrimary: Color(primaryLight),
            inactiveColorPrimary: Colors.grey[400]),
        PersistentBottomNavBarItem(
            icon: const Icon(CupertinoIcons.link),
            title: 'Quick Links',
            activeColorPrimary: Color(primaryLight),
            inactiveColorPrimary: Colors.grey[400]),
      ];
    }
    return [
      PersistentBottomNavBarItem(
          icon: const Icon(CupertinoIcons.home),
          title: 'Home',
          activeColorPrimary: Color(primaryLight),
          inactiveColorPrimary: Colors.grey[400]),
      PersistentBottomNavBarItem(
          icon: const Icon(CupertinoIcons.calendar),
          title: 'Calendar',
          activeColorPrimary: Color(primaryLight),
          inactiveColorPrimary: Colors.grey[400]),
      PersistentBottomNavBarItem(
          icon: const Icon(Icons.event),
          title: 'Events',
          activeColorPrimary: Color(primaryLight),
          inactiveColorPrimary: Colors.grey[400]),
      PersistentBottomNavBarItem(
          icon: const Icon(Icons.group),
          title: 'Groups',
          activeColorPrimary: Color(primaryLight),
          inactiveColorPrimary: Colors.grey[400]),
      PersistentBottomNavBarItem(
          icon: const Icon(Icons.food_bank_rounded),
          title: 'Mess Menu',
          activeColorPrimary: Color(primaryLight),
          inactiveColorPrimary: Colors.grey[400]),
      PersistentBottomNavBarItem(
          icon: const Icon(CupertinoIcons.link),
          title: 'Quick Links',
          activeColorPrimary: Color(primaryLight),
          inactiveColorPrimary: Colors.grey[400]),
    ];
  }
}
