import 'package:flutter/material.dart';
import 'package:vaxi_track/app/app_colors.dart';
import 'package:vaxi_track/app/app_routes.dart';
import '../../dashboard/widgets/bottom_nav_bar.dart';

import '../widgets/settings_tile.dart';
import '../widgets/settings_section.dart';
import 'about_page.dart';
import 'profile_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notifications = true;
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(title: const Text("Settings"), centerTitle: true),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.person, size: 40),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Krish",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    "Cold Chain Administrator",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            const SettingsSection(title: "Profile"),

            SettingsTile(
              icon: Icons.person,
              title: "My Profile",
              subtitle: "View and edit profile",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
            ),

            const SettingsSection(title: "Preferences"),

            SettingsTile(
              icon: Icons.notifications,
              title: "Notifications",
              trailing: Switch(
                value: notifications,
                onChanged: (value) {
                  setState(() {
                    notifications = value;
                  });
                },
              ),
            ),

            SettingsTile(
              icon: Icons.dark_mode,
              title: "Dark Mode",
              trailing: Switch(
                value: darkMode,
                onChanged: (value) {
                  setState(() {
                    darkMode = value;
                  });
                },
              ),
            ),

            SettingsTile(
              icon: Icons.language,
              title: "Language",
              subtitle: "English",
            ),

            const SettingsSection(title: "About"),

            SettingsTile(
              icon: Icons.info,
              title: "About VaxiTrack",
              subtitle: "Version 1.0.0",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutPage()),
                );
              },
            ),
            SettingsTile(
              icon: Icons.privacy_tip,
              title: "Privacy Policy",
              subtitle: "Read our privacy policy",
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Privacy Policy coming soon")),
                );
              },
            ),

            SettingsTile(
              icon: Icons.description,
              title: "Terms & Conditions",
              subtitle: "Application terms of use",
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Terms & Conditions coming soon"),
                  ),
                );
              },
            ),

            const SettingsSection(title: "Account"),

            SettingsTile(
              icon: Icons.logout,
              title: "Logout",
              subtitle: "Sign out from VaxiTrack",
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text("Logout"),
                    content: const Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Logout feature coming soon"),
                            ),
                          );
                        },
                        child: const Text("Logout"),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavBar(
        currentIndex: 4,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
              break;

            case 1:
              Navigator.pushReplacementNamed(context, AppRoutes.devices);
              break;

            case 2:
              Navigator.pushReplacementNamed(context, AppRoutes.batches);
              break;

            case 3:
              Navigator.pushReplacementNamed(context, AppRoutes.alerts);
              break;

            case 4:
              break;
          }
        },
      ),
    );
  }
}
