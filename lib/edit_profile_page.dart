import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'main.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // 🔥 CONTROLLERS
  final nameController = TextEditingController();
  final studentIdController = TextEditingController();
  final universityController = TextEditingController();
  final courseController = TextEditingController();
  final yearController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  // 🔥 IMAGE VARIABLES
  String profileImageUrl = "";
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  // 🔥 LOAD USER DATA FROM FIRESTORE
  void loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          nameController.text = data['name'] ?? '';
          studentIdController.text = data['studentId'] ?? '';
          universityController.text = data['university'] ?? '';
          courseController.text = data['course'] ?? '';
          yearController.text = data['year'] ?? '';
          emailController.text = data['email'] ?? '';
          phoneController.text = data['phone'] ?? '';
          profileImageUrl = data['profileImage'] ?? "";
        });
      }
    }
  }

  // 🔥 FIXED IMAGE PICK + UPLOAD
  Future<void> pickAndUploadImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (pickedFile == null) return;

      File imageFile = File(pickedFile.path);
      setState(() {
        _image = imageFile;
        isUploading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final ref = FirebaseStorage.instance.ref().child('profile_images/${user.uid}.jpg');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'profileImage': downloadUrl,
      }, SetOptions(merge: true));

      setState(() {
        profileImageUrl = downloadUrl;
        isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Image Updated")));
    } catch (e) {
      setState(() => isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Image upload failed")));
    }
  }

  // 🔥 REUSABLE PREMIUM TEXT FIELD
  Widget buildPremiumTextField(String label, IconData icon, TextEditingController controller, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade600, fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF3A7BD5), size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  // 🔥 SAVE DATA TO FIRESTORE
  Future<void> saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': nameController.text,
        'studentId': studentIdController.text,
        'university': universityController.text,
        'course': courseController.text,
        'year': yearController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'profileImage': profileImageUrl,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated Successfully")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = MyApp.of(context)?.isDark ?? false;
    const themeColor = Color(0xFF3A7BD5);
    const accentColor = Color(0xFF00D2FF);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Edit Profile",
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 🔥 EDITABLE PROFILE IMAGE
            Center(
              child: GestureDetector(
                onTap: pickAndUploadImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(colors: [themeColor, accentColor]),
                        boxShadow: [
                          BoxShadow(color: themeColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: isDark ? Colors.grey.shade800 : Colors.white,
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : (profileImageUrl.isNotEmpty
                                ? NetworkImage(profileImageUrl)
                                : const AssetImage("assets/profpic.png")) as ImageProvider,
                      ),
                    ),
                    if (isUploading) const CircularProgressIndicator(color: Colors.white),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt_rounded, color: themeColor, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // --- FORM FIELDS ---
            buildPremiumTextField("Full Name", Icons.person_outline_rounded, nameController, isDark),
            buildPremiumTextField("Student ID", Icons.badge_outlined, studentIdController, isDark),
            buildPremiumTextField("University", Icons.school_outlined, universityController, isDark),
            buildPremiumTextField("Course / Major", Icons.book_outlined, courseController, isDark),
            buildPremiumTextField("Graduation Year", Icons.calendar_today_outlined, yearController, isDark),
            buildPremiumTextField("Email", Icons.email_outlined, emailController, isDark),
            buildPremiumTextField("Phone Number", Icons.phone_outlined, phoneController, isDark),

            const SizedBox(height: 32),

            // --- SAVE BUTTON ---
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(colors: [themeColor, accentColor]),
                  boxShadow: [
                    BoxShadow(color: themeColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Save Changes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade600, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
