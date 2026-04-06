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
    const ChatPlaceholder(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReportItemPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatPage()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        );
        break;
    }
  }
}

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = MyApp.of(context)?.isDark ?? false;
    final themeColor = const Color(0xFF3A7BD5);

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
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () {
              MyApp.of(context)?.toggleTheme();
            },
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.notifications_none_rounded, color: isDark ? Colors.white : Colors.black),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔥 Welcome Section
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage("assets/profile.jpg"),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
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
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello, Partho!",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      "Have you lost anything today?",
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 🔥 Dynamic Cards
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
                        buttonText: "View Lost Items",
                        color: Colors.blue.shade50,
                        buttonColor: Colors.blue,
                        icon: Icons.help_outline,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DashboardCard(
                        title: "Items Found",
                        subtitle: "$foundCount active found reports",
                        buttonText: "View Found Items",
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
              "Recent Lost and Found Items",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // --- ITEMS LIST ---
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('items')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState(isDark);
                }
                final items = snapshot.data!.docs;

                return Column(
                  children: items.map((doc) {
                    final item = doc.data() as Map<String, dynamic>;
                    bool isFound = item['status'] == 'Found';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 1,
                      child: ListTile(
                        leading: const Icon(Icons.inventory, size: 32),
                        title: Text(item['title'] ?? ""),
                        subtitle: Text(item['location'] ?? ""),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isFound
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item['status'],
                                style: TextStyle(
                                  color: isFound ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) {
                                      final data =
                                      item as Map<String, dynamic>;
                                      data['id'] = doc.id; // ✅ FIX

                                      return ItemDetailPage(item: data);
                                    },
                                  ),
                                );
                              },
                              child: const Text(
                                "View Details",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

class ChatPlaceholder extends StatelessWidget {
  const ChatPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = MyApp.of(context)?.isDark ?? false;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          "Chat",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 80, color: Colors.blue.withValues(alpha: 0.5)),
            const SizedBox(height: 20),
            Text(
              "Chat Support",
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Coming soon! Stay tuned.",
              style: TextStyle(
                fontSize: 16, 
                color: isDark ? Colors.white60 : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Dashboard Card (UNCHANGED) ---
class DashboardCard extends StatelessWidget {
  final String title;
  final String count;
  final String label;
  final Gradient gradient;
  final IconData icon;

  const PremiumDashboardCard({
    super.key,
    required this.title,
    required this.count,
    required this.label,
    required this.gradient,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: buttonColor, size: 32),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
          const SizedBox(height: 8), // 🔥 CLEAN SPACING (NO BUTTON)
        ],
      ),
    );
  }
}

class PremiumItemTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isDark;

  const PremiumItemTile({super.key, required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    bool isFound = item['status'] == 'Found';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ItemDetailPage(item: item)),
          );
        },
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF3A7BD5).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            item['category'] == 'Electronics' ? Icons.devices : Icons.inventory_2_outlined,
            color: const Color(0xFF3A7BD5),
            size: 28,
          ),
        ),
        title: Text(
          item['title'] ?? "Unnamed Item",
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(Icons.location_on_outlined, size: 14, color: isDark ? Colors.white54 : Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                item['location'] ?? "Unknown Location", 
                style: TextStyle(color: isDark ? Colors.white54 : Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isFound ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item['status'].toUpperCase(),
                style: TextStyle(
                  color: isFound ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
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
        Icon(Icons.inbox_outlined, size: 60, color: isDark ? Colors.white24 : Colors.grey.shade300),
        const SizedBox(height: 16),
        Text(
          "No items found", 
          style: TextStyle(color: isDark ? Colors.white54 : Colors.grey.shade500, fontSize: 16),
        ),
      ],
    ),
  );
}
