import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool chatNotifications = true;
  bool itemAlerts = true;

  @override
  Widget build(BuildContext context) {
    final bool isDark = MyApp.of(context)?.isDark ?? false;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Settings",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          // 🔹 ACCOUNT SECURITY
          _sectionTitle("Account Security", isDark),
          _tile(
            icon: Icons.lock_outline_rounded,
            title: "Change Password",
            color: Colors.orange,
            isDark: isDark,
            onTap: () async {
              await FirebaseAuth.instance.sendPasswordResetEmail(
                email: FirebaseAuth.instance.currentUser!.email!,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Password reset email sent")),
              );
            },
          ),

          // 🔹 APPEARANCE
          _sectionTitle("Appearance", isDark),

          _switchTile(
            icon: Icons.dark_mode_rounded,
            title: "Dark Mode",
            value: isDark,
            color: Colors.deepPurple,
            isDark: isDark,
            onChanged: (val) {
              MyApp.of(context)?.toggleTheme(); // global theme toggle
            },
          ),

          // 🔹 NOTIFICATIONS
          _sectionTitle("Notifications", isDark),
          _switchTile(
            icon: Icons.chat_bubble_outline_rounded,
            title: "Chat Notifications",
            value: chatNotifications,
            color: Colors.green,
            isDark: isDark,
            onChanged: (val) => setState(() => chatNotifications = val),
          ),
          _switchTile(
            icon: Icons.notifications_none_rounded,
            title: "Item Alerts",
            value: itemAlerts,
            color: Colors.purple,
            isDark: isDark,
            onChanged: (val) => setState(() => itemAlerts = val),
          ),

          // 🔹 PRIVACY & CHAT
          _sectionTitle("Privacy & Chat", isDark),
          _tile(
            icon: Icons.chat_bubble_outline_rounded,
            title: "Chat Settings",
            subtitle: "Privacy, Media, History",
            color: Colors.teal,
            isDark: isDark,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Chat settings coming soon")),
              );
            },
          ),
          _tile(
            icon: Icons.block,
            title: "Blocked Users",
            color: Colors.redAccent,
            isDark: isDark,
            onTap: () {},
          ),
          _tile(
            icon: Icons.visibility,
            title: "Who can message me",
            subtitle: "Everyone",
            color: Colors.blue,
            isDark: isDark,
            onTap: () {},
          ),

          // 🔹 ABOUT
          _sectionTitle("About", isDark),
          _tile(
            icon: Icons.info_outline_rounded,
            title: "App Version",
            subtitle: "1.0.0",
            color: Colors.indigo,
            isDark: isDark,
          ),
          _tile(
            icon: Icons.description_outlined,
            title: "Terms & Privacy",
            color: Colors.blueGrey,
            isDark: isDark,
          ),

          // 🔴 DANGER ZONE
          _sectionTitle("Danger Zone", isDark),
          _tile(
            icon: Icons.logout_rounded,
            title: "Logout",
            color: Colors.red,
            isDark: isDark,
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => AnimatedLoginPage()),
                (route) => false,
              );
            },
          ),
          _tile(
            icon: Icons.delete_forever_rounded,
            title: "Delete Account",
            color: Colors.red,
            isDark: isDark,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
                  title: Text("Delete Account?", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                  content: Text("This action cannot be undone. All your data will be permanently removed.",
                      style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                    TextButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.currentUser!.delete();
                        if (!mounted) return;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => AnimatedLoginPage()),
                          (route) => false,
                        );
                      },
                      child: const Text("Delete", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white54 : Colors.grey.shade600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color color,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey : Colors.grey.shade500,
                ),
              )
            : null,
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: isDark ? Colors.grey : Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required bool value,
    required Color color,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        trailing: Switch.adaptive(
          value: value,
          activeColor: color,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
