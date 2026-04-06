import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'edit_profile_page.dart';
import 'settings_page.dart';
import 'help_support_page.dart';
import 'admin_panel_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade100,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data =
              snapshot.data!.data() as Map<String, dynamic>? ?? {};

          final name = data['name'] ?? "User";
          final email = data['email'] ?? user.email ?? "";
          final image = data['profileImage'] ?? "";

          return SingleChildScrollView(
            child: Column(
              children: [

                // 🔥 HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 60, bottom: 30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [Colors.grey.shade900, Colors.black]
                          : [const Color(0xFF3A7BD5), const Color(0xFF00D2FF)],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [

                      CircleAvatar(
                        radius: 50,
                        backgroundImage: image.isNotEmpty
                            ? NetworkImage(image)
                            : const AssetImage("assets/profpic.png")
                        as ImageProvider,
                      ),

                      const SizedBox(height: 12),

                      Text(name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),

                      Text(email,
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔥 STATS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStat("2", "Reported", isDark),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStat("1", "Helped", isDark),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔥 ACTIONS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [

                      _buildTile(
                        Icons.person,
                        "Edit Profile",
                        "Update your info",
                            () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => EditProfilePage()),
                        ),
                        isDark,
                      ),

                      _buildTile(
                        Icons.settings,
                        "Settings",
                        "App preferences",
                            () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SettingsPage()),
                        ),
                        isDark,
                      ),

                      _buildTile(
                        Icons.help,
                        "Help & Support",
                        "Get help",
                            () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                              const HelpSupportPage()),
                        ),
                        isDark,
                      ),

                      // 🔥 LOGOUT
                      _buildTile(
                        Icons.logout,
                        "Logout",
                        "Sign out from account",
                            () async {
                          await FirebaseAuth.instance.signOut();
                        },
                        isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔥 ADMIN BUTTON
                if (data['role'] == "admin")
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AdminPanelPage()),
                        );
                      },
                      child: const Text("Admin Panel"),
                    ),
                  ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🔹 STAT
  Widget _buildStat(String value, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black)),
          Text(label),
        ],
      ),
    );
  }

  // 🔹 TILE
  Widget _buildTile(
      IconData icon,
      String title,
      String subtitle,
      VoidCallback onTap,
      bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.blue),
        title: Text(title,
            style: TextStyle(
                color: isDark ? Colors.white : Colors.black)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}