import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/services.dart';

class AcknowledgementScreen extends StatelessWidget {
  final Color appBarBackgroundColor;

  const AcknowledgementScreen({
    Key? key,
    required this.appBarBackgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        elevation: 0,
        backgroundColor: appBarBackgroundColor,
        title: const Text(
          "ACKNOWLEDGEMENTS",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
      backgroundColor: theme.colorScheme.secondary,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            // 🌓 Theme Toggle Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.brightness_6, color: Color(0xFFAD1457)),
                title: const Text("Dark Mode"),
                trailing: Switch(
                  activeColor: const Color(0xFFAD1457),
                  value: AdaptiveTheme.of(context).mode.isDark,
                  onChanged: (value) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Please restart the app"),
                          content: const Text("The theme has been changed. Please restart the app for changes to take effect."),
                          actions: [
                            TextButton(
                              child: const Text("Ok"),
                              onPressed: () {
                                if (value) {
                                  AdaptiveTheme.of(context).setDark();
                                } else {
                                  AdaptiveTheme.of(context).setLight();
                                }
                                Navigator.of(context).pop();
                                Future.delayed(const Duration(milliseconds: 200), () {
                                  SystemNavigator.pop();
                                });
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 🙌 Credits Section
            Expanded(
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                color: theme.cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: const [
                      Text(
                        "Project Credits",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFAD1457),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text("🔹 Developed as part of IIT Ropar's student initiatives."),
                      SizedBox(height: 10),
                      Text("🔹 Mentored by Dr. Puneet Goyal"),
                      SizedBox(height: 10),
                      Text("🔹 Contributors:"),
                      Padding(
                        padding: EdgeInsets.only(left: 12.0, top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("• Aditya Garg"),
                            Text("• Aayan Soni"),
                            Text("• Akash"),
                            Text("• Aniket Kumar Sahil"),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        "Thank you to everyone who supported the development of this project!",
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
