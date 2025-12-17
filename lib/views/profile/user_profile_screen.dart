import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/db_service.dart';
import '../../view_models/db_view_model.dart';
import '../../widgets/custom_snack_bar.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String? _currentName;

  void _showEditDialog(
    BuildContext context,
    String currentName,
    String currentEmail,
    bool isDark,
  ) {
    final nameController = TextEditingController(text: currentName);
    final emailController = TextEditingController(text: currentEmail);
    final formKey = GlobalKey<FormState>();

    final dialogBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final inputFillColor = isDark ? Colors.white12 : Colors.grey.shade50;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: dialogBgColor,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Edit Profile",
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogTextField(
                    controller: nameController,
                    label: "Name",
                    icon: Icons.person_outline,
                    isDark: isDark,
                    fillColor: inputFillColor,
                    textColor: textColor,
                  ),
                  const SizedBox(height: 16),
                  _buildDialogTextField(
                    controller: emailController,
                    label: "Email",
                    icon: Icons.email_outlined,
                    isDark: isDark,
                    fillColor: inputFillColor,
                    textColor: textColor,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.only(bottom: 20, right: 20),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final dbVM = context.read<DbViewModel>();
                  final success = await dbVM.updateProfile(
                    nameController.text.trim(),
                    emailController.text.trim(),
                  );

                  if (context.mounted) {
                    Navigator.pop(context); // Close dialog
                    if (success) {
                      // Use CustomSnackBar
                      CustomSnackBar.showSuccess(
                        context,
                        "Profile updated successfully",
                      );
                    } else {
                      // Use CustomSnackBar
                      CustomSnackBar.showError(
                        context,
                        "Update failed. Email might be taken.",
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  TextFormField _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    required Color fillColor,
    required Color textColor,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: textColor),
      maxLines: maxLines,
      validator: (val) => val!.isEmpty ? "$label cannot be empty" : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500),
        prefixIcon: Icon(icon, color: Colors.indigo.shade300),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final dbVM = context.read<DbViewModel>();
    final success = await dbVM.updateProfilePicture();

    if (context.mounted) {
      if (success) {
        // Use CustomSnackBar
        CustomSnackBar.showSuccess(context, "Profile picture updated");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (rest of the build method same as before)
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dbVM = context.watch<DbViewModel>();
    final email = dbVM.currentUserEmail ?? "Guest";
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        titleSpacing: 0,
        actionsPadding: const EdgeInsets.only(right: 15),
        actions: [
          IconButton(
            onPressed: () {
              _showEditDialog(context, _currentName ?? "", email, isDark);
            },
            style: IconButton.styleFrom(
              backgroundColor: isDark
                  ? Colors.grey.shade800
                  : Colors.indigo.shade50,
            ),
            icon: Icon(
              Icons.edit_rounded,
              color: isDark ? Colors.white : Colors.indigo,
            ),
            tooltip: "Edit Profile",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: FutureBuilder<Map<String, dynamic>?>(
          future: DbService.getInstance.getUserDetails(email),
          builder: (context, snapshot) {
            final data = snapshot.data;
            _currentName = data?['Name'];
            final String? imagePath = data?['Image'];

            final displayTitle = snapshot.hasData
                ? (_currentName ?? "No Name")
                : (snapshot.connectionState == ConnectionState.waiting
                      ? "Loading..."
                      : "No Name");

            return Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                            width: 4,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: isDark
                              ? Colors.grey.shade800
                              : Colors.indigo.shade50,
                          backgroundImage:
                              (imagePath != null && imagePath.isNotEmpty)
                              ? FileImage(File(imagePath))
                              : null,
                          child: (imagePath == null || imagePath.isEmpty)
                              ? Icon(
                                  Icons.person,
                                  size: 60,
                                  color: isDark ? Colors.white : Colors.indigo,
                                )
                              : null,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _pickImage(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.indigo,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              width: 3,
                            ),
                          ),
                          child: dbVM.isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                _buildInfoTile(
                  "Full Name",
                  displayTitle,
                  Icons.person_outline_rounded,
                  cardColor,
                  textColor,
                ),
                const SizedBox(height: 16),
                _buildInfoTile(
                  "Email Address",
                  email,
                  Icons.email_outlined,
                  cardColor,
                  textColor,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    String label,
    String value,
    IconData icon,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.indigo, size: 22),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
