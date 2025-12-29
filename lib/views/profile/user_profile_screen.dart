import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../view_models/firebase_auth_view_model.dart';
import '../../widgets/custom_snack_bar.dart';

/// Screen to view and edit the current user's profile details.
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // ... (Dialog Logic remains same)
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
    final inputFillColor = isDark ? Colors.white12 : Colors.grey.shade200;

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
                    fillColor: inputFillColor,
                    textColor: textColor,
                  ),
                  const SizedBox(height: 16),
                  _buildDialogTextField(
                    controller: emailController,
                    label: "Email",
                    icon: Icons.email_outlined,
                    fillColor: inputFillColor,
                    textColor: textColor,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Note: Changing email will require verification.",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
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
                  final authVM = context.read<FirebaseAuthViewModel>();

                  final success = await authVM.updateUserProfile(
                    name: nameController.text.trim(),
                    email: emailController.text.trim(),
                  );

                  if (context.mounted) {
                    Navigator.pop(context);

                    if (success) {
                      CustomSnackBar.showSuccess(
                        context,
                        "Profile updated successfully",
                      );
                    } else {
                      final error =
                          authVM.errorMessage ??
                          "Update failed. Please try again.";
                      CustomSnackBar.showError(context, error);
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
      ),
    );
  }

  // ✅ NEW: Picks image from gallery and uploads to Firebase
  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    // 1. Pick Image
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Optimize size
    );

    if (pickedFile == null) return; // User cancelled

    if (context.mounted) {
      final authVM = context.read<FirebaseAuthViewModel>();

      // 2. Upload Image
      final success = await authVM.updateProfilePicture(pickedFile.path);

      if (context.mounted) {
        if (success) {
          CustomSnackBar.showSuccess(context, "Profile picture updated!");
        } else {
          CustomSnackBar.showError(
            context,
            authVM.errorMessage ?? "Failed to upload image",
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final fbVM = context.watch<FirebaseAuthViewModel>();
    final user = fbVM.currentUser;
    final isLoading = fbVM.isLoading; // Watch loading state for spinner

    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade200;
    final textColor = isDark ? Colors.white : Colors.black;

    // Helper to safely determine if we have a valid image path
    final hasImage =
        fbVM.profileImagePath != null && fbVM.profileImagePath!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        titleSpacing: 0,
        actionsPadding: const EdgeInsets.only(right: 15),
        actions: [
          IconButton(
            onPressed: () {
              _showEditDialog(
                context,
                user.displayName ?? "",
                user.email ?? "",
                isDark,
              );
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
        child: Column(
          children: [
            const SizedBox(height: 20),

            // --- Profile Image ---
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
                      // ✅ FIXED: Null-safe check
                      backgroundImage: hasImage
                          ? ResizeImage(
                              FileImage(File(fbVM.profileImagePath!)),
                              width: 500,
                            )
                          : null,
                      // ✅ FIXED: Only show icon if no image
                      child: !hasImage
                          ? Icon(
                              Icons.person,
                              size: 60,
                              color: isDark ? Colors.white : Colors.indigo,
                            )
                          : null,
                    ),
                  ),

                  // Camera Icon Button
                  GestureDetector(
                    onTap: isLoading ? null : () => _pickImage(context),
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
                      // Show Spinner if uploading, else show Camera Icon
                      child: isLoading
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

            // --- Info Tiles ---
            _buildInfoTile(
              "Full Name",
              user.displayName ?? "Not Set", // Safely handle null displayName
              Icons.person_outline_rounded,
              cardColor,
              textColor,
            ),
            const SizedBox(height: 16),
            _buildInfoTile(
              "Email Address",
              user.email ?? "Not Set",
              Icons.email_outlined,
              cardColor,
              textColor,
            ),
          ],
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
              color: Colors.indigo.withAlpha(50),
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
