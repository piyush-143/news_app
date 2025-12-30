import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app/widgets/custom_loader.dart';
import 'package:provider/provider.dart';

import '../../view_models/firebase_auth_view_model.dart';
import '../../widgets/custom_snack_bar.dart';
import '../auth/login_screen.dart';

/// Screen to view and edit the current user's profile details.
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // Removed RefreshIndicator logic and WidgetsBindingObserver

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
      barrierDismissible: false, // Prevent dismissing while loading
      builder: (context) {
        // Use Consumer to update the dialog UI when isLoading changes
        return Consumer<FirebaseAuthViewModel>(
          builder: (context, authVM, child) {
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
                // ✅ UPDATED: Stack to overlay loader in the middle of content
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Form Content (Dimmed when loading)
                    Opacity(
                      opacity: authVM.isLoading ? 0.5 : 1.0,
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
                              "Note: Changing email will require verification and re-login.",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Loader in the Center
                    if (authVM.isLoading)
                      SizedBox(width: 120, height: 60, child: CustomLoader()),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.only(bottom: 20, right: 20),
              actions: [
                TextButton(
                  // Disable cancel while loading
                  onPressed: authVM.isLoading
                      ? null
                      : () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  // ✅ UPDATED: Disable button when loading, keep text "Save"
                  onPressed: authVM.isLoading
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            // Note: We use authVM directly from Consumer
                            final isEmailChanged =
                                emailController.text.trim() != currentEmail;

                            final success = await authVM.updateUserProfile(
                              name: nameController.text.trim(),
                              email: emailController.text.trim(),
                            );

                            if (context.mounted) {
                              Navigator.pop(context); // Close Dialog

                              if (success) {
                                if (isEmailChanged &&
                                    (authVM.successMessage?.contains(
                                          "Verification",
                                        ) ??
                                        false)) {
                                  CustomSnackBar.showInfo(
                                    context,
                                    "Verification link sent. Please verify and login again.",
                                  );

                                  await authVM.logout();

                                  if (context.mounted) {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (_) => const LoginScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  }
                                } else {
                                  CustomSnackBar.showSuccess(
                                    context,
                                    authVM.successMessage ??
                                        "Profile updated successfully",
                                  );
                                }
                              } else {
                                final error =
                                    authVM.errorMessage ?? "Update failed.";
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

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile == null) return;

    if (context.mounted) {
      final authVM = context.read<FirebaseAuthViewModel>();

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
    final isLoading = fbVM.isLoading;
    final userData = fbVM.userData;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade200;
    final textColor = isDark ? Colors.white : Colors.black;

    final profilePath = fbVM.profileImagePath;
    final hasImage = profilePath != null && profilePath.isNotEmpty;

    // Fallbacks
    final displayName = userData?['name'] ?? user.displayName ?? "Not Set";
    final displayEmail = userData?['email'] ?? user.email ?? "Not Set";

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        titleSpacing: 0,
        actionsPadding: const EdgeInsets.only(right: 15),
        actions: [
          IconButton(
            onPressed: () {
              _showEditDialog(context, displayName, displayEmail, isDark);
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
                      backgroundImage: hasImage
                          ? ResizeImage(
                              FileImage(File(profilePath)),
                              width: 500,
                            )
                          : null,
                      child: !hasImage
                          ? Icon(
                              Icons.person,
                              size: 60,
                              color: isDark ? Colors.white : Colors.indigo,
                            )
                          : null,
                    ),
                  ),
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
            _buildInfoTile(
              "Full Name",
              displayName,
              Icons.person_outline_rounded,
              cardColor,
              textColor,
            ),
            const SizedBox(height: 16),
            _buildInfoTile(
              "Email Address",
              displayEmail,
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
