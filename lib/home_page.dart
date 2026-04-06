import 'package:flutter/material.dart';
import 'report_item_page.dart';
import 'profile_page.dart';
import 'search_page.dart';
import 'item_detail_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeBody(),
    const SearchPage(),
    const ReportItemPage(),
    const ChatPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: "Report"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                "assets/app_logo.png",
                height: 40,
                width: 40,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "UniFind",
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔥 Welcome Section
            const SizedBox(height: 10),
            Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundImage: AssetImage("assets/profile.jpg"),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser?.uid)
                        .get(),
                    builder: (context, snapshot) {
                      String name = "User";

                      if (snapshot.hasData && snapshot.data!.exists) {
                        final data =
                        snapshot.data!.data() as Map<String, dynamic>;
                        name = data['name'] ?? "User";
                      }

                      return Text(
                        "Welcome back, $name!",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 🔥 Dashboard Cards
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('items')
                  .snapshots(),
              builder: (context, snapshot) {
                int lostCount = 0;
                int foundCount = 0;

                if (snapshot.hasData) {
                  for (var doc in snapshot.data!.docs) {
                    final item = doc.data() as Map<String, dynamic>;
                    if (item['status'] == 'Lost') lostCount++;
                    if (item['status'] == 'Found') foundCount++;
                  }
                }

                return Row(
                  children: [
                    Expanded(
                      child: DashboardCard(
                        title: "Lost Items",
                        subtitle: "$lostCount active lost reports",
                        color: Colors.blue.shade50,
                        buttonColor: Colors.blue,
                        icon: Icons.help_outline,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DashboardCard(
                        title: "Items Found",
                        subtitle: "$foundCount active found reports",
                        color: Colors.green.shade50,
                        buttonColor: Colors.green,
                        icon: Icons.search,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            const Text(
              "Recent Items",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // 🔥 ITEMS LIST
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('items')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState(isDark);
                }

                final items = snapshot.data!.docs;

                return Column(
                  children: items.map((doc) {
                    final item =
                    doc.data() as Map<String, dynamic>;

                    final data = Map<String, dynamic>.from(item);
                    data['id'] = doc.id;

                    return PremiumItemTile(
                      item: data,
                      isDark: isDark,
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final Color buttonColor;
  final IconData icon;

  const DashboardCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.buttonColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: buttonColor, size: 30),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(subtitle),
        ],
      ),
    );
  }
}

class PremiumItemTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isDark;

  const PremiumItemTile(
      {super.key, required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bool isFound = item['status'] == 'Found';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
            ),
        ],
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ItemDetailPage(item: item),
            ),
          );
        },
        leading: const Icon(Icons.inventory),
        title: Text(item['title'] ?? "Unnamed"),
        subtitle: Text(item['location'] ?? ""),
        trailing: Text(
          item['status'] ?? "",
          style: TextStyle(
            color: isFound ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}

Widget _buildEmptyState(bool isDark) {
  return Center(
    child: Column(
      children: [
        const SizedBox(height: 40),
        Icon(Icons.inbox,
            size: 60,
            color: isDark ? Colors.white24 : Colors.grey),
        const SizedBox(height: 10),
        const Text("No items found"),
      ],
    ),
  );
}