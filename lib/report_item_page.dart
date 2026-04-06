import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportItemPage extends StatefulWidget {
  const ReportItemPage({super.key});

  @override
  State<ReportItemPage> createState() => _ReportItemPageState();
}

class _ReportItemPageState extends State<ReportItemPage> {
  bool isLost = true;
  File? _selectedImage;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // 🔥 ADDED (ONLY CHANGE)
  final TextEditingController uniqueIdController = TextEditingController();
  final TextEditingController insideItemController = TextEditingController();

  String? selectedCategory;
  String? selectedLocation;

  Future<void> _pickImageFromCamera() async {
    final pickedImage =
    await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = FirebaseAuth.instance.currentUser;

        await FirebaseFirestore.instance.collection('items').add({
          'title': itemNameController.text,
          'category': selectedCategory,
          'description': descriptionController.text,
          'location': selectedLocation ?? "",
          'status': isLost ? 'Lost' : 'Found',
          'userId': user?.uid,
          'createdAt': Timestamp.now(),

          // 🔥 ADDED (ONLY CHANGE)
          'uniqueIdentifier': isLost ? uniqueIdController.text : null,
          'insideDetails': isLost ? insideItemController.text : null,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Successfully Reported!"),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context);

      } catch (e) {
        print("ERROR: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isLost ? "Report Lost Item" : "Report Found Item",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toggle Section
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildToggleButton(
                        title: "Lost",
                        isSelected: isLost,
                        onTap: () => setState(() => isLost = true),
                        activeColor: const Color(0xFF6A11CB),
                      ),
                    ),
                    Expanded(
                      child: _buildToggleButton(
                        title: "Found",
                        isSelected: !isLost,
                        onTap: () => setState(() => isLost = false),
                        activeColor: const Color(0xFF00B09B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Image Selection
              _buildSectionTitle("Visual Proof"),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImageFromCamera,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.withOpacity(0.2), style: BorderStyle.solid),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.blue.shade400),
                            const SizedBox(height: 12),
                            Text("Add Photo", style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 32),

              // Details Section
              _buildSectionTitle("Item Details"),
              const SizedBox(height: 16),
              _buildPremiumTextField(
                controller: itemNameController,
                label: "Item Name",
                icon: Icons.inventory_2_outlined,
                validator: (value) => value!.isEmpty ? "Enter item name" : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: _premiumInputDecoration("Category", Icons.category_outlined),
                items: ["Electronics", "Personal", "Accessories", "Documents"]
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) => selectedCategory = value,
                validator: (value) => value == null ? "Select category" : null,
              ),
              const SizedBox(height: 20),
              _buildPremiumTextField(
                controller: descriptionController,
                label: "Short Description",
                icon: Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Location Section
              _buildSectionTitle("Location"),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: _premiumInputDecoration("Where was it?", Icons.location_on_outlined),
                items: ["Library", "Cafeteria", "Lecture Hall", "Parking", "Other"]
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (value) => selectedLocation = value,
                validator: (value) => value == null ? "Select location" : null,
              ),
              const SizedBox(height: 40),
              // 🔥 ONLY CHANGE HERE (CONNECTED CONTROLLERS)
              if (isLost) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border:
                    Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Security Questions",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),

                      TextField(
                        controller: uniqueIdController,
                        decoration: const InputDecoration(
                            labelText: "Unique identifier"),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: insideItemController,
                        decoration: const InputDecoration(
                            labelText: "What’s inside?"),
                      ),
                    ],
                  ),
                ),
              ],

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLost ? const Color(0xFF6A11CB) : const Color(0xFF00B09B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    shadowColor: (isLost ? const Color(0xFF6A11CB) : const Color(0xFF00B09B)).withOpacity(0.4),
                  ),
                  child: Text(
                    isLost ? "Report Lost Item" : "Report Found Item",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton({required String title, required bool isSelected, required VoidCallback onTap, required Color activeColor}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [BoxShadow(color: activeColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.black54),
    );
  }

  Widget _buildPremiumTextField({required TextEditingController controller, required String label, required IconData icon, String? Function(String?)? validator, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: _premiumInputDecoration(label, icon),
    );
  }

  InputDecoration _premiumInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blue.shade700),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.blue.shade200, width: 1.5)),
      floatingLabelStyle: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold),
    );
  }
}