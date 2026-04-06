import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'claim_page.dart';

class ItemDetailPage extends StatelessWidget {
  final Map<String, dynamic> item;

  const ItemDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isDark = MyApp.of(context)?.isDark ?? false;
    final bool isFound = item['status'] == 'Found';
    const themeColor = Color(0xFF3A7BD5);
    const accentColor = Color(0xFF00D2FF);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Item Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['title'] ?? "",
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            Text(
              "Category: ${item['category'] ?? "N/A"}",
              style: const TextStyle(fontSize: 16),
            ),
          ),

          // --- CONTENT ---
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? Colors.black : Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Tag
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isFound ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isFound ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3)),
                        ),
                        child: Text(
                          item['status'].toUpperCase(),
                          style: TextStyle(
                            color: isFound ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      Text(
                        item['category'] ?? "General",
                        style: TextStyle(
                          color: isDark ? Colors.grey : Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

            Text(
              "Description: ${item['description'] ?? "No description"}",
              style: const TextStyle(fontSize: 16),
            ),

                  _buildInfoSection(
                    context,
                    title: "Description",
                    content: item['description'] ?? "No description provided.",
                    icon: Icons.description_outlined,
                    isDark: isDark,
                  ),

            Text(
              "Location: ${item['location'] ?? ""}",
              style: const TextStyle(fontSize: 16),
            ),

                  _buildInfoSection(
                    context,
                    title: "Location",
                    content: item['location'] ?? "Unknown",
                    icon: Icons.location_on_outlined,
                    isDark: isDark,
                  ),

            Text(
              "Status: ${item['status']}",
              style: TextStyle(
                color: isFound ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // 🔥 CLAIM BUTTON
            if (isFound)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClaimPage(
                          itemId: item['id'] ?? "",
                          itemName: item['title'],
                          foundBy: item['userId'],
                          category: item['category'], // 🔥 ADD THIS LINE
                        ),
                      ),
                    );
                  },
                  child: const Text("Claim Item"),
                ),
              ),

            const SizedBox(height: 10),

            // 🔹 Contact Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final userId = item['userId'];

                  if (userId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No user info available")),
                    );
                    return;
                  }

                  try {
                    final doc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .get();

                    if (!doc.exists) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("User data not found")),
                      );
                      return;
                    }

                    final userData = doc.data()!;

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Contact Finder"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Name: ${userData['name'] ?? ""}"),
                            Text("Phone: ${userData['contact'] ?? ""}"),
                            Text("Email: ${userData['email'] ?? ""}"),
                            Text("Course: ${userData['course'] ?? ""}"),
                            Text("Semester: ${userData['semester'] ?? ""}"),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: themeColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                    );
                  } catch (e) {
                    print("ERROR: $e");
                  }
                },
                child: const Text("Contact Details"),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  void _showContactDetails(BuildContext context, String? userId) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No user info available")));
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (!doc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User data not found")));
        return;
      }

      final userData = doc.data()!;
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              const Text("Contact Information", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _contactRow(Icons.person_outline, "Name", userData['name'] ?? "N/A"),
              _contactRow(Icons.phone_outlined, "Phone", userData['contact'] ?? "N/A"),
              _contactRow(Icons.email_outlined, "Email", userData['email'] ?? "N/A"),
              _contactRow(Icons.school_outlined, "Course", "${userData['course'] ?? ""} (Sem ${userData['semester'] ?? ""})"),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A7BD5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Close", style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    } catch (e) {
      print("ERROR: $e");
    }
  }

  Widget _contactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFF3A7BD5).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: const Color(0xFF3A7BD5), size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
